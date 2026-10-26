package edu.portal;

import java.nio.charset.StandardCharsets;
import java.security.MessageDigest;
import java.security.SecureRandom;
import java.util.Base64;
import javax.crypto.Cipher;
import javax.crypto.SecretKey;
import javax.crypto.spec.GCMParameterSpec;
import javax.crypto.spec.SecretKeySpec;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;

/**
 * Enterprise AES-256-GCM encryption service for sensitive PII (Aadhaar, bank account numbers).
 * Includes salted SHA-256 hashing for duplicate checks and standard masking.
 */
@Service
public class AesService {
    private static final int GCM_TAG_LENGTH = 128; // bits
    private static final int IV_LENGTH = 12; // bytes
    private final SecretKey secretKey;
    private final SecureRandom random = new SecureRandom();

    public AesService(@Value("${app.aes.key}") String base64Key) {
        byte[] decoded = Base64.getDecoder().decode(base64Key.trim());
        if (decoded.length != 32) {
            // If key is not 32 bytes, derive 32-byte key via SHA-256
            try {
                decoded = MessageDigest.getInstance("SHA-256").digest(base64Key.getBytes(StandardCharsets.UTF_8));
            } catch (Exception e) {
                throw new IllegalStateException("Could not initialize AES key", e);
            }
        }
        this.secretKey = new SecretKeySpec(decoded, "AES");
    }

    public String encrypt(String plainText) {
        if (plainText == null || plainText.isBlank()) return null;
        try {
            byte[] iv = new byte[IV_LENGTH];
            random.nextBytes(iv);
            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.ENCRYPT_MODE, secretKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            byte[] cipherText = cipher.doFinal(plainText.getBytes(StandardCharsets.UTF_8));

            byte[] combined = new byte[iv.length + cipherText.length];
            System.arraycopy(iv, 0, combined, 0, iv.length);
            System.arraycopy(cipherText, 0, combined, iv.length, cipherText.length);
            return Base64.getEncoder().encodeToString(combined);
        } catch (Exception e) {
            throw new RuntimeException("Encryption error", e);
        }
    }

    public String decrypt(String cipherTextBase64) {
        if (cipherTextBase64 == null || cipherTextBase64.isBlank()) return null;
        try {
            byte[] combined = Base64.getDecoder().decode(cipherTextBase64);
            if (combined.length < IV_LENGTH) return null;
            byte[] iv = new byte[IV_LENGTH];
            byte[] cipherText = new byte[combined.length - IV_LENGTH];
            System.arraycopy(combined, 0, iv, 0, IV_LENGTH);
            System.arraycopy(combined, IV_LENGTH, cipherText, 0, cipherText.length);

            Cipher cipher = Cipher.getInstance("AES/GCM/NoPadding");
            cipher.init(Cipher.DECRYPT_MODE, secretKey, new GCMParameterSpec(GCM_TAG_LENGTH, iv));
            byte[] plainBytes = cipher.doFinal(cipherText);
            return new String(plainBytes, StandardCharsets.UTF_8);
        } catch (Exception e) {
            return null; // Return null on decryption failure to preserve safety
        }
    }

    public String hashAadhaar(String aadhaar) {
        if (aadhaar == null || aadhaar.isBlank()) return null;
        String clean = aadhaar.replaceAll("\\s+", "");
        try {
            MessageDigest md = MessageDigest.getInstance("SHA-256");
            byte[] hash = md.digest(("aadhaar-salt-2026-" + clean).getBytes(StandardCharsets.UTF_8));
            StringBuilder sb = new StringBuilder();
            for (byte b : hash) sb.append(String.format("%02x", b));
            return sb.toString();
        } catch (Exception e) {
            throw new RuntimeException("Hash error", e);
        }
    }

    public String maskAadhaar(String aadhaar) {
        if (aadhaar == null || aadhaar.isBlank()) return "";
        String clean = aadhaar.replaceAll("\\s+", "");
        if (clean.length() < 4) return "XXXX";
        String last4 = clean.substring(clean.length() - 4);
        return "XXXX XXXX " + last4;
    }
}
