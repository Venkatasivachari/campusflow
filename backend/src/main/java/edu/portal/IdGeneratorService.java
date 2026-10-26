package edu.portal;

import java.time.LocalDate;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

/**
 * Generates atomic, collision-free registration numbers and employee IDs
 * using database row locking on the id_counters table.
 */
@Service
public class IdGeneratorService {
    private final Db db;

    public IdGeneratorService(Db db) {
        this.db = db;
    }

    @Transactional
    public synchronized String nextStudentId(String deptCode) {
        String code = deptCode.trim().toUpperCase();
        String yearPrefix = String.valueOf(LocalDate.now().getYear()).substring(2); // e.g. "25" or "26"
        String key = "STUDENT_" + yearPrefix + "_" + code;

        // Ensure row exists
        db.jdbc.update("INSERT IGNORE INTO id_counters (counter_key, current_val, year_prefix) VALUES (?, 0, ?)", key, yearPrefix);

        // Atomic lock and increment
        Long val = db.jdbc.queryForObject("SELECT current_val FROM id_counters WHERE counter_key = ? FOR UPDATE", Long.class, key);
        long nextVal = (val == null ? 0 : val) + 1;
        db.jdbc.update("UPDATE id_counters SET current_val = ? WHERE counter_key = ?", nextVal, key);

        return String.format("%s%s%04d", yearPrefix, code, nextVal);
    }

    @Transactional
    public synchronized String nextFacultyId() {
        String yearPrefix = String.valueOf(LocalDate.now().getYear()).substring(2);
        String key = "FACULTY_" + yearPrefix;

        db.jdbc.update("INSERT IGNORE INTO id_counters (counter_key, current_val, year_prefix) VALUES (?, 0, ?)", key, yearPrefix);

        Long val = db.jdbc.queryForObject("SELECT current_val FROM id_counters WHERE counter_key = ? FOR UPDATE", Long.class, key);
        long nextVal = (val == null ? 0 : val) + 1;
        db.jdbc.update("UPDATE id_counters SET current_val = ? WHERE counter_key = ?", nextVal, key);

        return String.format("FAC%s%03d", yearPrefix, nextVal);
    }

    @Transactional
    public synchronized String nextReceiptNumber() {
        String prefix = String.format("%02d%02d", LocalDate.now().getYear() % 100, LocalDate.now().getMonthValue());
        String key = "RECEIPT_" + prefix;

        db.jdbc.update("INSERT IGNORE INTO id_counters (counter_key, current_val, year_prefix) VALUES (?, 0, ?)", key, prefix);

        Long val = db.jdbc.queryForObject("SELECT current_val FROM id_counters WHERE counter_key = ? FOR UPDATE", Long.class, key);
        long nextVal = (val == null ? 0 : val) + 1;
        db.jdbc.update("UPDATE id_counters SET current_val = ? WHERE counter_key = ?", nextVal, key);

        return String.format("RCP%s%05d", prefix, nextVal);
    }
}
