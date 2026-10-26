package edu.portal;

import jakarta.servlet.http.HttpServletRequest;
import java.security.SecureRandom;
import java.time.LocalDateTime;
import java.util.Map;
import java.util.UUID;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.annotation.AuthenticationPrincipal;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import org.springframework.web.server.ResponseStatusException;

@RestController
@RequestMapping("/api/auth")
public class AuthController {
    private final Db db;
    private final PasswordEncoder enc;
    private final JwtService jwt;
    private final EmailService email;
    private final String defaultPassword;

    public AuthController(Db db, PasswordEncoder enc, JwtService jwt, EmailService email,
                          @Value("${app.default-password:ChangeMe@123}") String defaultPassword) {
        this.db = db;
        this.enc = enc;
        this.jwt = jwt;
        this.email = email;
        this.defaultPassword = defaultPassword;
    }

    public record LoginReq(String identifier, String password) {}
    public record LoginRes(String token, String refreshToken, long id, String email, String role, String name, String code, boolean mustChangePassword) {}
    public record ChangePwdReq(String currentPassword, String newPassword) {}
    public record ForgotReq(String identifier) {}
    public record ResetReq(String identifier, String otp, String newPassword) {}

    @PostMapping("/login/admin")
    public LoginRes loginAdmin(@RequestBody LoginReq req, HttpServletRequest httpReq) {
        return handleLogin(req, "ADMIN", httpReq);
    }

    @PostMapping("/login/faculty")
    public LoginRes loginFaculty(@RequestBody LoginReq req, HttpServletRequest httpReq) {
        return handleLogin(req, "FACULTY", httpReq);
    }

    @PostMapping("/login/student")
    public LoginRes loginStudent(@RequestBody LoginReq req, HttpServletRequest httpReq) {
        return handleLogin(req, "STUDENT", httpReq);
    }

    private LoginRes handleLogin(LoginReq req, String targetRole, HttpServletRequest httpReq) {
        String ip = httpReq.getRemoteAddr();
        String ua = httpReq.getHeader("User-Agent");
        if (req == null || req.identifier() == null || req.password() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Missing credentials");
        }

        String idf = req.identifier().trim();
        Map<String, Object> u = db.one("SELECT * FROM users WHERE (email=? OR id IN (SELECT user_id FROM students WHERE registration_number=?)) AND deleted_at IS NULL", idf, idf);
        if (u == null) {
            // Also check faculty employee_id
            u = db.one("SELECT u.* FROM users u JOIN faculty f ON f.user_id=u.id WHERE f.employee_id=? AND u.deleted_at IS NULL", idf);
        }

        if (u == null) {
            db.logLogin(idf, targetRole, "FAILED", "User not found", ip, ua);
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid identifier or password");
        }

        long uid = ((Number) u.get("id")).longValue();
        String role = (String) u.get("role");
        boolean isBlocked = Boolean.TRUE.equals(u.get("is_blocked"));
        int failedAttempts = ((Number) u.getOrDefault("failed_login_count", 0)).intValue();
        Object lockoutObj = u.get("lockout_until");

        if (isBlocked) {
            db.logLogin(idf, role, "FAILED", "Account blocked", ip, ua);
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Account is blocked by administration. Please contact support.");
        }

        if (lockoutObj != null) {
            LocalDateTime lockout = ((java.sql.Timestamp) lockoutObj).toLocalDateTime();
            if (lockout.isAfter(LocalDateTime.now())) {
                db.logLogin(idf, role, "FAILED", "Account locked out", ip, ua);
                throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Account locked due to 5 consecutive failed logins. Try again in 15 minutes.");
            }
        }

        // Verify password
        if (!enc.matches(req.password(), (String) u.get("password_hash"))) {
            int newFailed = failedAttempts + 1;
            if (newFailed >= 5) {
                db.update("UPDATE users SET failed_login_count=0, lockout_until=DATE_ADD(NOW(), INTERVAL 15 MINUTE) WHERE id=?", uid);
                db.logBlocked(uid, null, "LOCKED", "5 consecutive failed login attempts", ip);
                db.logLogin(idf, role, "FAILED", "5 failed attempts - account locked", ip, ua);
                throw new ResponseStatusException(HttpStatus.TOO_MANY_REQUESTS, "Too many failed attempts. Account locked for 15 minutes.");
            } else {
                db.update("UPDATE users SET failed_login_count=? WHERE id=?", newFailed, uid);
                db.logLogin(idf, role, "FAILED", "Bad password (attempt " + newFailed + "/5)", ip, ua);
                throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid identifier or password (" + (5 - newFailed) + " attempts remaining)");
            }
        }

        // Enforce portal role compatibility
        if ("ADMIN".equals(targetRole) && !role.contains("ADMIN") && !role.equals("ACCOUNTS") && !role.equals("EXAM_CELL")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Account is not authorized for the Admin Portal. Please use the appropriate login page.");
        }
        if ("FACULTY".equals(targetRole) && !role.equals("FACULTY") && !role.contains("ADMIN")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Account is not authorized for the Faculty Portal.");
        }
        if ("STUDENT".equals(targetRole) && !role.equals("STUDENT")) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Account is not authorized for the Student Portal.");
        }

        // Reset failed logins and update last login
        db.update("UPDATE users SET failed_login_count=0, lockout_until=NULL, last_login_at=NOW() WHERE id=?", uid);
        db.logLogin(idf, role, "SUCCESS", null, ip, ua);

        boolean mustChangePassword = Boolean.TRUE.equals(u.get("must_change_password"));
        String emailStr = (String) u.get("email");
        String token = jwt.issueAccessToken(uid, emailStr, role, mustChangePassword);
        String refreshToken = jwt.issueRefreshToken(uid, emailStr);

        // Fetch name and display code
        String name = "User";
        String code = idf;
        if ("STUDENT".equals(role)) {
            Map<String, Object> st = db.one("SELECT full_name, registration_number FROM students WHERE user_id=?", uid);
            if (st != null) {
                name = (String) st.get("full_name");
                code = (String) st.get("registration_number");
            }
        } else if ("FACULTY".equals(role)) {
            Map<String, Object> f = db.one("SELECT full_name, employee_id FROM faculty WHERE user_id=?", uid);
            if (f != null) {
                name = (String) f.get("full_name");
                code = (String) f.get("employee_id");
            }
        } else {
            name = "Administrator";
            code = "ADMIN";
        }

        return new LoginRes(token, refreshToken, uid, emailStr, role, name, code, mustChangePassword);
    }

    @PostMapping("/set-initial-password")
    public Map<String, Object> setInitialPassword(@AuthenticationPrincipal AuthUser user, @RequestBody Map<String, String> body) {
        String newPassword = body.get("newPassword");
        if (newPassword == null || !PasswordPolicy.isValid(newPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password must be at least 8 characters and include uppercase, lowercase, digit, and a special character.");
        }
        if (newPassword.equals(defaultPassword)) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "New password cannot equal the default password.");
        }

        db.update("UPDATE users SET password_hash=?, must_change_password=FALSE WHERE id=?", enc.encode(newPassword), user.id());
        db.audit(user.id(), "CHANGE_PASSWORD", "users", String.valueOf(user.id()), null, "Changed initial default password", null);

        String refreshedToken = jwt.issueAccessToken(user.id(), user.email(), user.role(), false);
        return Map.of("success", true, "token", refreshedToken);
    }

    @PostMapping("/change-password")
    public Map<String, Object> changePassword(@AuthenticationPrincipal AuthUser user, @RequestBody ChangePwdReq req) {
        Map<String, Object> u = db.one("SELECT password_hash FROM users WHERE id=?", user.id());
        if (u == null || !enc.matches(req.currentPassword(), (String) u.get("password_hash"))) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Current password does not match.");
        }
        if (!PasswordPolicy.isValid(req.newPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "New password does not meet security requirements.");
        }

        db.update("UPDATE users SET password_hash=?, must_change_password=FALSE WHERE id=?", enc.encode(req.newPassword()), user.id());
        db.audit(user.id(), "CHANGE_PASSWORD", "users", String.valueOf(user.id()), null, "Password changed from profile menu", null);
        return Map.of("success", true, "message", "Password updated successfully.");
    }

    @PostMapping("/forgot-password/request")
    public Map<String, Object> forgotPasswordRequest(@RequestBody ForgotReq req) {
        if (req == null || req.identifier() == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Identifier is required.");
        }
        String idf = req.identifier().trim();
        Map<String, Object> u = db.one("SELECT id, email FROM users WHERE (email=? OR id IN (SELECT user_id FROM students WHERE registration_number=?)) AND deleted_at IS NULL", idf, idf);
        if (u == null) {
            u = db.one("SELECT u.id, u.email FROM users u JOIN faculty f ON f.user_id=u.id WHERE f.employee_id=? AND u.deleted_at IS NULL", idf);
        }

        // Even if user does not exist, return generic success to prevent enumeration
        if (u != null) {
            long uid = ((Number) u.get("id")).longValue();
            String userEmail = (String) u.get("email");
            String otp = String.format("%06d", new SecureRandom().nextInt(1_000_000));
            String token = UUID.randomUUID().toString();

            db.update("DELETE FROM password_reset_tokens WHERE user_id=?", uid);
            db.update("INSERT INTO password_reset_tokens (user_id, token, otp, expires_at) VALUES (?,?,?, DATE_ADD(NOW(), INTERVAL 10 MINUTE))",
                    uid, token, otp);

            email.sendOtpEmail(userEmail, otp, "http://localhost:5173/reset-password?token=" + token);
        }

        return Map.of("success", true, "message", "If an account matches that identifier, an OTP has been sent to the registered email address.");
    }

    @PostMapping("/forgot-password/reset")
    public Map<String, Object> resetPassword(@RequestBody ResetReq req) {
        if (req == null || req.newPassword() == null || !PasswordPolicy.isValid(req.newPassword())) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Password must satisfy policy (8+ chars, upper, lower, number, symbol).");
        }

        Map<String, Object> tokenRow = db.one("""
            SELECT prt.id, prt.user_id FROM password_reset_tokens prt
            JOIN users u ON u.id = prt.user_id
            WHERE prt.otp = ? AND prt.expires_at > NOW() AND prt.used_at IS NULL
            AND (u.email = ? OR u.id IN (SELECT user_id FROM students WHERE registration_number=?))
            """, req.otp().trim(), req.identifier().trim(), req.identifier().trim());

        if (tokenRow == null) {
            throw new ResponseStatusException(HttpStatus.BAD_REQUEST, "Invalid or expired OTP.");
        }

        long tokenId = ((Number) tokenRow.get("id")).longValue();
        long uid = ((Number) tokenRow.get("user_id")).longValue();

        db.update("UPDATE users SET password_hash=?, must_change_password=FALSE WHERE id=?", enc.encode(req.newPassword()), uid);
        db.update("UPDATE password_reset_tokens SET used_at=NOW() WHERE id=?", tokenId);
        db.audit(uid, "RESET_PASSWORD", "users", String.valueOf(uid), null, "Password reset via OTP", null);

        return Map.of("success", true, "message", "Password has been successfully reset. Please log in.");
    }

    @GetMapping("/me")
    public Map<String, Object> getMe(@AuthenticationPrincipal AuthUser user) {
        Map<String, Object> res = db.one("SELECT id, email, role, must_change_password, is_blocked, last_login_at FROM users WHERE id=?", user.id());
        if ("STUDENT".equals(user.role())) {
            Map<String, Object> st = db.one("""
                SELECT s.*, p.name AS programme_name, d.name AS department_name
                FROM students s
                JOIN programmes p ON p.id = s.programme_id
                JOIN departments d ON d.id = s.department_id
                WHERE s.user_id = ?
                """, user.id());
            return Map.of("user", res, "profile", st != null ? st : Map.of());
        } else if ("FACULTY".equals(user.role())) {
            Map<String, Object> fac = db.one("""
                SELECT f.*, des.title AS designation, d.name AS department_name
                FROM faculty f
                JOIN designations des ON des.id = f.designation_id
                JOIN departments d ON d.id = f.department_id
                WHERE f.user_id = ?
                """, user.id());
            return Map.of("user", res, "profile", fac != null ? fac : Map.of());
        }
        return Map.of("user", res, "profile", Map.of("name", "Administrator"));
    }
}
