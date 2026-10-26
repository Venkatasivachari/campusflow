package edu.portal;

import jakarta.servlet.http.HttpServletRequest;
import java.time.Instant;
import java.util.LinkedHashMap;
import java.util.Map;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.dao.DataIntegrityViolationException;
import org.springframework.dao.DuplicateKeyException;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.http.converter.HttpMessageNotReadableException;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.web.bind.MethodArgumentNotValidException;
import org.springframework.web.bind.annotation.ExceptionHandler;
import org.springframework.web.bind.annotation.RestControllerAdvice;
import org.springframework.web.server.ResponseStatusException;

/** Consistent error envelope: {timestamp, status, error, message, path}. */
@RestControllerAdvice
class Errors {
    private static final Logger log = LoggerFactory.getLogger(Errors.class);

    private ResponseEntity<Map<String, Object>> body(HttpStatus s, String msg, HttpServletRequest req) {
        Map<String, Object> m = new LinkedHashMap<>();
        m.put("timestamp", Instant.now().toString());
        m.put("status", s.value());
        m.put("error", s.getReasonPhrase());
        m.put("message", msg);
        m.put("path", req.getRequestURI());
        return ResponseEntity.status(s).body(m);
    }

    @ExceptionHandler(ResponseStatusException.class)
    ResponseEntity<Map<String, Object>> rse(ResponseStatusException e, HttpServletRequest r) {
        return body(HttpStatus.valueOf(e.getStatusCode().value()), e.getReason(), r);
    }

    @ExceptionHandler(MethodArgumentNotValidException.class)
    ResponseEntity<Map<String, Object>> invalid(MethodArgumentNotValidException e, HttpServletRequest r) {
        String msg = e.getBindingResult().getFieldErrors().stream()
                .map(f -> f.getField() + " " + f.getDefaultMessage()).findFirst().orElse("Invalid request");
        return body(HttpStatus.BAD_REQUEST, msg, r);
    }

    @ExceptionHandler(HttpMessageNotReadableException.class)
    ResponseEntity<Map<String, Object>> unreadable(HttpMessageNotReadableException e, HttpServletRequest r) {
        return body(HttpStatus.BAD_REQUEST, "Malformed request body", r);
    }

    @ExceptionHandler({DuplicateKeyException.class, DataIntegrityViolationException.class})
    ResponseEntity<Map<String, Object>> conflict(Exception e, HttpServletRequest r) {
        return body(HttpStatus.CONFLICT, "That record already exists or refers to something that does not exist", r);
    }

    @ExceptionHandler(AccessDeniedException.class)
    ResponseEntity<Map<String, Object>> denied(AccessDeniedException e, HttpServletRequest r) {
        return body(HttpStatus.FORBIDDEN, "Access denied", r);
    }

    @ExceptionHandler(Exception.class)
    ResponseEntity<Map<String, Object>> other(Exception e, HttpServletRequest r) {
        log.error("Unhandled error on {}", r.getRequestURI(), e);
        return body(HttpStatus.INTERNAL_SERVER_ERROR, "Something went wrong", r);
    }
}
