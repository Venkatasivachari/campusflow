package edu.portal;

import java.util.List;
import java.util.Map;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@RequestMapping("/api/notifications")
public class NotificationController {
    private final Db db;

    public NotificationController(Db db) {
        this.db = db;
    }

    @GetMapping
    public Map<String, Object> getMyNotifications(@AuthenticationPrincipal AuthUser user) {
        List<Map<String, Object>> notifs = db.list("""
            SELECT id, title, message, type, link_url, is_read, created_at
            FROM notifications
            WHERE recipient_id = ?
            ORDER BY created_at DESC
            LIMIT 50
            """, user.id());

        long unreadCount = db.count("SELECT COUNT(*) FROM notifications WHERE recipient_id = ? AND is_read = FALSE", user.id());

        return Map.of("notifications", notifs, "unreadCount", unreadCount);
    }

    @PostMapping("/{id}/mark-read")
    public Map<String, Object> markAsRead(@AuthenticationPrincipal AuthUser user, @PathVariable long id) {
        db.update("UPDATE notifications SET is_read = TRUE, read_at = NOW() WHERE id = ? AND recipient_id = ?", id, user.id());
        return Map.of("success", true);
    }

    @PostMapping("/mark-all-read")
    public Map<String, Object> markAllAsRead(@AuthenticationPrincipal AuthUser user) {
        db.update("UPDATE notifications SET is_read = TRUE, read_at = NOW() WHERE recipient_id = ? AND is_read = FALSE", user.id());
        return Map.of("success", true);
    }
}

