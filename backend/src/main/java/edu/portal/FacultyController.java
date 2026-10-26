package edu.portal;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/faculty")
public class FacultyController {
    private final Db db;

    public FacultyController(Db db) {
        this.db = db;
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
        // Verify ownership
        Map<String, Object> off = db.one("SELECT id FROM course_offerings WHERE id=? AND faculty_id=?", offeringId, facultyId);
        if (off == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Not authorized for this course offering.");

        // Return student view: Name, Reg No, parent phone, attendance %, performance (NEVER Aadhaar or fee data)
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

        // Check or create session
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
}
