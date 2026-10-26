package edu.portal;

import jakarta.mail.internet.MimeMessage;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.mail.javamail.JavaMailSender;
import org.springframework.mail.javamail.MimeMessageHelper;
import org.springframework.stereotype.Service;

@Service
public class EmailService {
    private static final Logger log = LoggerFactory.getLogger(EmailService.class);

    private final JavaMailSender mailSender;
    private final Db db;
    private final String fromEmail;
    private final String baseUrl;

    public EmailService(JavaMailSender mailSender, Db db,
                        @Value("${app.mail.from:noreply@college.local}") String fromEmail,
                        @Value("${app.base-url:http://localhost:5173}") String baseUrl) {
        this.mailSender = mailSender;
        this.db = db;
        this.fromEmail = fromEmail;
        this.baseUrl = baseUrl;
    }

    public void sendEmail(String to, String subject, String bodyHtml) {
        long outboxId = db.insert("INSERT INTO email_outbox (recipient_email, subject, body_html, status) VALUES (?,?,?,'PENDING')",
                to, subject, bodyHtml);
        try {
            MimeMessage message = mailSender.createMimeMessage();
            MimeMessageHelper helper = new MimeMessageHelper(message, true, "UTF-8");
            helper.setFrom(fromEmail);
            helper.setTo(to);
            helper.setSubject(subject);
            helper.setText(bodyHtml, true);
            mailSender.send(message);

            db.update("UPDATE email_outbox SET status='SENT', sent_at=NOW() WHERE id=?", outboxId);
            log.info("Email successfully sent to: {}", to);
        } catch (Exception e) {
            log.warn("Failed to send real email to {}: {}. Logged in email_outbox.", to, e.getMessage());
            db.update("UPDATE email_outbox SET status='FAILED', last_error=?, retry_count=retry_count+1 WHERE id=?",
                    e.getMessage(), outboxId);
        }
    }

    public void sendWelcomeEmail(String to, String name, String regOrEmpId, String role) {
        String subject = "Welcome to Smart College Portal - Account Credentials";
        String html = """
            <div style="font-family: sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e5e8f0; border-radius: 8px;">
                <h2 style="color: #4F46E5;">Smart College Portal</h2>
                <p>Hello <b>%s</b>,</p>
                <p>Your institutional account has been created successfully.</p>
                <div style="background: #F6F7FB; padding: 16px; border-radius: 6px; margin: 20px 0;">
                    <p style="margin: 4px 0;"><b>Login ID / Registration No:</b> <code style="font-size: 16px;">%s</code></p>
                    <p style="margin: 4px 0;"><b>Role:</b> %s</p>
                    <p style="margin: 4px 0; color: #64708A;">Default password was shared by college administration.</p>
                </div>
                <p>On your first login, you will be required to choose a new password.</p>
                <a href="%s" style="display: inline-block; background: #4F46E5; color: #fff; padding: 10px 20px; border-radius: 6px; text-decoration: none;">Log In to Portal</a>
            </div>
            """.formatted(name, regOrEmpId, role, baseUrl);
        sendEmail(to, subject, html);
    }

    public void sendOtpEmail(String to, String otp, String resetLink) {
        String subject = "Smart College Portal - Password Reset OTP";
        String html = """
            <div style="font-family: sans-serif; max-width: 600px; margin: auto; padding: 20px; border: 1px solid #e5e8f0; border-radius: 8px;">
                <h2 style="color: #4F46E5;">Password Reset Request</h2>
                <p>You requested a password reset for your Smart College Portal account.</p>
                <p>Your 6-digit OTP is:</p>
                <div style="background: #F6F7FB; padding: 16px; border-radius: 6px; text-align: center; margin: 20px 0;">
                    <span style="font-size: 28px; font-weight: bold; letter-spacing: 4px; color: #0B1020;">%s</span>
                </div>
                <p>This code expires in 10 minutes. Alternatively, click the link below:</p>
                <p><a href="%s" style="color: #4F46E5;">Reset Password Link</a></p>
                <p style="color: #64708A; font-size: 12px;">If you did not request this, please ignore this email.</p>
            </div>
            """.formatted(otp, resetLink);
        sendEmail(to, subject, html);
    }
}
