package edu.portal;

import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.springframework.core.io.ByteArrayResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/faculty")
public class FacultyController {
    private final Db db;
    private final ExportService exportService;

    public FacultyController(Db db, ExportService exportService) {
        this.db = db;
        this.exportService = exportService;
    }

    @GetMapping("/dashboard")
    public Map<String, Object> getFacultyDashboard(@AuthenticationPrincipal AuthUser user) {
        long facultyId = db.facultyIdFor(user.id());
        int todayDay = LocalDate.now().getDayOfWeek().getValue(); // 1=Mon .. 7=Sun

        // Today's classes
        List<Map<String, Object>> todayClasses = db.list("""
            SELECT ts.id AS slot_id, ts.period_number, ts.start_time, ts.end_time,
                   c.code AS course_code, c.name AS course_name,
                   sec.name AS section_name, r.room_number, co.id AS offering_id
            FROM timetable_slots ts
            JOIN course_offerings co ON co.id = ts.offering_id
            JOIN courses c ON c.id = co.course_id
            JOIN sections sec ON sec.id = co.section_id
            JOIN rooms r ON r.id = ts.room_id
            JOIN timetable_versions tv ON tv.id = ts.version_id
            WHERE co.faculty_id = ? AND ts.day_of_week = ? AND tv.is_active = TRUE
            ORDER BY ts.period_number ASC
            """, facultyId, todayDay);

        // Active courses taught
        long courseCount = db.count("SELECT COUNT(DISTINCT course_id) FROM course_offerings WHERE faculty_id=?", facultyId);

        // Total students across all sections
        long studentCount = db.count("""
            SELECT COUNT(DISTINCT cr.student_id)
            FROM course_registrations cr
            JOIN course_offerings co ON co.id = cr.offering_id
            WHERE co.faculty_id = ?
            """, facultyId);

        // Pending assignments to grade
        long pendingGrading = db.count("""
            SELECT COUNT(asub.id)
            FROM assignment_submissions asub
            JOIN assignments a ON a.id = asub.assignment_id
            JOIN course_offerings co ON co.id = a.offering_id
            WHERE co.faculty_id = ? AND asub.marks_obtained IS NULL
            """, facultyId);

        return Map.of(
            "todayClasses", todayClasses,
            "stats", Map.of(
                "coursesTaught", courseCount,
                "totalStudents", studentCount,
                "pendingGrading", pendingGrading
            )
        );
    }

    @GetMapping("/courses")
    public List<Map<String, Object>> getMyCourses(@AuthenticationPrincipal AuthUser user) {
        long facultyId = db.facultyIdFor(user.id());
        return db.list("""
            SELECT co.id AS offering_id, c.code, c.name, c.credits, c.course_type,
                   sec.name AS section_name, sem.semester_number,
                   (SELECT COUNT(*) FROM course_registrations cr WHERE cr.offering_id = co.id) AS student_count
            FROM course_offerings co
            JOIN courses c ON c.id = co.course_id
            JOIN sections sec ON sec.id = co.section_id
            JOIN semesters sem ON sem.id = co.semester_id
            WHERE co.faculty_id = ?
            ORDER BY c.code ASC
            """, facultyId);
    }

    @GetMapping("/courses/{offeringId}/students")
    public List<Map<String, Object>> getCourseStudents(@AuthenticationPrincipal AuthUser user, @PathVariable long offeringId) {
        long facultyId = db.facultyIdFor(user.id());
        Map<String, Object> off = db.one("SELECT id FROM course_offerings WHERE id=? AND faculty_id=?", offeringId, facultyId);
        if (off == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized for this course offering.");

        return db.list("""
            SELECT s.id, s.full_name, s.registration_number, s.college_email,
                   sg.parent_phone,
                   sas.attendance_percentage, sas.current_cgpa
            FROM course_registrations cr
            JOIN students s ON s.id = cr.student_id
            LEFT JOIN student_guardians sg ON sg.student_id = s.id
            LEFT JOIN student_academic_status sas ON sas.student_id = s.id
            WHERE cr.offering_id = ? AND s.deleted_at IS NULL
            ORDER BY s.registration_number ASC
            """, offeringId);
    }

    @PostMapping("/attendance/mark")
    @Transactional
    public Map<String, Object> markAttendance(@AuthenticationPrincipal AuthUser user, @RequestBody Map<String, Object> body) {
        long facultyId = db.facultyIdFor(user.id());
        Number offeringIdNum = (Number) body.get("offeringId");
        String sessionDate = (String) body.getOrDefault("sessionDate", LocalDate.now().toString());
        Number periodNum = (Number) body.getOrDefault("periodNumber", 1);
        String topic = (String) body.get("topicCovered");
        List<Map<String, Object>> records = (List<Map<String, Object>>) body.get("records");

        long offeringId = offeringIdNum.longValue();
        Map<String, Object> off = db.one("SELECT id FROM course_offerings WHERE id=? AND faculty_id=?", offeringId, facultyId);
        if (off == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized for this course offering.");

        long sessionId = db.insert("""
            INSERT INTO attendance_sessions (offering_id, session_date, period_number, topic_covered, marked_by_faculty_id)
            VALUES (?,?,?,?,?)
            """, offeringId, sessionDate, periodNum.intValue(), topic, facultyId);

        if (records != null) {
            for (Map<String, Object> rec : records) {
                long studentId = ((Number) rec.get("studentId")).longValue();
                String status = (String) rec.getOrDefault("status", "PRESENT");
                db.insert("INSERT INTO attendance_records (session_id, student_id, status) VALUES (?,?,?)",
                        sessionId, studentId, status);
            }
        }

        return Map.of("success", true, "sessionId", sessionId, "markedCount", records != null ? records.size() : 0);
    }

    @GetMapping("/timetable")
    public List<Map<String, Object>> getMyTimetable(@AuthenticationPrincipal AuthUser user) {
        long facultyId = db.facultyIdFor(user.id());
        return db.list("""
            SELECT ts.day_of_week, ts.period_number, ts.start_time, ts.end_time,
                   c.code AS course_code, c.name AS course_name, sec.name AS section_name, r.room_number,
                   ts.is_updated
            FROM timetable_slots ts
            JOIN course_offerings co ON co.id = ts.offering_id
            JOIN courses c ON c.id = co.course_id
            JOIN sections sec ON sec.id = co.section_id
            JOIN rooms r ON r.id = ts.room_id
            JOIN timetable_versions tv ON tv.id = ts.version_id
            WHERE co.faculty_id = ? AND tv.is_active = TRUE
            ORDER BY ts.day_of_week, ts.period_number
            """, facultyId);
    }

    @GetMapping("/payslips")
    public List<Map<String, Object>> getMyPayslips(@AuthenticationPrincipal AuthUser user) {
        long facultyId = db.facultyIdFor(user.id());
        return db.list("""
            SELECT p.*, pr.month_year, pr.status AS payroll_status
            FROM payslips p
            JOIN payroll_runs pr ON pr.id = p.payroll_run_id
            WHERE p.faculty_id = ?
            ORDER BY p.id DESC
            """, facultyId);
    }

    @GetMapping("/payslips/{id}/download-pdf")
    public ResponseEntity<ByteArrayResource> downloadPayslipPdf(@AuthenticationPrincipal AuthUser user, @PathVariable long id) {
        long facultyId = db.facultyIdFor(user.id());
        Map<String, Object> payslip = db.one("SELECT * FROM payslips WHERE id=? AND faculty_id=?", id, facultyId);
        if (payslip == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Payslip not found");

        Map<String, Object> faculty = db.one("""
            SELECT f.*, des.title AS designation, d.name AS department_name
            FROM faculty f
            JOIN designations des ON des.id = f.designation_id
            JOIN departments d ON d.id = f.department_id
            WHERE f.id = ?
            """, facultyId);

        byte[] pdfBytes = exportService.generatePayslipPdf(faculty, payslip);
        ByteArrayResource res = new ByteArrayResource(pdfBytes);
        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"payslip_" + id + ".pdf\"")
                .contentType(MediaType.APPLICATION_PDF)
                .contentLength(pdfBytes.length)
                .body(res);
    }

    // =========================================================================
    // ASSIGNMENTS MANAGEMENT
    // =========================================================================
    @GetMapping("/assignments")
    public List<Map<String, Object>> getMyAssignments(@AuthenticationPrincipal AuthUser user) {
        long facultyId = db.facultyIdFor(user.id());
        return db.list("""
            SELECT a.*, c.code AS course_code, c.name AS course_name, sec.name AS section_name,
                   (SELECT COUNT(*) FROM assignment_submissions asub WHERE asub.assignment_id = a.id) AS submission_count,
                   (SELECT COUNT(*) FROM course_registrations cr WHERE cr.offering_id = a.offering_id) AS total_students
            FROM assignments a
            JOIN course_offerings co ON co.id = a.offering_id
            JOIN courses c ON c.id = co.course_id
            JOIN sections sec ON sec.id = co.section_id
            WHERE co.faculty_id = ?
            ORDER BY a.due_date DESC
            """, facultyId);
    }

    @PostMapping("/assignments")
    public Map<String, Object> createAssignment(@AuthenticationPrincipal AuthUser user, @RequestBody Map<String, Object> body) {
        long facultyId = db.facultyIdFor(user.id());
        Number offeringIdNum = (Number) body.get("offeringId");
        String title = (String) body.get("title");
        String instructions = (String) body.get("instructions");
        String dueDate = (String) body.get("dueDate");
        Number maxMarksNum = (Number) body.getOrDefault("maxMarks", 100);
        String attachmentUrl = (String) body.get("attachmentUrl");

        if (offeringIdNum == null || title == null || dueDate == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "offeringId, title, and dueDate are required");
        }

        long offeringId = offeringIdNum.longValue();
        Map<String, Object> off = db.one("SELECT id FROM course_offerings WHERE id=? AND faculty_id=?", offeringId, facultyId);
        if (off == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized for this course offering");

        long assignmentId = db.insert("""
            INSERT INTO assignments (offering_id, title, instructions, due_date, max_marks, attachment_url, created_by_faculty_id)
            VALUES (?,?,?,?,?,?,?)
            """, offeringId, title.trim(), instructions == null ? "" : instructions.trim(), dueDate, maxMarksNum.intValue(), attachmentUrl, facultyId);

        // Notify enrolled students
        List<Map<String, Object>> students = db.list("SELECT s.user_id FROM course_registrations cr JOIN students s ON s.id = cr.student_id WHERE cr.offering_id=?", offeringId);
        for (Map<String, Object> st : students) {
            db.notify(((Number) st.get("user_id")).longValue(), "New Assignment: " + title, "A new assignment has been posted. Due: " + dueDate, "ASSIGNMENT", "/student/assignments");
        }

        return Map.of("success", true, "assignmentId", assignmentId);
    }

    @GetMapping("/assignments/{assignmentId}/submissions")
    public List<Map<String, Object>> getSubmissions(@AuthenticationPrincipal AuthUser user, @PathVariable long assignmentId) {
        long facultyId = db.facultyIdFor(user.id());
        Map<String, Object> a = db.one("""
            SELECT a.id FROM assignments a
            JOIN course_offerings co ON co.id = a.offering_id
            WHERE a.id=? AND co.faculty_id=?
            """, assignmentId, facultyId);
        if (a == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Assignment not found or unauthorized");

        return db.list("""
            SELECT asub.id, asub.assignment_id, asub.student_id, asub.submission_text, asub.file_url,
                   asub.submitted_at, asub.marks_obtained, asub.feedback, asub.graded_at,
                   s.full_name AS student_name, s.registration_number, s.roll_number
            FROM assignment_submissions asub
            JOIN students s ON s.id = asub.student_id
            WHERE asub.assignment_id = ?
            ORDER BY asub.submitted_at DESC
            """, assignmentId);
    }

    @PostMapping("/assignments/submissions/{subId}/grade")
    public Map<String, Object> gradeSubmission(@AuthenticationPrincipal AuthUser user, @PathVariable long subId, @RequestBody Map<String, Object> body) {
        long facultyId = db.facultyIdFor(user.id());
        Map<String, Object> sub = db.one("""
            SELECT asub.id, asub.student_id, s.user_id, a.title
            FROM assignment_submissions asub
            JOIN assignments a ON a.id = asub.assignment_id
            JOIN course_offerings co ON co.id = a.offering_id
            JOIN students s ON s.id = asub.student_id
            WHERE asub.id=? AND co.faculty_id=?
            """, subId, facultyId);
        if (sub == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Submission not found or unauthorized");

        Number marksNum = (Number) body.get("marksObtained");
        String feedback = (String) body.get("feedback");

        db.update("""
            UPDATE assignment_submissions
            SET marks_obtained=?, feedback=?, graded_by=?, graded_at=NOW()
            WHERE id=?
            """, marksNum != null ? marksNum.doubleValue() : null, feedback, facultyId, subId);

        // Notify student
        db.notify(((Number) sub.get("user_id")).longValue(), "Assignment Graded: " + sub.get("title"),
                "Your submission was graded: " + marksNum + " marks. Feedback: " + (feedback != null ? feedback : "None"),
                "ASSIGNMENT", "/student/assignments");

        return Map.of("success", true);
    }

    // =========================================================================
    // MARKS ENTRY
    // =========================================================================
    @GetMapping("/courses/{offeringId}/marks")
    public Map<String, Object> getCourseMarks(@AuthenticationPrincipal AuthUser user, @PathVariable long offeringId) {
        long facultyId = db.facultyIdFor(user.id());
        Map<String, Object> off = db.one("""
            SELECT co.id, co.semester_id, c.code AS course_code, c.name AS course_name, c.credits, sec.name AS section_name
            FROM course_offerings co
            JOIN courses c ON c.id = co.course_id
            JOIN sections sec ON sec.id = co.section_id
            WHERE co.id=? AND co.faculty_id=?
            """, offeringId, facultyId);
        if (off == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized for this course offering");

        List<Map<String, Object>> students = db.list("""
            SELECT s.id AS student_id, s.full_name, s.registration_number, s.roll_number,
                   m.id AS mark_id, m.exam_id, m.internal_marks, m.external_marks, m.total_marks,
                   m.grade, m.grade_point, m.is_pass
            FROM course_registrations cr
            JOIN students s ON s.id = cr.student_id
            LEFT JOIN marks m ON m.offering_id = cr.offering_id AND m.student_id = s.id
            WHERE cr.offering_id = ?
            ORDER BY s.registration_number ASC
            """, offeringId);

        List<Map<String, Object>> exams = db.list("SELECT id, exam_type, title FROM exams WHERE semester_id=?", off.get("semester_id"));

        return Map.of("offering", off, "students", students, "exams", exams);
    }

    @PostMapping("/courses/{offeringId}/marks")
    @Transactional
    public Map<String, Object> saveCourseMarks(@AuthenticationPrincipal AuthUser user, @PathVariable long offeringId, @RequestBody Map<String, Object> body) {
        long facultyId = db.facultyIdFor(user.id());
        Map<String, Object> off = db.one("SELECT id, semester_id FROM course_offerings WHERE id=? AND faculty_id=?", offeringId, facultyId);
        if (off == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized for this course offering");

        Number examIdNum = (Number) body.get("examId");
        long examId = examIdNum != null ? examIdNum.longValue() : 1L;
        List<Map<String, Object>> marksList = (List<Map<String, Object>>) body.get("marks");

        if (marksList != null) {
            for (Map<String, Object> entry : marksList) {
                long studentId = ((Number) entry.get("studentId")).longValue();
                double internal = entry.get("internalMarks") != null ? ((Number) entry.get("internalMarks")).doubleValue() : 0.0;
                double external = entry.get("externalMarks") != null ? ((Number) entry.get("externalMarks")).doubleValue() : 0.0;
                double total = internal + external;

                Object[] gInfo = Gpa.grade(total);
                String grade = (String) gInfo[0];
                int gp = ((Number) gInfo[1]).intValue();
                boolean isPass = !"F".equals(grade);

                Map<String, Object> existing = db.one("SELECT id FROM marks WHERE offering_id=? AND student_id=? AND exam_id=?", offeringId, studentId, examId);
                if (existing != null) {
                    db.update("""
                        UPDATE marks
                        SET internal_marks=?, external_marks=?, total_marks=?, grade=?, grade_point=?, is_pass=?, entered_by=?
                        WHERE id=?
                        """, internal, external, total, grade, gp, isPass, facultyId, existing.get("id"));
                } else {
                    db.insert("""
                        INSERT INTO marks (exam_id, offering_id, student_id, internal_marks, external_marks, total_marks, grade, grade_point, is_pass, entered_by)
                        VALUES (?,?,?,?,?,?,?,?,?,?)
                        """, examId, offeringId, studentId, internal, external, total, grade, gp, isPass, facultyId);
                }
            }
        }

        return Map.of("success", true, "count", marksList != null ? marksList.size() : 0);
    }
}
