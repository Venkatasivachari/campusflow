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
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/student")
public class StudentController {
    private final Db db;
    private final ExportService exportService;

    public StudentController(Db db, ExportService exportService) {
        this.db = db;
        this.exportService = exportService;
    }

    // =========================================================================
    // 7.1 AGGREGATED DASHBOARD (Sub-second response)
    // =========================================================================
    @GetMapping("/dashboard")
    public Map<String, Object> getStudentDashboard(@AuthenticationPrincipal AuthUser user) {
        long studentId = db.studentIdFor(user.id());
        int todayDay = LocalDate.now().getDayOfWeek().getValue();

        // Student Profile & Status
        Map<String, Object> profile = db.one("""
            SELECT s.id, s.full_name, s.registration_number, s.current_semester, s.current_year_of_study,
                   s.expected_graduation_year, s.abc_id, p.name AS programme_name, d.name AS department_name,
                   sas.current_sgpa, sas.current_cgpa, sas.attendance_percentage, sas.arrears_count,
                   sas.total_credits_earned, sas.credits_required, sas.at_risk
            FROM students s
            JOIN programmes p ON p.id = s.programme_id
            JOIN departments d ON d.id = s.department_id
            LEFT JOIN student_academic_status sas ON sas.student_id = s.id
            WHERE s.id = ?
            """, studentId);

        // Today's Timetable
        List<Map<String, Object>> todayClasses = db.list("""
            SELECT ts.period_number, ts.start_time, ts.end_time,
                   c.code AS course_code, c.name AS course_name,
                   r.room_number, f.full_name AS faculty_name, ts.is_updated
            FROM course_registrations cr
            JOIN course_offerings co ON co.id = cr.offering_id
            JOIN timetable_slots ts ON ts.offering_id = co.id
            JOIN courses c ON c.id = co.course_id
            JOIN rooms r ON r.id = ts.room_id
            JOIN faculty f ON f.id = co.faculty_id
            JOIN timetable_versions tv ON tv.id = ts.version_id
            WHERE cr.student_id = ? AND ts.day_of_week = ? AND tv.is_active = TRUE
            ORDER BY ts.period_number ASC
            """, studentId, todayDay);

        // Upcoming Assignments
        List<Map<String, Object>> upcomingAssignments = db.list("""
            SELECT a.id, a.title, a.due_date, a.max_marks, c.code AS course_code,
                   asub.marks_obtained, asub.submitted_at
            FROM course_registrations cr
            JOIN assignments a ON a.offering_id = cr.offering_id
            JOIN course_offerings co ON co.id = a.offering_id
            JOIN courses c ON c.id = co.course_id
            LEFT JOIN assignment_submissions asub ON asub.assignment_id = a.id AND asub.student_id = cr.student_id
            WHERE cr.student_id = ? AND a.due_date >= NOW()
            ORDER BY a.due_date ASC
            LIMIT 5
            """, studentId);

        // Fee summary
        Map<String, Object> feeSummary = db.one("""
            SELECT COALESCE(SUM(total_payable), 0) AS total_payable,
                   COALESCE(SUM(total_paid), 0) AS total_paid,
                   COALESCE(SUM(balance_due), 0) AS balance_due
            FROM student_fees
            WHERE student_id = ?
            """, studentId);

        // Arrear alert
        List<Map<String, Object>> activeArrears = db.list("""
            SELECT a.id, a.status, a.attempts_count, c.code AS course_code, c.name AS course_name
            FROM arrears a
            JOIN courses c ON c.id = a.course_id
            WHERE a.student_id = ? AND a.status <> 'CLEARED'
            """, studentId);

        // Latest Announcements
        List<Map<String, Object>> announcements = db.list("""
            SELECT id, title, content, priority, created_at
            FROM announcements
            WHERE target_type IN ('EVERYONE', 'ALL_STUDENTS')
            ORDER BY created_at DESC LIMIT 5
            """);

        // Unread notification count
        long unreadCount = db.count("SELECT COUNT(*) FROM notifications WHERE recipient_id=? AND is_read=FALSE", user.id());

        return Map.of(
            "profile", profile != null ? profile : Map.of(),
            "todayClasses", todayClasses,
            "upcomingAssignments", upcomingAssignments,
            "feeSummary", feeSummary != null ? feeSummary : Map.of(),
            "activeArrears", activeArrears,
            "announcements", announcements,
            "unreadNotifications", unreadCount
        );
    }

    // =========================================================================
    // 7.4 ATTENDANCE HEATMAP & STATS
    // =========================================================================
    @GetMapping("/attendance")
    public Map<String, Object> getStudentAttendance(@AuthenticationPrincipal AuthUser user) {
        long studentId = db.studentIdFor(user.id());

        List<Map<String, Object>> subjectWise = db.list("""
            SELECT c.code, c.name,
                   COUNT(ar.id) AS total_classes,
                   SUM(CASE WHEN ar.status='PRESENT' THEN 1 ELSE 0 END) AS attended_classes,
                   ROUND(SUM(CASE WHEN ar.status='PRESENT' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(ar.id), 0), 1) AS percentage
            FROM course_registrations cr
            JOIN course_offerings co ON co.id = cr.offering_id
            JOIN courses c ON c.id = co.course_id
            LEFT JOIN attendance_sessions asess ON asess.offering_id = co.id
            LEFT JOIN attendance_records ar ON ar.session_id = asess.id AND ar.student_id = cr.student_id
            WHERE cr.student_id = ?
            GROUP BY c.id, c.code, c.name
            """, studentId);

        // Heatmap entries (last 30 days)
        List<Map<String, Object>> heatmap = db.list("""
            SELECT asess.session_date, ar.status, c.code AS course_code
            FROM attendance_records ar
            JOIN attendance_sessions asess ON asess.id = ar.session_id
            JOIN course_offerings co ON co.id = asess.offering_id
            JOIN courses c ON c.id = co.course_id
            WHERE ar.student_id = ? AND asess.session_date >= DATE_SUB(CURDATE(), INTERVAL 60 DAY)
            ORDER BY asess.session_date DESC
            """, studentId);

        return Map.of("subjectWise", subjectWise, "heatmap", heatmap);
    }

    // =========================================================================
    // 7.6 RESULTS & RESULT SHEET PDF
    // =========================================================================
    @GetMapping("/results")
    public Map<String, Object> getStudentResults(@AuthenticationPrincipal AuthUser user) {
        long studentId = db.studentIdFor(user.id());

        List<Map<String, Object>> marks = db.list("""
            SELECT m.id, c.code AS course_code, c.name AS course_name, c.credits,
                   m.internal_marks, m.external_marks, m.total_marks, m.grade, m.grade_point, m.is_pass
            FROM marks m
            JOIN course_offerings co ON co.id = m.offering_id
            JOIN courses c ON c.id = co.course_id
            WHERE m.student_id = ?
            ORDER BY c.code ASC
            """, studentId);

        Map<String, Object> status = db.one("SELECT current_sgpa, current_cgpa FROM student_academic_status WHERE student_id=?", studentId);

        return Map.of("marks", marks, "status", status != null ? status : Map.of());
    }

    @GetMapping("/results/download-pdf")
    public ResponseEntity<ByteArrayResource> downloadResultSheetPdf(@AuthenticationPrincipal AuthUser user) {
        long studentId = db.studentIdFor(user.id());
        Map<String, Object> student = db.one("""
            SELECT s.*, p.name AS programme_name, sas.current_cgpa
            FROM students s
            JOIN programmes p ON p.id = s.programme_id
            LEFT JOIN student_academic_status sas ON sas.student_id = s.id
            WHERE s.id = ?
            """, studentId);

        List<Map<String, Object>> marks = db.list("""
            SELECT c.code AS course_code, c.name AS course_name, c.credits, m.grade, m.is_pass
            FROM marks m
            JOIN course_offerings co ON co.id = m.offering_id
            JOIN courses c ON c.id = co.course_id
            WHERE m.student_id = ?
            """, studentId);

        byte[] pdfBytes = exportService.generateResultSheetPdf(student, marks);
        ByteArrayResource res = new ByteArrayResource(pdfBytes);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"result_sheet.pdf\"")
                .contentType(MediaType.APPLICATION_PDF)
                .contentLength(pdfBytes.length)
                .body(res);
    }

    // =========================================================================
    // 7.8 FEES & RECEIPTS PDF
    // =========================================================================
    @GetMapping("/fees")
    public Map<String, Object> getStudentFees(@AuthenticationPrincipal AuthUser user) {
        long studentId = db.studentIdFor(user.id());

        List<Map<String, Object>> fees = db.list("""
            SELECT sf.*, fs.due_date, fs.total_amount AS structure_amount, fs.late_fine_per_day
            FROM student_fees sf
            JOIN fee_structures fs ON fs.id = sf.fee_structure_id
            WHERE sf.student_id = ?
            """, studentId);

        List<Map<String, Object>> payments = db.list("""
            SELECT fp.*
            FROM fee_payments fp
            JOIN student_fees sf ON sf.id = fp.student_fee_id
            WHERE sf.student_id = ?
            ORDER BY fp.payment_date DESC
            """, studentId);

        return Map.of("fees", fees, "payments", payments);
    }

    @GetMapping("/fees/receipt/{paymentId}/download-pdf")
    public ResponseEntity<ByteArrayResource> downloadFeeReceiptPdf(@AuthenticationPrincipal AuthUser user, @PathVariable long paymentId) {
        long studentId = db.studentIdFor(user.id());
        Map<String, Object> payment = db.one("""
            SELECT fp.* FROM fee_payments fp
            JOIN student_fees sf ON sf.id = fp.student_fee_id
            WHERE fp.id = ? AND sf.student_id = ?
            """, paymentId, studentId);
        if (payment == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Receipt not found");

        Map<String, Object> student = db.one("SELECT full_name, registration_number FROM students WHERE id=?", studentId);

        byte[] pdf = exportService.generateFeeReceiptPdf(payment, student);
        ByteArrayResource res = new ByteArrayResource(pdf);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=\"receipt_" + payment.get("receipt_number") + ".pdf\"")
                .contentType(MediaType.APPLICATION_PDF)
                .contentLength(pdf.length)
                .body(res);
    }

    // =========================================================================
    // 7.7 ARREARS & RE-EXAM REGISTRATION
    // =========================================================================
    @GetMapping("/arrears")
    public List<Map<String, Object>> getStudentArrears(@AuthenticationPrincipal AuthUser user) {
        long studentId = db.studentIdFor(user.id());
        return db.list("""
            SELECT a.id, a.attempts_count, a.status,
                   c.code AS course_code, c.name AS course_name, c.credits,
                   sem.semester_number,
                   ae.id AS arrear_exam_id, ae.exam_date, ae.registration_fee
            FROM arrears a
            JOIN courses c ON c.id = a.course_id
            JOIN semesters sem ON sem.id = a.semester_id
            LEFT JOIN arrear_exams ae ON ae.course_id = c.id AND ae.is_published = TRUE
            WHERE a.student_id = ?
            ORDER BY a.status ASC, a.id DESC
            """, studentId);
    }

    @PostMapping("/arrears/{arrearId}/register-reexam")
    public Map<String, Object> registerForReExam(@AuthenticationPrincipal AuthUser user, @PathVariable long arrearId) {
        long studentId = db.studentIdFor(user.id());
        Map<String, Object> arr = db.one("SELECT id, status FROM arrears WHERE id=? AND student_id=?", arrearId, studentId);
        if (arr == null) throw new ResponseStatusException(HttpStatus.NOT_FOUND, "Arrear record not found.");

        db.update("UPDATE arrears SET status='REGISTERED_FOR_REEXAM', attempts_count=attempts_count+1 WHERE id=?", arrearId);
        return Map.of("success", true, "message", "Successfully registered for upcoming arrear re-exam.");
    }
}
