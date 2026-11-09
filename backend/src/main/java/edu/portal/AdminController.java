package edu.portal;

import jakarta.servlet.http.HttpServletRequest;
import java.io.InputStreamReader;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.multipart.MultipartFile;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/admin")
public class AdminController {
    private final Db db;
    private final IdGeneratorService idGen;
    private final AesService aes;
    private final PasswordEncoder enc;
    private final EmailService email;
    private final ExportService exportService;
    private final String defaultPassword;

    public AdminController(Db db, IdGeneratorService idGen, AesService aes, PasswordEncoder enc,
                           EmailService email, ExportService exportService,
                           @Value("${app.default-password:ChangeMe@123}") String defaultPassword) {
        this.db = db;
        this.idGen = idGen;
        this.aes = aes;
        this.enc = enc;
        this.email = email;
        this.exportService = exportService;
        this.defaultPassword = defaultPassword;
    }

    // =========================================================================
    // 5.1 DASHBOARD ANALYTICS & NEEDS ATTENTION
    // =========================================================================
    @GetMapping("/dashboard")
    public Map<String, Object> getDashboard() {
        long totalStudents = db.count("SELECT COUNT(*) FROM students WHERE deleted_at IS NULL");
        long totalFaculty = db.count("SELECT COUNT(*) FROM faculty WHERE deleted_at IS NULL");
        long activeCourses = db.count("SELECT COUNT(*) FROM courses");
        long openArrears = db.count("SELECT COUNT(*) FROM arrears WHERE status='PENDING'");
        long blockedAccounts = db.count("SELECT COUNT(*) FROM users WHERE is_blocked=TRUE");

        Map<String, Object> feeStats = db.one("""
            SELECT COALESCE(SUM(total_paid), 0) AS total_collected,
                   COALESCE(SUM(balance_due), 0) AS total_pending
            FROM student_fees
            """);

        Double avgAtt = db.jdbc.queryForObject("SELECT AVG(attendance_percentage) FROM student_academic_status", Double.class);
        double todayAttendance = avgAtt == null ? 85.0 : Math.round(avgAtt * 10.0) / 10.0;

        // Charts
        List<Map<String, Object>> deptStrength = db.list("""
            SELECT d.name, d.code, COUNT(s.id) AS student_count
            FROM departments d
            LEFT JOIN students s ON s.department_id = d.id AND s.deleted_at IS NULL
            GROUP BY d.id, d.name, d.code
            """);

        List<Map<String, Object>> gradeDistribution = db.list("""
            SELECT gs.letter_grade AS grade, COUNT(m.id) AS count
            FROM grade_scale gs
            LEFT JOIN marks m ON m.grade = gs.letter_grade
            GROUP BY gs.letter_grade, gs.grade_point
            ORDER BY gs.grade_point DESC
            """);

        List<Map<String, Object>> payrollByDept = db.list("""
            SELECT d.name AS department, COALESCE(SUM(fs.net_salary), 0) AS total_payroll
            FROM departments d
            LEFT JOIN faculty f ON f.department_id = d.id AND f.deleted_at IS NULL
            LEFT JOIN faculty_salary fs ON fs.faculty_id = f.id
            GROUP BY d.id, d.name
            """);

        // Needs Attention List
        List<Map<String, Object>> lowAttendance = db.list("""
            SELECT s.id, s.full_name, s.registration_number, sas.attendance_percentage, sg.parent_phone
            FROM students s
            JOIN student_academic_status sas ON sas.student_id = s.id
            LEFT JOIN student_guardians sg ON sg.student_id = s.id
            WHERE sas.attendance_percentage < 75 AND s.deleted_at IS NULL
            LIMIT 10
            """);

        List<Map<String, Object>> overdueFees = db.list("""
            SELECT s.id, s.full_name, s.registration_number, sf.balance_due, fs.due_date
            FROM student_fees sf
            JOIN students s ON s.id = sf.student_id
            JOIN fee_structures fs ON fs.id = sf.fee_structure_id
            WHERE sf.status='OVERDUE' OR (sf.balance_due > 0 AND fs.due_date < CURDATE())
            LIMIT 10
            """);

        return Map.of(
            "cards", Map.of(
                "totalStudents", totalStudents,
                "totalFaculty", totalFaculty,
                "activeCourses", activeCourses,
                "todayAttendance", todayAttendance,
                "feeCollected", (feeStats != null && feeStats.get("total_collected") != null) ? feeStats.get("total_collected") : 0,
                "feePending", (feeStats != null && feeStats.get("total_pending") != null) ? feeStats.get("total_pending") : 0,
                "openArrears", openArrears,
                "blockedAccounts", blockedAccounts
            ),
            "charts", Map.of(
                "deptStrength", deptStrength,
                "gradeDistribution", gradeDistribution,
                "payrollByDept", payrollByDept
            ),
            "needsAttention", Map.of(
                "lowAttendance", lowAttendance,
                "overdueFees", overdueFees
            )
        );
    }

    // =========================================================================
    // 5.2 STUDENT MANAGEMENT & ENCRYPTION
    // =========================================================================
    @GetMapping("/students")
    public Map<String, Object> getStudents(@RequestParam(defaultValue = "") String search,
                                           @RequestParam(required = false) Long departmentId,
                                           @RequestParam(required = false) Long programmeId,
                                           @RequestParam(required = false) Integer semester,
                                           @RequestParam(required = false) Integer yearOfStudy,
                                           @RequestParam(required = false) Integer admissionYear,
                                           @RequestParam(required = false) String gender,
                                           @RequestParam(required = false) Double minCgpa,
                                           @RequestParam(required = false) Double maxCgpa,
                                           @RequestParam(required = false) String attendanceFilter,
                                           @RequestParam(required = false) String status,
                                           @RequestParam(defaultValue = "id") String sortBy,
                                           @RequestParam(defaultValue = "desc") String sortDir,
                                           @RequestParam(defaultValue = "1") int page,
                                           @RequestParam(defaultValue = "20") int size) {
        int offset = (Math.max(1, page) - 1) * size;
        List<Object> filterParams = new ArrayList<>();
        StringBuilder filterSql = new StringBuilder(" WHERE s.deleted_at IS NULL");

        if (search != null && !search.trim().isEmpty()) {
            String q = "%" + search.trim() + "%";
            filterSql.append(" AND (s.full_name LIKE ? OR s.registration_number LIKE ? OR s.roll_number LIKE ? OR s.phone LIKE ? OR s.college_email LIKE ?)");
            filterParams.add(q);
            filterParams.add(q);
            filterParams.add(q);
            filterParams.add(q);
            filterParams.add(q);
        }
        if (departmentId != null && departmentId > 0) {
            filterSql.append(" AND s.department_id = ?");
            filterParams.add(departmentId);
        }
        if (programmeId != null && programmeId > 0) {
            filterSql.append(" AND s.programme_id = ?");
            filterParams.add(programmeId);
        }
        if (semester != null && semester > 0) {
            filterSql.append(" AND s.current_semester = ?");
            filterParams.add(semester);
        }
        if (yearOfStudy != null && yearOfStudy > 0) {
            filterSql.append(" AND s.current_year_of_study = ?");
            filterParams.add(yearOfStudy);
        }
        if (admissionYear != null && admissionYear > 0) {
            filterSql.append(" AND s.admission_year = ?");
            filterParams.add(admissionYear);
        }
        if (gender != null && !gender.trim().isEmpty() && !gender.equalsIgnoreCase("ALL")) {
            filterSql.append(" AND UPPER(s.gender) = ?");
            filterParams.add(gender.trim().toUpperCase());
        }
        if (minCgpa != null) {
            filterSql.append(" AND sas.current_cgpa >= ?");
            filterParams.add(minCgpa);
        }
        if (maxCgpa != null) {
            filterSql.append(" AND sas.current_cgpa <= ?");
            filterParams.add(maxCgpa);
        }
        if (attendanceFilter != null && !attendanceFilter.trim().isEmpty()) {
            if ("LOW".equalsIgnoreCase(attendanceFilter)) {
                filterSql.append(" AND sas.attendance_percentage < 75.0");
            } else if ("GOOD".equalsIgnoreCase(attendanceFilter)) {
                filterSql.append(" AND sas.attendance_percentage >= 75.0");
            }
        }
        if (status != null && !status.trim().isEmpty() && !status.equalsIgnoreCase("ALL")) {
            filterSql.append(" AND UPPER(s.status) = ?");
            filterParams.add(status.trim().toUpperCase());
        }

        String countSql = """
            SELECT COUNT(DISTINCT s.id)
            FROM students s
            LEFT JOIN student_academic_status sas ON sas.student_id = s.id
            """ + filterSql.toString();
        long total = db.count(countSql, filterParams.toArray());

        // Quick stats for filtered dataset
        String statsSql = """
            SELECT 
                COALESCE(SUM(CASE WHEN UPPER(s.gender) = 'MALE' THEN 1 ELSE 0 END), 0) AS male_count,
                COALESCE(SUM(CASE WHEN UPPER(s.gender) = 'FEMALE' THEN 1 ELSE 0 END), 0) AS female_count,
                COALESCE(ROUND(AVG(sas.current_cgpa), 2), 0.00) AS avg_cgpa
            FROM students s
            LEFT JOIN student_academic_status sas ON sas.student_id = s.id
            """ + filterSql.toString();
        Map<String, Object> stats = db.one(statsSql, filterParams.toArray());

        String orderClause;
        boolean isAsc = "asc".equalsIgnoreCase(sortDir);
        switch (sortBy.toLowerCase()) {
            case "name" -> orderClause = " ORDER BY s.full_name " + (isAsc ? "ASC" : "DESC");
            case "cgpa" -> orderClause = " ORDER BY sas.current_cgpa " + (isAsc ? "ASC" : "DESC");
            case "attendance" -> orderClause = " ORDER BY sas.attendance_percentage " + (isAsc ? "ASC" : "DESC");
            case "regno" -> orderClause = " ORDER BY s.registration_number " + (isAsc ? "ASC" : "DESC");
            case "year" -> orderClause = " ORDER BY s.current_year_of_study " + (isAsc ? "ASC" : "DESC") + ", s.id DESC";
            case "sem" -> orderClause = " ORDER BY s.current_semester " + (isAsc ? "ASC" : "DESC") + ", s.id DESC";
            default -> orderClause = " ORDER BY s.id " + (isAsc ? "ASC" : "DESC");
        }

        List<Object> dataParams = new ArrayList<>(filterParams);
        dataParams.add(size);
        dataParams.add(offset);

        String dataSql = """
            SELECT s.id, s.registration_number, s.roll_number, s.full_name, s.college_email, s.personal_email,
                   s.phone, s.dob, s.gender, s.abc_id, s.current_semester, s.current_year_of_study, s.admission_year,
                   s.expected_graduation_year, s.status, s.admission_type, s.photo_url,
                   d.name AS department_name, d.code AS department_code,
                   p.name AS programme_name,
                   sas.current_cgpa, sas.attendance_percentage, sas.arrears_count,
                   sg.father_name, sg.mother_name, sg.parent_phone
            FROM students s
            JOIN departments d ON d.id = s.department_id
            JOIN programmes p ON p.id = s.programme_id
            LEFT JOIN student_academic_status sas ON sas.student_id = s.id
            LEFT JOIN student_guardians sg ON sg.student_id = s.id
            """ + filterSql.toString() + orderClause + " LIMIT ? OFFSET ?";

        List<Map<String, Object>> students = db.list(dataSql, dataParams.toArray());
        Map<String, Object> resp = new HashMap<>();
        resp.put("items", students);
        resp.put("total", total);
        resp.put("page", page);
        resp.put("size", size);
        resp.put("maleCount", stats != null ? stats.get("male_count") : 0);
        resp.put("femaleCount", stats != null ? stats.get("female_count") : 0);
        resp.put("avgCgpa", stats != null ? stats.get("avg_cgpa") : 0.0);
        return resp;
    }

    @GetMapping("/students/{id}")
    public Map<String, Object> getStudentDetail(@PathVariable long id) {
        Map<String, Object> s = db.one("""
            SELECT s.*, d.name AS department_name, p.name AS programme_name,
                   sas.current_sgpa, sas.current_cgpa, sas.attendance_percentage, sas.arrears_count, sas.total_credits_earned,
                   sg.father_name, sg.mother_name, sg.guardian_name, sg.parent_phone, sg.parent_email, sg.relation
            FROM students s
            JOIN departments d ON d.id = s.department_id
            JOIN programmes p ON p.id = s.programme_id
            LEFT JOIN student_academic_status sas ON sas.student_id = s.id
            LEFT JOIN student_guardians sg ON sg.student_id = s.id
            WHERE s.id = ? AND s.deleted_at IS NULL
            """, id);
        if (s == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found");

        // Mask Aadhaar if stored
        String aadhaarEnc = (String) s.get("aadhaar_encrypted");
        if (aadhaarEnc != null && !aadhaarEnc.isBlank()) {
            s.put("aadhaar_masked", "XXXX XXXX " + (s.get("aadhaar_hash") != null ? ((String) s.get("aadhaar_hash")).substring(0, 4) : "1234"));
        } else {
            s.put("aadhaar_masked", "Not provided");
        }
        s.remove("aadhaar_encrypted"); // Never expose raw ciphertext directly

        // Fetch registered courses
        List<Map<String, Object>> courses = db.list("""
            SELECT c.code, c.name, c.credits, co.id AS offering_id, f.full_name AS faculty_name, cr.status
            FROM course_registrations cr
            JOIN course_offerings co ON co.id = cr.offering_id
            JOIN courses c ON c.id = co.course_id
            JOIN faculty f ON f.id = co.faculty_id
            WHERE cr.student_id = ?
            """, id);

        // Fetch fee dues
        List<Map<String, Object>> fees = db.list("""
            SELECT sf.*, fs.due_date, fs.total_amount
            FROM student_fees sf
            JOIN fee_structures fs ON fs.id = sf.fee_structure_id
            WHERE sf.student_id = ?
            """, id);

        // Fetch arrears
        List<Map<String, Object>> arrears = db.list("""
            SELECT a.*, c.code AS course_code, c.name AS course_name
            FROM arrears a
            JOIN courses c ON c.id = a.course_id
            WHERE a.student_id = ?
            """, id);

        return Map.of("student", s, "courses", courses, "fees", fees, "arrears", arrears);
    }

    @PostMapping("/students")
    @Transactional
    public Map<String, Object> createStudent(@AuthenticationPrincipal AuthUser user,
                                             @RequestBody Map<String, Object> body,
                                             HttpServletRequest req) {
        String fullName = (String) body.get("fullName");
        String personalEmail = (String) body.get("personalEmail");
        String phone = (String) body.get("phone");
        String dob = (String) body.get("dob");
        String gender = (String) body.get("gender");
        String address = (String) body.get("address");
        String aadhaar = (String) body.get("aadhaar");
        String abcId = (String) body.get("abcId");
        Number deptIdNum = (Number) body.get("departmentId");
        Number progIdNum = (Number) body.get("programmeId");
        Number admYearNum = (Number) body.get("admissionYear");
        String fatherName = (String) body.get("fatherName");
        String motherName = (String) body.get("motherName");
        String parentPhone = (String) body.get("parentPhone");

        if (fullName == null || deptIdNum == null || progIdNum == null || parentPhone == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Required fields missing.");
        }

        long deptId = deptIdNum.longValue();
        long progId = progIdNum.longValue();
        int admissionYear = admYearNum == null ? LocalDate.now().getYear() : admYearNum.intValue();
        int gradYear = admissionYear + 4; // Expected 4-year degree

        Map<String, Object> dept = db.one("SELECT code FROM departments WHERE id=?", deptId);
        String deptCode = dept != null ? (String) dept.get("code") : "CSE";

        // Auto-generate atomic Registration Number
        String regNumber = idGen.nextStudentId(deptCode);
        String collegeEmail = regNumber.toLowerCase() + "@college.local";
        String rollNumber = regNumber;

        // Encrypt Aadhaar if provided
        String aadhaarHash = null;
        String aadhaarEnc = null;
        if (aadhaar != null && !aadhaar.isBlank()) {
            aadhaarHash = aes.hashAadhaar(aadhaar);
            aadhaarEnc = aes.encrypt(aadhaar.trim());
        }

        // Create user account with default password and must_change_password=TRUE
        long userId = db.insert("INSERT INTO users (email, password_hash, role, must_change_password) VALUES (?,?,'STUDENT',TRUE)",
                collegeEmail, enc.encode(defaultPassword));

        long studentId = db.insert("""
            INSERT INTO students (user_id, registration_number, roll_number, full_name, college_email, personal_email,
                                  phone, dob, gender, address, aadhaar_hash, aadhaar_encrypted, abc_id,
                                  programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study)
            VALUES (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,?,1,1)
            """, userId, regNumber, rollNumber, fullName, collegeEmail, personalEmail, phone,
                dob == null ? "2005-01-01" : dob, gender == null ? "MALE" : gender, address == null ? "N/A" : address,
                aadhaarHash, aadhaarEnc, abcId, progId, deptId, admissionYear, gradYear);

        // Insert guardians
        db.insert("INSERT INTO student_guardians (student_id, father_name, mother_name, parent_phone) VALUES (?,?,?,?)",
                studentId, fatherName, motherName, parentPhone);

        // Initialize academic status
        db.insert("INSERT INTO student_academic_status (student_id, attendance_percentage, current_cgpa) VALUES (?,100.0,0.0)", studentId);

        // Log audit
        db.audit(user.id(), "CREATE", "students", String.valueOf(studentId), null, "Created student " + regNumber + " (" + fullName + ")", req.getRemoteAddr());

        // Send welcome email if personal email provided
        if (personalEmail != null && !personalEmail.isBlank()) {
            email.sendWelcomeEmail(personalEmail, fullName, regNumber, "Student");
        }

        return Map.of("success", true, "id", studentId, "registrationNumber", regNumber, "email", collegeEmail);
    }

    @PostMapping("/students/{id}/reveal-aadhaar")
    public Map<String, Object> revealAadhaar(@AuthenticationPrincipal AuthUser user, @PathVariable long id, HttpServletRequest req) {
        Map<String, Object> s = db.one("SELECT aadhaar_encrypted, registration_number FROM students WHERE id=?", id);
        if (s == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found");

        String encText = (String) s.get("aadhaar_encrypted");
        if (encText == null || encText.isBlank()) {
            return Map.of("aadhaar", "Not provided");
        }

        String decrypted = aes.decrypt(encText);

        // DPDP Act 2023 Compliance: Log every reveal action
        db.audit(user.id(), "REVEAL", "students", String.valueOf(id), null, "Revealed Aadhaar for student " + s.get("registration_number"), req.getRemoteAddr());

        return Map.of("aadhaar", decrypted != null ? decrypted : "Unavailable");
    }

    // =========================================================================
    // 5.3 FACULTY MANAGEMENT
    // =========================================================================
    @GetMapping("/faculty")
    public List<Map<String, Object>> getFacultyList() {
        return db.list("""
            SELECT f.id, f.employee_id, f.full_name, f.email, f.phone, f.qualification, f.experience_years,
                   f.joining_date, f.employment_type, f.status, f.photo_url,
                   des.title AS designation, d.name AS department_name, d.code AS department_code,
                   COALESCE(fs.net_salary, 0) AS net_salary
            FROM faculty f
            JOIN designations des ON des.id = f.designation_id
            JOIN departments d ON d.id = f.department_id
            LEFT JOIN faculty_salary fs ON fs.faculty_id = f.id
            WHERE f.deleted_at IS NULL
            ORDER BY f.id DESC
            """);
    }

    @PostMapping("/faculty")
    @Transactional
    public Map<String, Object> createFaculty(@AuthenticationPrincipal AuthUser user,
                                             @RequestBody Map<String, Object> body,
                                             HttpServletRequest req) {
        String fullName = (String) body.get("fullName");
        String personalEmail = (String) body.get("email");
        String phone = (String) body.get("phone");
        Number desigIdNum = (Number) body.get("designationId");
        Number deptIdNum = (Number) body.get("departmentId");
        String qualification = (String) body.get("qualification");
        Number expNum = (Number) body.get("experienceYears");
        Number basicPayNum = (Number) body.get("basicPay");

        if (fullName == null || desigIdNum == null || deptIdNum == null || personalEmail == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Required fields missing.");
        }

        long desigId = desigIdNum.longValue();
        long deptId = deptIdNum.longValue();
        String empId = idGen.nextFacultyId();
        String loginEmail = personalEmail.trim().toLowerCase();

        long userId = db.insert("INSERT INTO users (email, password_hash, role, must_change_password) VALUES (?,?,'FACULTY',TRUE)",
                loginEmail, enc.encode(defaultPassword));

        long facultyId = db.insert("""
            INSERT INTO faculty (user_id, employee_id, full_name, email, phone, designation_id, department_id,
                                 qualification, experience_years, joining_date, employment_type)
            VALUES (?,?,?,?,?,?,?,?,?,CURDATE(),'PERMANENT')
            """, userId, empId, fullName, loginEmail, phone == null ? "N/A" : phone, desigId, deptId,
                qualification == null ? "M.Tech / Ph.D" : qualification, expNum == null ? 3 : expNum.intValue());

        // Assign default salary
        double basic = basicPayNum != null ? basicPayNum.doubleValue() : 65000.00;
        double hra = basic * 0.20;
        double da = basic * 0.15;
        double allowances = 5000.00;
        double pf = basic * 0.12;
        double tax = basic * 0.05;
        double net = basic + hra + da + allowances - pf - tax;

        db.insert("""
            INSERT INTO faculty_salary (faculty_id, basic_pay, hra, da, allowances, pf, tax, net_salary, effective_date)
            VALUES (?,?,?,?,?,?,?,?,CURDATE())
            """, facultyId, basic, hra, da, allowances, pf, tax, net);

        db.audit(user.id(), "CREATE", "faculty", String.valueOf(facultyId), null, "Created faculty " + empId + " (" + fullName + ")", req.getRemoteAddr());
        email.sendWelcomeEmail(loginEmail, fullName, empId, "Faculty");

        return Map.of("success", true, "id", facultyId, "employeeId", empId);
    }

    // =========================================================================
    // 5.4 SALARY & PAYROLL
    // =========================================================================
    @GetMapping("/payroll/runs")
    public List<Map<String, Object>> getPayrollRuns() {
        return db.list("SELECT * FROM payroll_runs ORDER BY id DESC");
    }

    @PostMapping("/payroll/generate")
    @Transactional
    public Map<String, Object> generateMonthlyPayroll(@AuthenticationPrincipal AuthUser user, @RequestBody Map<String, String> body) {
        String monthYear = body.getOrDefault("monthYear", String.format("%02d-%d", LocalDate.now().getMonthValue(), LocalDate.now().getYear()));

        Map<String, Object> existing = db.one("SELECT id, status FROM payroll_runs WHERE month_year=?", monthYear);
        if (existing != null && "PAID".equals(existing.get("status"))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Payroll for " + monthYear + " has already been locked and paid.");
        }

        long runId;
        if (existing == null) {
            runId = db.insert("INSERT INTO payroll_runs (month_year, status, processed_by, processed_at) VALUES (?,'DRAFT',?,NOW())",
                    monthYear, user.id());
        } else {
            runId = ((Number) existing.get("id")).longValue();
            db.update("DELETE FROM payslips WHERE payroll_run_id=?", runId);
        }

        List<Map<String, Object>> facultyList = db.list("""
            SELECT f.id, COALESCE(fs.basic_pay, 60000) AS basic, COALESCE(fs.hra, 12000) AS hra,
                   COALESCE(fs.da, 9000) AS da, COALESCE(fs.allowances, 5000) AS allowances,
                   (COALESCE(fs.pf, 7200) + COALESCE(fs.tax, 3000)) AS deductions,
                   COALESCE(fs.net_salary, 75800) AS net
            FROM faculty f
            LEFT JOIN faculty_salary fs ON fs.faculty_id = f.id
            WHERE f.deleted_at IS NULL
            """);

        double totalDisbursed = 0;
        for (Map<String, Object> fac : facultyList) {
            long fId = ((Number) fac.get("id")).longValue();
            double basic = ((Number) fac.get("basic")).doubleValue();
            double hra = ((Number) fac.get("hra")).doubleValue();
            double da = ((Number) fac.get("da")).doubleValue();
            double allow = ((Number) fac.get("allowances")).doubleValue();
            double ded = ((Number) fac.get("deductions")).doubleValue();
            double net = ((Number) fac.get("net")).doubleValue();
            totalDisbursed += net;

            db.insert("""
                INSERT INTO payslips (payroll_run_id, faculty_id, basic, hra, da, allowances, deductions, net_amount)
                VALUES (?,?,?,?,?,?,?,?)
                """, runId, fId, basic, hra, da, allow, ded, net);
        }

        db.update("UPDATE payroll_runs SET total_disbursed=?, status='DRAFT' WHERE id=?", totalDisbursed, runId);
        return Map.of("success", true, "runId", runId, "monthYear", monthYear, "totalDisbursed", totalDisbursed, "payslipsGenerated", facultyList.size());
    }

    @PostMapping("/payroll/runs/{id}/mark-paid")
    public Map<String, Object> markPayrollPaid(@PathVariable long id) {
        db.update("UPDATE payroll_runs SET status='PAID' WHERE id=?", id);
        return Map.of("success", true, "message", "Payroll marked as PAID and locked.");
    }

    // =========================================================================
    // 5.5 ACADEMIC STRUCTURE (DEPARTMENTS, COURSES, OFFERINGS)
    // =========================================================================
    @GetMapping("/departments")
    public List<Map<String, Object>> getDepartments() {
        return db.list("SELECT * FROM departments ORDER BY name ASC");
    }

    @GetMapping("/programmes")
    public List<Map<String, Object>> getProgrammes() {
        return db.list("""
            SELECT p.*, d.name AS department_name
            FROM programmes p
            JOIN departments d ON d.id = p.department_id
            ORDER BY p.name ASC
            """);
    }

    @GetMapping("/courses")
    public List<Map<String, Object>> getCourses() {
        return db.list("""
            SELECT c.*, d.name AS department_name
            FROM courses c
            JOIN departments d ON d.id = c.department_id
            ORDER BY c.code ASC
            """);
    }

    @PostMapping("/courses")
    public Map<String, Object> createCourse(@RequestBody Map<String, Object> body) {
        String code = ((String) body.get("code")).trim().toUpperCase();
        String name = (String) body.get("name");
        Number credits = (Number) body.get("credits");
        Number deptId = (Number) body.get("departmentId");
        Number sem = (Number) body.get("semesterNumber");
        String type = (String) body.getOrDefault("courseType", "THEORY");

        long id = db.insert("INSERT INTO courses (code, name, credits, course_type, semester_number, department_id) VALUES (?,?,?,?,?,?)",
                code, name, credits == null ? 3 : credits.intValue(), type, sem == null ? 1 : sem.intValue(), deptId.longValue());
        return Map.of("success", true, "id", id);
    }

    // =========================================================================
    // 5.10 TIMETABLE & CONFLICT DETECTION
    // =========================================================================
    @GetMapping("/timetable/{sectionId}")
    public Map<String, Object> getTimetableGrid(@PathVariable long sectionId) {
        Map<String, Object> version = db.one("SELECT * FROM timetable_versions WHERE section_id=? AND is_active=TRUE", sectionId);
        if (version == null) return Map.of("version", Map.of(), "slots", List.of());

        long vId = ((Number) version.get("id")).longValue();
        List<Map<String, Object>> slots = db.list("""
            SELECT ts.*, c.code AS course_code, c.name AS course_name, f.full_name AS faculty_name, r.room_number
            FROM timetable_slots ts
            JOIN course_offerings co ON co.id = ts.offering_id
            JOIN courses c ON c.id = co.course_id
            JOIN faculty f ON f.id = co.faculty_id
            JOIN rooms r ON r.id = ts.room_id
            WHERE ts.version_id = ?
            ORDER BY ts.day_of_week, ts.period_number
            """, vId);

        return Map.of("version", version, "slots", slots);
    }

    @PostMapping("/timetable/slot")
    public Map<String, Object> createTimetableSlot(@RequestBody Map<String, Object> body) {
        Number vIdNum = (Number) body.get("versionId");
        Number dayNum = (Number) body.get("dayOfWeek");
        Number periodNum = (Number) body.get("periodNumber");
        Number offeringIdNum = (Number) body.get("offeringId");
        Number roomIdNum = (Number) body.get("roomId");

        long vId = vIdNum.longValue();
        int day = dayNum.intValue();
        int period = periodNum.intValue();
        long offeringId = offeringIdNum.longValue();
        long roomId = roomIdNum.longValue();

        // 1. Conflict Check: Room double-booked at the same time
        long roomConflicts = db.count("""
            SELECT COUNT(*) FROM timetable_slots ts
            JOIN timetable_versions tv ON tv.id = ts.version_id
            WHERE ts.room_id = ? AND ts.day_of_week = ? AND ts.period_number = ? AND tv.is_active = TRUE AND ts.version_id <> ?
            """, roomId, day, period, vId);
        if (roomConflicts > 0) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "Room Conflict: Room is already booked for another section at this time.");
        }

        // 2. Conflict Check: Faculty double-booked across sections
        Map<String, Object> off = db.one("SELECT faculty_id FROM course_offerings WHERE id=?", offeringId);
        if (off != null) {
            long facultyId = ((Number) off.get("faculty_id")).longValue();
            long facultyConflicts = db.count("""
                SELECT COUNT(*) FROM timetable_slots ts
                JOIN course_offerings co ON co.id = ts.offering_id
                JOIN timetable_versions tv ON tv.id = ts.version_id
                WHERE co.faculty_id = ? AND ts.day_of_week = ? AND ts.period_number = ? AND tv.is_active = TRUE
                """, facultyId, day, period);
            if (facultyConflicts > 0) {
                throw new ResponseStatusException(HttpStatus.CONFLICT, "Faculty Conflict: Assigned faculty member has another class in this period.");
            }
        }

        String startTime = period == 1 ? "09:00:00" : period == 2 ? "10:00:00" : period == 3 ? "11:15:00" : period == 4 ? "12:15:00" : period == 5 ? "14:00:00" : "15:00:00";
        String endTime = period == 1 ? "10:00:00" : period == 2 ? "11:00:00" : period == 3 ? "12:15:00" : period == 4 ? "13:15:00" : period == 5 ? "15:00:00" : "16:00:00";

        long slotId = db.insert("""
            INSERT INTO timetable_slots (version_id, day_of_week, period_number, start_time, end_time, offering_id, room_id)
            VALUES (?,?,?,?,?,?,?)
            """, vId, day, period, startTime, endTime, offeringId, roomId);

        return Map.of("success", true, "slotId", slotId);
    }

    // =========================================================================
    // 5.7 ARREAR MANAGEMENT
    // =========================================================================
    @GetMapping("/arrears")
    public List<Map<String, Object>> getArrearList() {
        return db.list("""
            SELECT a.id, a.status, a.attempts_count, a.created_at,
                   s.full_name AS student_name, s.registration_number, s.college_email,
                   c.code AS course_code, c.name AS course_name, c.credits,
                   d.name AS department_name
            FROM arrears a
            JOIN students s ON s.id = a.student_id
            JOIN courses c ON c.id = a.course_id
            JOIN departments d ON d.id = s.department_id
            ORDER BY a.status ASC, a.id DESC
            """);
    }

    // =========================================================================
    // 5.13 ANNOUNCEMENTS & TARGETED NOTIFICATIONS
    // =========================================================================
    @GetMapping("/announcements")
    public List<Map<String, Object>> getAnnouncements() {
        return db.list("""
            SELECT a.*, u.email AS author_email
            FROM announcements a
            JOIN users u ON u.id = a.author_id
            ORDER BY a.created_at DESC
            """);
    }

    @PostMapping("/announcements")
    @Transactional
    public Map<String, Object> createAnnouncement(@AuthenticationPrincipal AuthUser user, @RequestBody Map<String, Object> body) {
        String title = (String) body.get("title");
        String content = (String) body.get("content");
        String priority = (String) body.getOrDefault("priority", "INFO");
        String channel = (String) body.getOrDefault("channel", "IN_APP");
        String targetType = (String) body.getOrDefault("targetType", "EVERYONE");

        long annId = db.insert("""
            INSERT INTO announcements (title, content, priority, channel, target_type, author_id)
            VALUES (?,?,?,?,?,?)
            """, title, content, priority, channel, targetType, user.id());

        // Broadcast notifications to target users
        List<Map<String, Object>> targetUsers;
        if ("ALL_STUDENTS".equals(targetType)) {
            targetUsers = db.list("SELECT user_id FROM students WHERE deleted_at IS NULL");
        } else if ("ALL_FACULTY".equals(targetType)) {
            targetUsers = db.list("SELECT user_id FROM faculty WHERE deleted_at IS NULL");
        } else {
            targetUsers = db.list("SELECT id AS user_id FROM users WHERE is_blocked=FALSE");
        }

        for (Map<String, Object> tu : targetUsers) {
            long uid = ((Number) tu.get("user_id")).longValue();
            db.notify(uid, title, content, "ANNOUNCEMENT", "/announcements");
        }

        return Map.of("success", true, "id", annId);
    }

    // =========================================================================
    // 5.14 LOGS & REGISTERS (AUDIT, LOGIN, BLOCKED REGISTER, COMMUNICATION)
    // =========================================================================
    @GetMapping("/logs/audit")
    public List<Map<String, Object>> getAuditLogs() {
        return db.list("""
            SELECT al.*, u.email AS user_email, u.role AS user_role
            FROM audit_log al
            LEFT JOIN users u ON u.id = al.user_id
            ORDER BY al.id DESC LIMIT 100
            """);
    }

    @GetMapping("/logs/login")
    public List<Map<String, Object>> getLoginLogs() {
        return db.list("SELECT * FROM login_log ORDER BY id DESC LIMIT 100");
    }

    @GetMapping("/logs/blocked")
    public List<Map<String, Object>> getBlockedAccountRegister() {
        return db.list("""
            SELECT bar.*, u.email AS account_email, u.role AS account_role,
                   admin_u.email AS blocked_by_email
            FROM blocked_account_register bar
            JOIN users u ON u.id = bar.user_id
            LEFT JOIN users admin_u ON admin_u.id = bar.blocked_by_user_id
            ORDER BY bar.id DESC
            """);
    }

    @GetMapping("/logs/communication")
    public List<Map<String, Object>> getCommunicationLogs() {
        return db.list("SELECT * FROM email_outbox ORDER BY id DESC LIMIT 100");
    }

    @PostMapping("/users/{userId}/toggle-block")
    public Map<String, Object> toggleBlockUser(@AuthenticationPrincipal AuthUser user,
                                               @PathVariable long userId,
                                               @RequestBody Map<String, String> body,
                                               HttpServletRequest req) {
        Map<String, Object> u = db.one("SELECT is_blocked, email FROM users WHERE id=?", userId);
        if (u == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "User not found");

        boolean currentlyBlocked = Boolean.TRUE.equals(u.get("is_blocked"));
        boolean newBlocked = !currentlyBlocked;
        String reason = body.getOrDefault("reason", newBlocked ? "Blocked by administrator" : "Unblocked by administrator");

        db.update("UPDATE users SET is_blocked=?, blocked_reason=?, blocked_at=? WHERE id=?",
                newBlocked, newBlocked ? reason : null, newBlocked ? LocalDate.now() : null, userId);

        db.logBlocked(userId, user.id(), newBlocked ? "BLOCKED" : "UNBLOCKED", reason, req.getRemoteAddr());
        db.audit(user.id(), newBlocked ? "BLOCK_USER" : "UNBLOCK_USER", "users", String.valueOf(userId), null, reason, req.getRemoteAddr());

        return Map.of("success", true, "isBlocked", newBlocked);
    }

    @GetMapping("/sections")
    public List<Map<String, Object>> getSections() {
        return db.list("""
            SELECT sec.*, sem.semester_number, b.admission_year, p.name AS programme_name
            FROM sections sec
            JOIN semesters sem ON sem.id = sec.semester_id
            JOIN batches b ON b.id = sem.batch_id
            JOIN programmes p ON p.id = b.programme_id
            ORDER BY sec.id ASC
            """);
    }

    @GetMapping("/assignments")
    public List<Map<String, Object>> getAdminAssignments() {
        return db.list("""
            SELECT a.*, c.code AS course_code, c.name AS course_name,
                   f.full_name AS faculty_name, sec.name AS section_name,
                   (SELECT COUNT(*) FROM assignment_submissions asub WHERE asub.assignment_id = a.id) AS submission_count
            FROM assignments a
            JOIN course_offerings co ON co.id = a.offering_id
            JOIN courses c ON c.id = co.course_id
            JOIN faculty f ON f.id = co.faculty_id
            JOIN sections sec ON sec.id = co.section_id
            ORDER BY a.due_date DESC
            """);
    }

    @PutMapping("/students/{id}")
    public Map<String, Object> updateStudent(@AuthenticationPrincipal AuthUser user,
                                             @PathVariable long id,
                                             @RequestBody Map<String, Object> body,
                                             HttpServletRequest req) {
        Map<String, Object> existing = db.one("SELECT * FROM students WHERE id=? AND deleted_at IS NULL", id);
        if (existing == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found");

        String fullName = (String) body.get("fullName");
        String phone = (String) body.get("phone");
        String personalEmail = (String) body.get("personalEmail");
        String address = (String) body.get("address");
        String status = (String) body.getOrDefault("status", existing.get("status"));
        Number sectionIdNum = (Number) body.get("sectionId");

        db.update("""
            UPDATE students
            SET full_name = COALESCE(?, full_name),
                phone = COALESCE(?, phone),
                personal_email = COALESCE(?, personal_email),
                address = COALESCE(?, address),
                status = ?,
                section_id = COALESCE(?, section_id)
            WHERE id = ?
            """, fullName, phone, personalEmail, address, status, sectionIdNum != null ? sectionIdNum.longValue() : null, id);

        db.audit(user.id(), "UPDATE_STUDENT", "students", String.valueOf(id), null, "Updated student profile", req.getRemoteAddr());
        return Map.of("success", true);
    }

    @DeleteMapping("/students/{id}")
    public Map<String, Object> deleteStudent(@AuthenticationPrincipal AuthUser user,
                                             @PathVariable long id,
                                             HttpServletRequest req) {
        Map<String, Object> existing = db.one("SELECT user_id FROM students WHERE id=? AND deleted_at IS NULL", id);
        if (existing == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student not found");

        db.update("UPDATE students SET deleted_at=NOW(), status='DISCONTINUED' WHERE id=?", id);
        db.update("UPDATE users SET deleted_at=NOW(), is_blocked=TRUE WHERE id=?", existing.get("user_id"));
        db.audit(user.id(), "DELETE_STUDENT", "students", String.valueOf(id), null, "Soft deleted student", req.getRemoteAddr());
        return Map.of("success", true);
    }

    @PutMapping("/faculty/{id}")
    public Map<String, Object> updateFaculty(@AuthenticationPrincipal AuthUser user,
                                             @PathVariable long id,
                                             @RequestBody Map<String, Object> body,
                                             HttpServletRequest req) {
        Map<String, Object> existing = db.one("SELECT * FROM faculty WHERE id=? AND deleted_at IS NULL", id);
        if (existing == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Faculty not found");

        String fullName = (String) body.get("fullName");
        String phone = (String) body.get("phone");
        String qualification = (String) body.get("qualification");
        Number expNum = (Number) body.get("experienceYears");
        String status = (String) body.getOrDefault("status", existing.get("status"));

        db.update("""
            UPDATE faculty
            SET full_name = COALESCE(?, full_name),
                phone = COALESCE(?, phone),
                qualification = COALESCE(?, qualification),
                experience_years = COALESCE(?, experience_years),
                status = ?
            WHERE id = ?
            """, fullName, phone, qualification, expNum != null ? expNum.intValue() : null, status, id);

        db.audit(user.id(), "UPDATE_FACULTY", "faculty", String.valueOf(id), null, "Updated faculty profile", req.getRemoteAddr());
        return Map.of("success", true);
    }

    @PostMapping("/fees/payments")
    public Map<String, Object> recordFeePayment(@AuthenticationPrincipal AuthUser user,
                                                @RequestBody Map<String, Object> body,
                                                HttpServletRequest req) {
        Number studentFeeIdNum = (Number) body.get("studentFeeId");
        Number amountNum = (Number) body.get("amount");
        String paymentMode = (String) body.getOrDefault("paymentMode", "ONLINE");
        String reference = (String) body.getOrDefault("reference", "REF-" + System.currentTimeMillis());

        if (studentFeeIdNum == null || amountNum == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "studentFeeId and amount are required");
        }

        long sfId = studentFeeIdNum.longValue();
        double amount = amountNum.doubleValue();

        Map<String, Object> sf = db.one("SELECT sf.*, s.user_id FROM student_fees sf JOIN students s ON s.id = sf.student_id WHERE sf.id=?", sfId);
        if (sf == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Student fee record not found");

        String receiptNum = idGen.nextReceiptNumber();
        long paymentId = db.insert("""
            INSERT INTO fee_payments (student_fee_id, amount_paid, payment_mode, transaction_reference, receipt_number, payment_date, received_by)
            VALUES (?,?,?,?,?,NOW(),?)
            """, sfId, amount, paymentMode, reference, receiptNum, user.id());

        double currentPaid = ((Number) sf.getOrDefault("total_paid", 0.0)).doubleValue();
        double totalPayable = ((Number) sf.getOrDefault("total_payable", 0.0)).doubleValue();
        double newPaid = currentPaid + amount;
        double newBalance = Math.max(0.0, totalPayable - newPaid);
        String newStatus = newBalance <= 0 ? "PAID" : "PARTIAL";

        db.update("UPDATE student_fees SET total_paid=?, balance_due=?, status=? WHERE id=?", newPaid, newBalance, newStatus, sfId);

        db.notify(((Number) sf.get("user_id")).longValue(), "Fee Payment Received",
                "Payment of INR " + amount + " recorded. Receipt: " + receiptNum, "FEE", "/student/fees");

        db.audit(user.id(), "RECORD_PAYMENT", "fee_payments", String.valueOf(paymentId), null, "Amount: " + amount + " Receipt: " + receiptNum, req.getRemoteAddr());

        return Map.of("success", true, "paymentId", paymentId, "receiptNumber", receiptNum);
    }

    @GetMapping("/search")
    public Map<String, Object> globalSearch(@RequestParam("q") String query) {
        if (query == null || query.trim().length() < 2) {
            return Map.of("students", List.of(), "faculty", List.of(), "courses", List.of());
        }
        String q = "%" + query.trim() + "%";
        List<Map<String, Object>> students = db.list("""
            SELECT id, full_name, registration_number, college_email
            FROM students
            WHERE (full_name LIKE ? OR registration_number LIKE ? OR roll_number LIKE ?) AND deleted_at IS NULL
            LIMIT 10
            """, q, q, q);

        List<Map<String, Object>> faculty = db.list("""
            SELECT id, full_name, employee_id, email
            FROM faculty
            WHERE (full_name LIKE ? OR employee_id LIKE ?) AND deleted_at IS NULL
            LIMIT 10
            """, q, q);

        List<Map<String, Object>> courses = db.list("""
            SELECT id, code, name, credits
            FROM courses
            WHERE code LIKE ? OR name LIKE ?
            LIMIT 10
            """, q, q);

        return Map.of("students", students, "faculty", faculty, "courses", courses);
    }

    @GetMapping("/reports/summary")
    public Map<String, Object> getReportsSummary() {
        List<Map<String, Object>> deptStats = db.list("""
            SELECT d.name AS department_name,
                   COUNT(DISTINCT s.id) AS total_students,
                   COUNT(DISTINCT f.id) AS total_faculty,
                   COUNT(DISTINCT c.id) AS total_courses
            FROM departments d
            LEFT JOIN students s ON s.department_id = d.id AND s.deleted_at IS NULL
            LEFT JOIN faculty f ON f.department_id = d.id AND f.deleted_at IS NULL
            LEFT JOIN courses c ON c.department_id = d.id
            GROUP BY d.id, d.name
            """);

        Map<String, Object> feesOverview = db.one("""
            SELECT COALESCE(SUM(total_payable), 0) AS total_billed,
                   COALESCE(SUM(total_paid), 0) AS total_collected,
                   COALESCE(SUM(balance_due), 0) AS total_pending
            FROM student_fees
            """);

        List<Map<String, Object>> gradeDist = db.list("""
            SELECT grade, COUNT(*) AS count
            FROM marks
            GROUP BY grade
            ORDER BY count DESC
            """);

        return Map.of("departments", deptStats, "fees", feesOverview, "gradeDistribution", gradeDist);
    }
}
