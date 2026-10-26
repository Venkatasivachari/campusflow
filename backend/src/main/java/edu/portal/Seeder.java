package edu.portal;

import java.time.DayOfWeek;
import java.time.LocalDate;
import java.util.List;
import java.util.Random;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.boot.ApplicationArguments;
import org.springframework.boot.ApplicationRunner;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Component;

@Component
public class Seeder implements ApplicationRunner {
    private static final Logger log = LoggerFactory.getLogger(Seeder.class);
    public static final String DEMO_PASSWORD = "Demo@12345";

    private final Db db;
    private final PasswordEncoder enc;
    private final AesService aes;
    private final String adminEmail;
    private final String adminPassword;
    private final boolean seedDemo;

    public Seeder(Db db, PasswordEncoder enc, AesService aes,
                  @Value("${app.admin.email:admin@college.local}") String adminEmail,
                  @Value("${app.admin.password:Admin@12345}") String adminPassword,
                  @Value("${app.seed-demo:true}") boolean seedDemo) {
        this.db = db;
        this.enc = enc;
        this.aes = aes;
        this.adminEmail = adminEmail.trim().toLowerCase();
        this.adminPassword = adminPassword;
        this.seedDemo = seedDemo;
    }

    @Override
    public void run(ApplicationArguments args) {
        // 1. Ensure Super Admin Account
        if (db.count("SELECT COUNT(*) FROM users WHERE role='ADMIN'") == 0) {
            long uid = db.insert("INSERT INTO users (email, password_hash, role, must_change_password) VALUES (?,?,'ADMIN',FALSE)",
                    adminEmail, enc.encode(adminPassword));
            log.info("Created primary administrator account: {}", adminEmail);
        }

        // 2. Seed Realistic Demo Data if requested and not yet seeded
        if (seedDemo && db.count("SELECT COUNT(*) FROM students") == 0) {
            seedRealisticData();
        }
    }

    private void seedRealisticData() {
        log.info("Seeding realistic sample data across all modules...");
        String hash = enc.encode(DEMO_PASSWORD);

        // Academic references
        long deptId = 1; // CSE
        long progId = 1; // BTech CSE
        long ayId = 1; // 2025-2026

        long batchId = db.insert("INSERT INTO batches (programme_id, admission_year, expected_graduation_year) VALUES (?, 2025, 2029)", progId);
        long semId = db.insert("INSERT INTO semesters (batch_id, semester_number, academic_year_id, start_date, end_date, is_current) VALUES (?,1,?, '2025-08-01', '2025-12-15', TRUE)", batchId, ayId);
        long secId = db.insert("INSERT INTO sections (semester_id, name, capacity) VALUES (?,'A', 60)", semId);

        // Rooms
        long room1 = db.insert("INSERT INTO rooms (room_number, building, capacity, room_type) VALUES ('L101', 'Science Block', 60, 'LECTURE_HALL')");
        long room2 = db.insert("INSERT INTO rooms (room_number, building, capacity, room_type) VALUES ('LAB-CS1', 'Tech Center', 40, 'COMPUTER_LAB')");

        // Faculty
        String[][] facultyData = {
            {"Dr. Anita Rao", "teacher1@college.local", "FAC25001", "Professor", "9876543210"},
            {"Prof. Rahul Mehta", "teacher2@college.local", "FAC25002", "Associate Professor", "9876543211"},
            {"Dr. Vikram Sethi", "teacher3@college.local", "FAC25003", "Assistant Professor", "9876543212"}
        };

        long[] facIds = new long[3];
        for (int i = 0; i < facultyData.length; i++) {
            long uid = db.insert("INSERT INTO users (email, password_hash, role, must_change_password) VALUES (?,?,'FACULTY',FALSE)", facultyData[i][1], hash);
            long desigId = i == 0 ? 1 : i == 1 ? 2 : 3;
            facIds[i] = db.insert("""
                INSERT INTO faculty (user_id, employee_id, full_name, email, phone, designation_id, department_id, qualification, experience_years, joining_date)
                VALUES (?,?,?,?,?,?,?,?,5,CURDATE())
                """, uid, facultyData[i][2], facultyData[i][0], facultyData[i][1], facultyData[i][4], desigId, deptId, "Ph.D. in Computer Science");

            // Seed faculty salary
            double basic = 75000.00 + i * 15000;
            double hra = basic * 0.20;
            double da = basic * 0.15;
            double allow = 5000.00;
            double ded = basic * 0.17;
            double net = basic + hra + da + allow - ded;
            db.insert("""
                INSERT INTO faculty_salary (faculty_id, basic_pay, hra, da, allowances, pf, tax, net_salary, effective_date)
                VALUES (?,?,?,?,?,?,?,?,CURDATE())
                """, facIds[i], basic, hra, da, allow, basic * 0.12, basic * 0.05, net);
        }

        // Courses
        String[][] courses = {
            {"CS101", "Programming Fundamentals", "4", "THEORY"},
            {"CS102", "Data Structures and Algorithms", "4", "THEORY"},
            {"CS103", "Database Management Systems", "3", "THEORY"},
            {"CS104", "Programming Lab", "2", "LAB"}
        };

        long[] courseIds = new long[courses.length];
        long[] offeringIds = new long[courses.length];
        for (int i = 0; i < courses.length; i++) {
            courseIds[i] = db.insert("INSERT INTO courses (code, name, credits, course_type, semester_number, department_id) VALUES (?,?,?,?,?,?)",
                    courses[i][0], courses[i][1], Integer.parseInt(courses[i][2]), courses[i][3], 1, deptId);
            long assignedFaculty = facIds[i % facIds.length];
            offeringIds[i] = db.insert("INSERT INTO course_offerings (course_id, semester_id, section_id, faculty_id) VALUES (?,?,?,?)",
                    courseIds[i], semId, secId, assignedFaculty);
        }

        // Timetable version & slots (Mon to Fri)
        long tvId = db.insert("INSERT INTO timetable_versions (section_id, version_number, effective_from, is_active) VALUES (?, 1, CURDATE(), TRUE)", secId);
        for (int day = 1; day <= 5; day++) {
            for (int p = 1; p <= 4; p++) {
                long offId = offeringIds[(day + p) % offeringIds.length];
                long roomId = (p == 4) ? room2 : room1;
                String st = p == 1 ? "09:00:00" : p == 2 ? "10:00:00" : p == 3 ? "11:15:00" : "12:15:00";
                String et = p == 1 ? "10:00:00" : p == 2 ? "11:00:00" : p == 3 ? "12:15:00" : "13:15:00";
                db.insert("INSERT INTO timetable_slots (version_id, day_of_week, period_number, start_time, end_time, offering_id, room_id) VALUES (?,?,?,?,?,?,?)",
                        tvId, day, p, st, et, offId, roomId);
            }
        }

        // Fee Structure
        long fsId = db.insert("INSERT INTO fee_structures (programme_id, academic_year_id, batch_id, total_amount, due_date) VALUES (?,?,?, 65000.00, DATE_ADD(CURDATE(), INTERVAL 30 DAY))",
                progId, ayId, batchId);
        db.insert("INSERT INTO fee_components (fee_structure_id, name, amount) VALUES (?, 'Tuition Fee', 45000.00)", fsId);
        db.insert("INSERT INTO fee_components (fee_structure_id, name, amount) VALUES (?, 'Lab & Equipment', 12000.00)", fsId);
        db.insert("INSERT INTO fee_components (fee_structure_id, name, amount) VALUES (?, 'Exam & Library', 8000.00)", fsId);

        // Seed 15 Students
        String[] firstNames = {"Aarav", "Ananya", "Rohan", "Diya", "Kabir", "Meera", "Vivaan", "Sneha", "Aditya", "Pooja", "Ishaan", "Riya", "Karan", "Tanvi", "Siddharth"};
        String[] lastNames = {"Sharma", "Verma", "Patel", "Reddy", "Iyer", "Nair", "Gupta", "Kulkarni", "Singh", "Das", "Rao", "Joshi", "Bose", "Choudhury", "Pillai"};

        Random rand = new Random(42);
        for (int i = 0; i < 15; i++) {
            String regNo = String.format("25CSE%04d", i + 1);
            String email = "student" + (i + 1) + "@college.local";
            String fullName = firstNames[i] + " " + lastNames[i];
            String phone = "98000000" + String.format("%02d", i);
            String parentPhone = "97000000" + String.format("%02d", i);

            long uid = db.insert("INSERT INTO users (email, password_hash, role, must_change_password) VALUES (?,?,'STUDENT',FALSE)", email, hash);

            String aadhaar = "23456789" + String.format("%04d", i + 1000);
            String aadhaarEnc = aes.encrypt(aadhaar);
            String aadhaarHash = aes.hashAadhaar(aadhaar);
            String abcId = "ABC" + (900000000000L + i);

            long stId = db.insert("""
                INSERT INTO students (user_id, registration_number, roll_number, full_name, college_email, phone, dob,
                                      gender, address, aadhaar_hash, aadhaar_encrypted, abc_id, programme_id, department_id,
                                      admission_year, expected_graduation_year, current_semester, current_year_of_study, section_id)
                VALUES (?,?,?,?,?,?,'2005-04-15',?,'Chennai, India',?,?,?,?,?,2025,2029,1,1,?)
                """, uid, regNo, regNo, fullName, email, phone, i % 2 == 0 ? "MALE" : "FEMALE",
                    aadhaarHash, aadhaarEnc, abcId, progId, deptId, secId);

            db.insert("INSERT INTO student_guardians (student_id, father_name, mother_name, parent_phone) VALUES (?,?,?,?)",
                    stId, "Mr. " + lastNames[i], "Mrs. " + lastNames[i], parentPhone);

            // Register student in all courses
            for (long offId : offeringIds) {
                db.insert("INSERT INTO course_registrations (student_id, offering_id, status) VALUES (?,?, 'APPROVED')", stId, offId);
            }

            // Attendance records
            double attPct = i == 2 ? 68.5 : i == 5 ? 71.0 : (80.0 + (i % 15));
            boolean atRisk = attPct < 75.0;
            double cgpa = 7.0 + (i % 3) * 0.8;
            int arrears = (i == 2 || i == 6) ? 1 : 0;

            db.insert("""
                INSERT INTO student_academic_status (student_id, current_sgpa, current_cgpa, total_credits_earned, attendance_percentage, at_risk, arrears_count)
                VALUES (?,?,?,20,?,?,?)
                """, stId, cgpa, cgpa, attPct, atRisk, arrears);

            // Seed fees
            double paid = (i % 3 == 0) ? 65000.00 : (i % 3 == 1) ? 35000.00 : 0.00;
            double balance = 65000.00 - paid;
            String feeStatus = balance == 0 ? "PAID" : paid > 0 ? "PARTIAL" : "OVERDUE";
            long sfId = db.insert("""
                INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status)
                VALUES (?,?, 65000.00, ?, ?, ?)
                """, stId, fsId, paid, balance, feeStatus);

            if (paid > 0) {
                db.insert("""
                    INSERT INTO fee_payments (student_fee_id, amount_paid, payment_mode, transaction_reference, receipt_number)
                    VALUES (?,?, 'UPI', ?, ?)
                    """, sfId, paid, "TXN" + System.currentTimeMillis() + "" + i, "RCP2508" + String.format("%04d", i + 1));
            }

            // Seed an arrear for student 3 & 7
            if (arrears > 0) {
                db.insert("""
                    INSERT INTO arrears (student_id, course_id, semester_id, attempts_count, status)
                    VALUES (?,?, 1, 1, 'PENDING')
                    """, stId, courseIds[1]);
            }
        }

        // Announcements
        db.insert("""
            INSERT INTO announcements (title, content, priority, channel, target_type, author_id)
            VALUES ('Mid-Semester Examinations Schedule', 'Mid-semester examinations commence on the 10th of next month. Check the student dashboard for room allocations.', 'IMPORTANT', 'IN_APP', 'EVERYONE', 1)
            """);

        db.insert("""
            INSERT INTO announcements (title, content, priority, channel, target_type, author_id)
            VALUES ('Arrear Re-Examination Portal Open', 'Eligible students with pending course arrears can register for re-examinations through the Arrears tab.', 'URGENT', 'IN_APP', 'ALL_STUDENTS', 1)
            """);

        // Payroll run
        long prId = db.insert("INSERT INTO payroll_runs (month_year, total_disbursed, status, processed_at) VALUES ('10-2025', 245000.00, 'PAID', NOW())");
        for (long fid : facIds) {
            db.insert("""
                INSERT INTO payslips (payroll_run_id, faculty_id, basic, hra, da, allowances, deductions, net_amount)
                VALUES (?,?, 75000.00, 15000.00, 11250.00, 5000.00, 15000.00, 86250.00)
                """, prId, fid);
        }

        log.info("Realistic demo seed completed successfully. Logins: admin@college.local, teacher1@college.local, student1@college.local .. student15@college.local (password Demo@12345).");
    }
}
