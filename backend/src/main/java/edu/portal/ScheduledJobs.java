package edu.portal;

import java.util.List;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

@Component
public class ScheduledJobs {
    private static final Logger log = LoggerFactory.getLogger(ScheduledJobs.class);
    private final Db db;

    public ScheduledJobs(Db db) {
        this.db = db;
    }

    // Daily token & lockout cleanup at 02:00
    @Scheduled(cron = "0 0 2 * * *")
    public void cleanupTokens() {
        int tokens = db.update("DELETE FROM password_reset_tokens WHERE expires_at < NOW() OR used_at IS NOT NULL");
        int locks = db.update("UPDATE users SET lockout_until=NULL WHERE lockout_until < NOW()");
        log.info("Scheduled cleanup: purged {} expired tokens, cleared {} expired account lockouts.", tokens, locks);
    }

    // Daily low-attendance alert scan at 08:00
    @Scheduled(cron = "0 0 8 * * *")
    public void checkLowAttendance() {
        List<Map<String, Object>> low = db.list("""
            SELECT s.user_id, s.full_name, sas.attendance_percentage
            FROM students s
            JOIN student_academic_status sas ON sas.student_id = s.id
            WHERE sas.attendance_percentage < 75.0 AND s.deleted_at IS NULL
            """);

        for (Map<String, Object> row : low) {
            long uid = ((Number) row.get("user_id")).longValue();
            double att = ((Number) row.get("attendance_percentage")).doubleValue();
            db.notify(uid, "Low Attendance Warning",
                    String.format("Your current attendance is %.1f%%, which is below the mandatory 75%% threshold.", att),
                    "WARNING", "/attendance");
        }
        log.info("Low attendance scan complete: alerted {} students.", low.size());
    }

    // Daily assignment due scan at 09:00
    @Scheduled(cron = "0 0 9 * * *")
    public void checkUpcomingAssignments() {
        List<Map<String, Object>> dueSoon = db.list("""
            SELECT a.id, a.title, cr.student_id, s.user_id
            FROM assignments a
            JOIN course_offerings co ON co.id = a.offering_id
            JOIN course_registrations cr ON cr.offering_id = co.id
            JOIN students s ON s.id = cr.student_id
            LEFT JOIN assignment_submissions asub ON asub.assignment_id = a.id AND asub.student_id = cr.student_id
            WHERE a.due_date BETWEEN NOW() AND DATE_ADD(NOW(), INTERVAL 24 HOUR)
            AND asub.id IS NULL
            """);

        for (Map<String, Object> row : dueSoon) {
            long uid = ((Number) row.get("user_id")).longValue();
            String title = (String) row.get("title");
            db.notify(uid, "Assignment Due in 24 Hours",
                    "Assignment '" + title + "' is due tomorrow. Please submit before deadline.",
                    "REMINDER", "/assignments");
        }
    }
}
