package edu.portal;

import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import org.springframework.http.HttpStatus;
import org.springframework.jdbc.core.JdbcTemplate;
import org.springframework.jdbc.support.GeneratedKeyHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.server.ResponseStatusException;

/**
 * High-performance parameterized database access layer.
 * Enforces prepared statements, enterprise audit logging, and role lookups.
 */
@Component
public class Db {
    public final JdbcTemplate jdbc;

    public Db(JdbcTemplate jdbc) {
        this.jdbc = jdbc;
    }

    public List<Map<String, Object>> list(String sql, Object... args) {
        return jdbc.queryForList(sql, args).stream().map(m -> (Map<String, Object>) new LinkedHashMap<>(m)).toList();
    }

    public Map<String, Object> one(String sql, Object... args) {
        List<Map<String, Object>> rows = list(sql, args);
        return rows.isEmpty() ? null : rows.get(0);
    }

    public long count(String sql, Object... args) {
        Long n = jdbc.queryForObject(sql, Long.class, args);
        return n == null ? 0 : n;
    }

    public long insert(String sql, Object... args) {
        GeneratedKeyHolder kh = new GeneratedKeyHolder();
        jdbc.update(con -> {
            var ps = con.prepareStatement(sql, new String[] {"id"});
            for (int i = 0; i < args.length; i++) ps.setObject(i + 1, args[i]);
            return ps;
        }, kh);
        Number key = kh.getKey();
        return key == null ? -1 : key.longValue();
    }

    public int update(String sql, Object... args) {
        return jdbc.update(sql, args);
    }

    public long studentIdFor(long userId) {
        Long id = jdbc.query("SELECT id FROM students WHERE user_id=? AND deleted_at IS NULL", rs -> rs.next() ? rs.getLong(1) : null, userId);
        if (id == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No active student profile found for this account");
        return id;
    }

    public long facultyIdFor(long userId) {
        Long id = jdbc.query("SELECT id FROM faculty WHERE user_id=? AND deleted_at IS NULL", rs -> rs.next() ? rs.getLong(1) : null, userId);
        if (id == null) throw new ResponseStatusException(HttpStatus.FORBIDDEN, "No active faculty profile found for this account");
        return id;
    }

    public void audit(Long userId, String action, String entityName, String entityId, String oldValue, String newValue, String ipAddress) {
        jdbc.update("INSERT INTO audit_log (user_id, action, entity_name, entity_id, old_value, new_value, ip_address) VALUES (?,?,?,?,?,?,?)",
                userId, action, entityName, entityId, oldValue, newValue, ipAddress == null ? "127.0.0.1" : ipAddress);
    }

    public void notify(Long recipientId, String title, String message, String type, String linkUrl) {
        jdbc.update("INSERT INTO notifications (recipient_id, title, message, type, link_url) VALUES (?,?,?,?,?)",
                recipientId, title, message, type == null ? "GENERAL" : type, linkUrl);
    }

    public void logLogin(String identifier, String role, String status, String reason, String ipAddress, String userAgent) {
        jdbc.update("INSERT INTO login_log (identifier, role, status, failure_reason, ip_address, user_agent) VALUES (?,?,?,?,?,?)",
                identifier, role, status, reason, ipAddress == null ? "127.0.0.1" : ipAddress, userAgent);
    }

    public void logBlocked(Long userId, Long blockedByUserId, String action, String reason, String ipAddress) {
        jdbc.update("INSERT INTO blocked_account_register (user_id, blocked_by_user_id, action, reason, ip_address) VALUES (?,?,?,?,?)",
                userId, blockedByUserId, action, reason, ipAddress == null ? "127.0.0.1" : ipAddress);
    }
}
