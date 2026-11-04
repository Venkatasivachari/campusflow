-- ==============================================================================
-- IMPERIAL INSTITUTE - ENTERPRISE COLLEGE MANAGEMENT SYSTEM (2015-2026)
-- Part 1: Complete Normalized Database DDL Schema
-- Compatible with: MySQL 8.0+, MySQL Workbench, AWS RDS / Aurora MySQL
-- Character Set: utf8mb4 | Collation: utf8mb4_unicode_ci
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS college_management_system
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE college_management_system;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS fee_payments;
DROP TABLE IF EXISTS student_fees;
DROP TABLE IF EXISTS fee_structures;
DROP TABLE IF EXISTS arrears;
DROP TABLE IF EXISTS gpa_records;
DROP TABLE IF EXISTS student_marks;
DROP TABLE IF EXISTS assessments;
DROP TABLE IF EXISTS attendance_records;
DROP TABLE IF EXISTS attendance_sessions;
DROP TABLE IF EXISTS timetable_slots;
DROP TABLE IF EXISTS timetable_versions;
DROP TABLE IF EXISTS course_registrations;
DROP TABLE IF EXISTS course_offerings;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS student_academic_status;
DROP TABLE IF EXISTS student_mentor_assignment;
DROP TABLE IF EXISTS student_parent_info;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS faculty_payslips;
DROP TABLE IF EXISTS faculty_salary_structures;
DROP TABLE IF EXISTS faculty_leave_applications;
DROP TABLE IF EXISTS faculty_leave_balance;
DROP TABLE IF EXISTS faculty_workloads;
DROP TABLE IF EXISTS faculty;
DROP TABLE IF EXISTS ownership_history;
DROP TABLE IF EXISTS root_owner_control;
DROP TABLE IF EXISTS owners;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS rooms;
DROP TABLE IF EXISTS sections;
DROP TABLE IF EXISTS batches;
DROP TABLE IF EXISTS programmes;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS academic_years;
DROP TABLE IF EXISTS institutions;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------------------------
-- 1. INSTITUTIONS & DEPARTMENTS
-- ------------------------------------------------------------------------------
CREATE TABLE institutions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(32) NOT NULL UNIQUE,
    website VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE programmes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    department_id BIGINT NOT NULL,
    duration_years INT NOT NULL DEFAULT 4,
    total_semesters INT NOT NULL DEFAULT 8,
    degree_type VARCHAR(32) NOT NULL DEFAULT 'B.Tech',
    CONSTRAINT fk_prog_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 2. ACADEMIC CALENDAR & INFRASTRUCTURE
-- ------------------------------------------------------------------------------
CREATE TABLE academic_years (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(32) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE batches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    programme_id BIGINT NOT NULL,
    admission_year INT NOT NULL,
    expected_graduation_year INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    CONSTRAINT fk_batch_prog FOREIGN KEY (programme_id) REFERENCES programmes(id)
) ENGINE=InnoDB;

CREATE TABLE sections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT NOT NULL,
    name VARCHAR(16) NOT NULL,
    capacity INT NOT NULL DEFAULT 60,
    CONSTRAINT fk_sec_batch FOREIGN KEY (batch_id) REFERENCES batches(id)
) ENGINE=InnoDB;

CREATE TABLE rooms (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    room_number VARCHAR(32) NOT NULL UNIQUE,
    building VARCHAR(64) NOT NULL,
    capacity INT NOT NULL DEFAULT 60,
    room_type VARCHAR(32) NOT NULL DEFAULT 'CLASSROOM'
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 3. IDENTITY, ROLES & PERMISSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(64) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(191) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(32) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 4. ROOT OWNER & OWNERSHIP GOVERNANCE (SINGLETON ENFORCEMENT)
-- ------------------------------------------------------------------------------
CREATE TABLE owners (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    owner_code VARCHAR(32) NOT NULL UNIQUE,
    full_name VARCHAR(128) NOT NULL,
    official_email VARCHAR(191) NOT NULL UNIQUE,
    phone VARCHAR(32) NOT NULL,
    designation VARCHAR(64) NOT NULL DEFAULT 'Root Owner / Chairman',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    institution_id BIGINT NULL,
    permissions TEXT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_owner_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_owner_inst FOREIGN KEY (institution_id) REFERENCES institutions(id)
) ENGINE=InnoDB;

CREATE TABLE root_owner_control (
    singleton_id TINYINT PRIMARY KEY DEFAULT 1 CHECK (singleton_id = 1),
    user_id BIGINT NOT NULL UNIQUE,
    owner_id VARCHAR(50) NOT NULL UNIQUE,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_root_control_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE ownership_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    previous_owner_id VARCHAR(50) NULL,
    new_owner_id VARCHAR(50) NOT NULL,
    transferred_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    approved_by VARCHAR(50) NOT NULL,
    transfer_reason TEXT,
    ip_address VARCHAR(45) NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 5. FACULTY MANAGEMENT
-- ------------------------------------------------------------------------------
CREATE TABLE faculty (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    employee_code VARCHAR(32) NOT NULL UNIQUE,
    first_name VARCHAR(64) NOT NULL,
    last_name VARCHAR(64) NOT NULL,
    official_email VARCHAR(191) NOT NULL UNIQUE,
    phone VARCHAR(32) NOT NULL,
    department_id BIGINT NOT NULL,
    designation VARCHAR(64) NOT NULL,
    qualification VARCHAR(64) NOT NULL,
    specialization VARCHAR(128) NOT NULL,
    joining_date DATE NOT NULL,
    experience_years INT NOT NULL DEFAULT 5,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_faculty_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_faculty_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_workloads (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    academic_year VARCHAR(32) NOT NULL,
    semester INT NOT NULL,
    lecture_hours_per_week INT NOT NULL DEFAULT 12,
    lab_hours_per_week INT NOT NULL DEFAULT 4,
    total_hours_per_week INT NOT NULL DEFAULT 16,
    max_capacity_hours INT NOT NULL DEFAULT 20,
    CONSTRAINT fk_workload_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_leave_balance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL UNIQUE,
    casual_leave_remaining INT NOT NULL DEFAULT 12,
    sick_leave_remaining INT NOT NULL DEFAULT 10,
    earned_leave_remaining INT NOT NULL DEFAULT 15,
    CONSTRAINT fk_leave_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_leave_applications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    leave_type VARCHAR(32) NOT NULL,
    from_date DATE NOT NULL,
    to_date DATE NOT NULL,
    reason TEXT NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_leaveapp_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_salary_structures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL UNIQUE,
    basic_pay DECIMAL(10,2) NOT NULL,
    da DECIMAL(10,2) NOT NULL,
    hra DECIMAL(10,2) NOT NULL,
    allowances DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    pf_deduction DECIMAL(10,2) NOT NULL,
    tax_deduction DECIMAL(10,2) NOT NULL,
    gross_salary DECIMAL(10,2) NOT NULL,
    net_salary DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_sal_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_payslips (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    pay_period_month INT NOT NULL,
    pay_period_year INT NOT NULL,
    gross_amount DECIMAL(10,2) NOT NULL,
    total_deductions DECIMAL(10,2) NOT NULL,
    net_amount DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(32) NOT NULL DEFAULT 'PAID',
    payment_date DATE NOT NULL,
    transaction_ref VARCHAR(64) NOT NULL,
    CONSTRAINT fk_slip_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 6. STUDENT MANAGEMENT (2015-2026 COHORTS)
-- ------------------------------------------------------------------------------
CREATE TABLE students (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    registration_number VARCHAR(32) NOT NULL UNIQUE,
    roll_number VARCHAR(32) NOT NULL,
    full_name VARCHAR(128) NOT NULL,
    college_email VARCHAR(191) NOT NULL UNIQUE,
    phone VARCHAR(32) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(16) NOT NULL,
    address TEXT NOT NULL,
    programme_id BIGINT NOT NULL,
    department_id BIGINT NOT NULL,
    admission_year INT NOT NULL,
    expected_graduation_year INT NOT NULL,
    current_semester INT NOT NULL DEFAULT 1,
    current_year_of_study VARCHAR(32) NOT NULL DEFAULT 'First Year',
    section_id BIGINT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_student_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_student_prog FOREIGN KEY (programme_id) REFERENCES programmes(id),
    CONSTRAINT fk_student_dept FOREIGN KEY (department_id) REFERENCES departments(id),
    CONSTRAINT fk_student_sec FOREIGN KEY (section_id) REFERENCES sections(id)
) ENGINE=InnoDB;

CREATE TABLE student_parent_info (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL UNIQUE,
    father_name VARCHAR(128) NOT NULL,
    father_phone VARCHAR(32) NOT NULL,
    father_occupation VARCHAR(64),
    mother_name VARCHAR(128) NOT NULL,
    mother_phone VARCHAR(32),
    mother_occupation VARCHAR(64),
    emergency_contact VARCHAR(32) NOT NULL,
    CONSTRAINT fk_parent_student FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_mentor_assignment (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    faculty_id BIGINT NOT NULL,
    academic_year VARCHAR(32) NOT NULL,
    assigned_date DATE NOT NULL,
    CONSTRAINT fk_mentor_stu FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_mentor_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

CREATE TABLE student_academic_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL UNIQUE,
    current_cgpa DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    attendance_percentage DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    active_arrears_count INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_status_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 7. ACADEMICS, ATTENDANCE & EXAMINATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    department_id BIGINT NOT NULL,
    credits INT NOT NULL DEFAULT 3,
    lecture_hours INT NOT NULL DEFAULT 3,
    lab_hours INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_course_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE course_offerings (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_id BIGINT NOT NULL,
    faculty_id BIGINT NOT NULL,
    section_id BIGINT NOT NULL,
    semester INT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    CONSTRAINT fk_co_course FOREIGN KEY (course_id) REFERENCES courses(id),
    CONSTRAINT fk_co_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id),
    CONSTRAINT fk_co_sec FOREIGN KEY (section_id) REFERENCES sections(id),
    CONSTRAINT fk_co_ay FOREIGN KEY (academic_year_id) REFERENCES academic_years(id)
) ENGINE=InnoDB;

CREATE TABLE course_registrations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    course_offering_id BIGINT NOT NULL,
    registration_status VARCHAR(32) NOT NULL DEFAULT 'ENROLLED',
    registered_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_cr_stu FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_cr_co FOREIGN KEY (course_offering_id) REFERENCES course_offerings(id)
) ENGINE=InnoDB;

CREATE TABLE timetable_versions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE timetable_slots (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    timetable_version_id BIGINT NOT NULL,
    course_offering_id BIGINT NOT NULL,
    room_id BIGINT NOT NULL,
    day_of_week VARCHAR(16) NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    CONSTRAINT fk_slot_tv FOREIGN KEY (timetable_version_id) REFERENCES timetable_versions(id),
    CONSTRAINT fk_slot_co FOREIGN KEY (course_offering_id) REFERENCES course_offerings(id),
    CONSTRAINT fk_slot_room FOREIGN KEY (room_id) REFERENCES rooms(id)
) ENGINE=InnoDB;

CREATE TABLE attendance_sessions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_offering_id BIGINT NOT NULL,
    date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    topic TEXT,
    taken_by_faculty_id BIGINT NOT NULL,
    CONSTRAINT fk_as_co FOREIGN KEY (course_offering_id) REFERENCES course_offerings(id),
    CONSTRAINT fk_as_fac FOREIGN KEY (taken_by_faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

CREATE TABLE attendance_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    session_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    status VARCHAR(16) NOT NULL,
    CONSTRAINT fk_ar_sess FOREIGN KEY (session_id) REFERENCES attendance_sessions(id) ON DELETE CASCADE,
    CONSTRAINT fk_ar_stu FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;

CREATE TABLE assessments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_offering_id BIGINT NOT NULL,
    title VARCHAR(128) NOT NULL,
    type VARCHAR(32) NOT NULL,
    max_marks DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    weightage_percentage DECIMAL(5,2) NOT NULL DEFAULT 20.00,
    CONSTRAINT fk_asm_co FOREIGN KEY (course_offering_id) REFERENCES course_offerings(id)
) ENGINE=InnoDB;

CREATE TABLE student_marks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    assessment_id BIGINT NOT NULL,
    student_id BIGINT NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    is_absent BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_sm_asm FOREIGN KEY (assessment_id) REFERENCES assessments(id) ON DELETE CASCADE,
    CONSTRAINT fk_sm_stu FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;

CREATE TABLE gpa_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    semester INT NOT NULL,
    sgpa DECIMAL(4,2) NOT NULL,
    cgpa DECIMAL(4,2) NOT NULL,
    credits_earned INT NOT NULL,
    CONSTRAINT fk_gpa_stu FOREIGN KEY (student_id) REFERENCES students(id)
) ENGINE=InnoDB;

CREATE TABLE arrears (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    semester INT NOT NULL,
    is_cleared BOOLEAN NOT NULL DEFAULT FALSE,
    cleared_at DATE,
    CONSTRAINT fk_arr_stu FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_arr_course FOREIGN KEY (course_id) REFERENCES courses(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 8. FINANCIAL MANAGEMENT
-- ------------------------------------------------------------------------------
CREATE TABLE fee_structures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    programme_id BIGINT NOT NULL,
    admission_year INT NOT NULL,
    tuition_fee DECIMAL(10,2) NOT NULL,
    lab_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    library_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    other_charges DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_fee DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_fee_prog FOREIGN KEY (programme_id) REFERENCES programmes(id)
) ENGINE=InnoDB;

CREATE TABLE student_fees (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    fee_structure_id BIGINT NOT NULL,
    total_payable DECIMAL(10,2) NOT NULL,
    total_paid DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    balance_due DECIMAL(10,2) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    due_date DATE NOT NULL,
    CONSTRAINT fk_sf_stu FOREIGN KEY (student_id) REFERENCES students(id),
    CONSTRAINT fk_sf_fs FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(id)
) ENGINE=InnoDB;

CREATE TABLE fee_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_fee_id BIGINT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(32) NOT NULL,
    payment_date DATE NOT NULL,
    transaction_ref VARCHAR(64) NOT NULL UNIQUE,
    receipt_number VARCHAR(64) NOT NULL UNIQUE,
    CONSTRAINT fk_fp_sf FOREIGN KEY (student_fee_id) REFERENCES student_fees(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 9. AUDIT & NOTIFICATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE announcements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(191) NOT NULL,
    content TEXT NOT NULL,
    posted_by BIGINT NOT NULL,
    audience VARCHAR(32) NOT NULL DEFAULT 'ALL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_anc_user FOREIGN KEY (posted_by) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(191) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_notif_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    action VARCHAR(128) NOT NULL,
    entity VARCHAR(64) NOT NULL,
    entity_id VARCHAR(64) NULL,
    details TEXT NULL,
    ip_address VARCHAR(45) NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;
