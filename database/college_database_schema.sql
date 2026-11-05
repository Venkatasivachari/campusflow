-- ==============================================================================
-- IMPERIAL INSTITUTE - ENTERPRISE COLLEGE MANAGEMENT SYSTEM (2015-2026)
-- Part 1: Comprehensive Normalized Database Schema
-- Compatible with: MySQL 8.0+, MySQL Workbench, AWS Aurora/RDS
-- Engine: InnoDB | Character Set: utf8mb4 | Collation: utf8mb4_unicode_ci
-- ==============================================================================

CREATE DATABASE IF NOT EXISTS college_management_system
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE college_management_system;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS notifications;
DROP TABLE IF EXISTS announcements;
DROP TABLE IF EXISTS audit_logs;
DROP TABLE IF EXISTS mfa_credentials;
DROP TABLE IF EXISTS user_sessions;
DROP TABLE IF EXISTS password_reset_tokens;
DROP TABLE IF EXISTS login_attempts;
DROP TABLE IF EXISTS id_sequences;
DROP TABLE IF EXISTS sensitive_data;
DROP TABLE IF EXISTS salary_payments;
DROP TABLE IF EXISTS fee_payments;
DROP TABLE IF EXISTS student_fee_accounts;
DROP TABLE IF EXISTS fee_structures;
DROP TABLE IF EXISTS timetable;
DROP TABLE IF EXISTS assignment_submissions;
DROP TABLE IF EXISTS assignments;
DROP TABLE IF EXISTS arrears;
DROP TABLE IF EXISTS results;
DROP TABLE IF EXISTS marks;
DROP TABLE IF EXISTS examinations;
DROP TABLE IF EXISTS attendance;
DROP TABLE IF EXISTS faculty_allocations;
DROP TABLE IF EXISTS course_registrations;
DROP TABLE IF EXISTS sections;
DROP TABLE IF EXISTS subjects;
DROP TABLE IF EXISTS courses;
DROP TABLE IF EXISTS semesters;
DROP TABLE IF EXISTS academic_years;
DROP TABLE IF EXISTS student_documents;
DROP TABLE IF EXISTS student_status_history;
DROP TABLE IF EXISTS student_academic_history;
DROP TABLE IF EXISTS student_guardians;
DROP TABLE IF EXISTS student_batches;
DROP TABLE IF EXISTS students;
DROP TABLE IF EXISTS student_source_records;
DROP TABLE IF EXISTS faculty_subjects;
DROP TABLE IF EXISTS faculty_salary_history;
DROP TABLE IF EXISTS faculty_employment_history;
DROP TABLE IF EXISTS faculty;
DROP TABLE IF EXISTS admin_profiles;
DROP TABLE IF EXISTS owners;
DROP TABLE IF EXISTS organizational_assignments;
DROP TABLE IF EXISTS designations;
DROP TABLE IF EXISTS departments;
DROP TABLE IF EXISTS ownership_history;
DROP TABLE IF EXISTS root_owner_control;
DROP TABLE IF EXISTS user_roles;
DROP TABLE IF EXISTS role_permissions;
DROP TABLE IF EXISTS permissions;
DROP TABLE IF EXISTS roles;
DROP TABLE IF EXISTS users;
DROP TABLE IF EXISTS institutions;
SET FOREIGN_KEY_CHECKS = 1;

-- ------------------------------------------------------------------------------
-- 1. INSTITUTIONS & ACCESS CONTROL
-- ------------------------------------------------------------------------------
CREATE TABLE institutions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(32) NOT NULL UNIQUE,
    established_year INT NOT NULL DEFAULT 2014,
    email VARCHAR(191) NOT NULL,
    phone VARCHAR(32) NOT NULL,
    website VARCHAR(255),
    address TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    public_id VARCHAR(64) NOT NULL UNIQUE,
    email VARCHAR(191) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(32) NOT NULL,
    account_status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    mfa_enabled BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_count INT NOT NULL DEFAULT 0,
    lockout_until DATETIME NULL,
    last_login_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL
) ENGINE=InnoDB;

CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    role_code VARCHAR(32) NOT NULL UNIQUE,
    role_name VARCHAR(64) NOT NULL,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE permissions (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    permission_code VARCHAR(64) NOT NULL UNIQUE,
    description VARCHAR(255)
) ENGINE=InnoDB;

CREATE TABLE user_roles (
    user_id BIGINT NOT NULL,
    role_id BIGINT NOT NULL,
    PRIMARY KEY (user_id, role_id),
    CONSTRAINT fk_ur_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_ur_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE role_permissions (
    role_id BIGINT NOT NULL,
    permission_id BIGINT NOT NULL,
    PRIMARY KEY (role_id, permission_id),
    CONSTRAINT fk_rp_role FOREIGN KEY (role_id) REFERENCES roles(id) ON DELETE CASCADE,
    CONSTRAINT fk_rp_perm FOREIGN KEY (permission_id) REFERENCES permissions(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 2. SINGLETON ROOT OWNER GOVERNANCE
-- ------------------------------------------------------------------------------
CREATE TABLE root_owner_control (
    singleton_id TINYINT PRIMARY KEY DEFAULT 1 CHECK (singleton_id = 1),
    user_id BIGINT NOT NULL UNIQUE,
    owner_id VARCHAR(50) NOT NULL UNIQUE,
    appointed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_root_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE RESTRICT
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

CREATE TABLE owners (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    owner_id VARCHAR(50) NOT NULL UNIQUE,
    full_name VARCHAR(128) NOT NULL,
    email VARCHAR(191) NOT NULL UNIQUE,
    phone VARCHAR(32) NOT NULL,
    designation VARCHAR(64) NOT NULL DEFAULT 'Root Owner / Chancellor',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    institution_id BIGINT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_owner_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    CONSTRAINT fk_owner_inst FOREIGN KEY (institution_id) REFERENCES institutions(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 3. ORGANIZATIONAL STRUCTURE
-- ------------------------------------------------------------------------------
CREATE TABLE departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    department_code VARCHAR(32) NOT NULL UNIQUE,
    department_name VARCHAR(128) NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    established_year INT NOT NULL DEFAULT 2014,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE designations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    designation_name VARCHAR(64) NOT NULL UNIQUE,
    hierarchy_level INT NOT NULL DEFAULT 10,
    category VARCHAR(32) NOT NULL DEFAULT 'ACADEMIC'
) ENGINE=InnoDB;

CREATE TABLE organizational_assignments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    department_id BIGINT NULL,
    designation_id BIGINT NOT NULL,
    reports_to BIGINT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    CONSTRAINT fk_oa_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_oa_dept FOREIGN KEY (department_id) REFERENCES departments(id),
    CONSTRAINT fk_oa_desig FOREIGN KEY (designation_id) REFERENCES designations(id),
    CONSTRAINT fk_oa_rep FOREIGN KEY (reports_to) REFERENCES users(id)
) ENGINE=InnoDB;

CREATE TABLE admin_profiles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    employee_code VARCHAR(32) NOT NULL UNIQUE,
    full_name VARCHAR(128) NOT NULL,
    office_location VARCHAR(64),
    phone VARCHAR(32),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_admin_user FOREIGN KEY (user_id) REFERENCES users(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 4. FACULTY MANAGEMENT
-- ------------------------------------------------------------------------------
CREATE TABLE faculty (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    employee_code VARCHAR(32) NOT NULL UNIQUE,
    full_name VARCHAR(128) NOT NULL,
    gender VARCHAR(16) NOT NULL,
    email VARCHAR(191) NOT NULL UNIQUE,
    phone VARCHAR(32) NOT NULL,
    department_id BIGINT NOT NULL,
    designation VARCHAR(64) NOT NULL,
    qualification VARCHAR(64) NOT NULL,
    specialization VARCHAR(128) NOT NULL,
    joining_date DATE NOT NULL,
    experience_years INT NOT NULL DEFAULT 5,
    employment_status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    data_status VARCHAR(32) NOT NULL DEFAULT 'SYNTHETIC_DEMO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fac_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_fac_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_employment_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    designation_id BIGINT NOT NULL,
    department_id BIGINT NOT NULL,
    start_date DATE NOT NULL,
    end_date DATE NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_feh_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id) ON DELETE CASCADE,
    CONSTRAINT fk_feh_desig FOREIGN KEY (designation_id) REFERENCES designations(id),
    CONSTRAINT fk_feh_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_salary_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    basic_salary DECIMAL(10,2) NOT NULL,
    allowances DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    gross_salary DECIMAL(10,2) NOT NULL,
    deductions DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    net_salary DECIMAL(10,2) NOT NULL,
    effective_from DATE NOT NULL,
    effective_to DATE NULL,
    is_verified BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_fsh_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 5. ACADEMIC CALENDAR & INFRASTRUCTURE
-- ------------------------------------------------------------------------------
CREATE TABLE academic_years (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    year_name VARCHAR(32) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;

CREATE TABLE semesters (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    semester_number INT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    term_type VARCHAR(16) NOT NULL DEFAULT 'ODD',
    start_date DATE,
    end_date DATE,
    CONSTRAINT fk_sem_ay FOREIGN KEY (academic_year_id) REFERENCES academic_years(id)
) ENGINE=InnoDB;

CREATE TABLE courses (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    course_code VARCHAR(32) NOT NULL UNIQUE,
    course_name VARCHAR(128) NOT NULL,
    degree VARCHAR(32) NOT NULL DEFAULT 'B.Tech',
    duration_years INT NOT NULL DEFAULT 4,
    total_semesters INT NOT NULL DEFAULT 8
) ENGINE=InnoDB;

CREATE TABLE subjects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    subject_code VARCHAR(32) NOT NULL UNIQUE,
    subject_name VARCHAR(128) NOT NULL,
    department_id BIGINT NOT NULL,
    credits INT NOT NULL DEFAULT 3,
    lecture_hours INT NOT NULL DEFAULT 3,
    lab_hours INT NOT NULL DEFAULT 0,
    CONSTRAINT fk_sub_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE student_batches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_code VARCHAR(32) NOT NULL UNIQUE,
    admission_year INT NOT NULL,
    graduation_year INT NOT NULL,
    department_id BIGINT NOT NULL,
    CONSTRAINT fk_sb_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE sections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    batch_id BIGINT NOT NULL,
    section_name VARCHAR(16) NOT NULL,
    capacity INT NOT NULL DEFAULT 60,
    department_id BIGINT NOT NULL,
    CONSTRAINT fk_sec_batch FOREIGN KEY (batch_id) REFERENCES student_batches(id),
    CONSTRAINT fk_sec_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 6. STUDENT SOURCE RECORDS & STUDENT IDENTITY (9,000 EXCEL RECORDS)
-- ------------------------------------------------------------------------------
CREATE TABLE student_source_records (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    source_row_index INT NOT NULL UNIQUE,
    source_name VARCHAR(191) NOT NULL,
    source_phone VARCHAR(32) NOT NULL UNIQUE,
    source_gender VARCHAR(16) NOT NULL,
    has_encoding_anomaly BOOLEAN NOT NULL DEFAULT FALSE,
    import_batch_ref VARCHAR(64) NOT NULL DEFAULT 'INITIAL_EXCEL_V1',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE students (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    source_record_id BIGINT NOT NULL UNIQUE,
    student_id VARCHAR(32) NOT NULL UNIQUE,
    admission_number VARCHAR(32) NOT NULL UNIQUE,
    registration_number VARCHAR(32) NOT NULL UNIQUE,
    roll_number VARCHAR(32) NOT NULL,
    full_name VARCHAR(128) NOT NULL,
    display_name VARCHAR(128) NOT NULL,
    gender VARCHAR(16) NOT NULL,
    email VARCHAR(191) NOT NULL UNIQUE,
    phone VARCHAR(32) NOT NULL,
    department_id BIGINT NOT NULL,
    course_id BIGINT NOT NULL,
    batch_id BIGINT NOT NULL,
    admission_year INT NOT NULL,
    graduation_year INT NOT NULL,
    current_year_of_study VARCHAR(32) NOT NULL,
    current_semester INT NOT NULL,
    section_id BIGINT NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    data_origin VARCHAR(32) NOT NULL DEFAULT 'EXCEL_SOURCE_VERIFIED',
    academic_data_type VARCHAR(32) NOT NULL DEFAULT 'SYNTHETIC_ACADEMIC_DEMO',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_stu_user FOREIGN KEY (user_id) REFERENCES users(id),
    CONSTRAINT fk_stu_src FOREIGN KEY (source_record_id) REFERENCES student_source_records(id),
    CONSTRAINT fk_stu_dept FOREIGN KEY (department_id) REFERENCES departments(id),
    CONSTRAINT fk_stu_course FOREIGN KEY (course_id) REFERENCES courses(id),
    CONSTRAINT fk_stu_batch FOREIGN KEY (batch_id) REFERENCES student_batches(id),
    CONSTRAINT fk_stu_sec FOREIGN KEY (section_id) REFERENCES sections(id)
) ENGINE=InnoDB;

CREATE TABLE student_guardians (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    guardian_name VARCHAR(128) NOT NULL,
    relationship VARCHAR(32) NOT NULL DEFAULT 'Parent',
    phone VARCHAR(32) NOT NULL,
    CONSTRAINT fk_sg_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_academic_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    year_of_study VARCHAR(32) NOT NULL,
    section_id BIGINT NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'PROMOTED',
    cgpa DECIMAL(4,2) NOT NULL DEFAULT 0.00,
    attendance_pct DECIMAL(5,2) NOT NULL DEFAULT 0.00,
    CONSTRAINT fk_sah_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_sah_ay FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    CONSTRAINT fk_sah_sem FOREIGN KEY (semester_id) REFERENCES semesters(id),
    CONSTRAINT fk_sah_sec FOREIGN KEY (section_id) REFERENCES sections(id)
) ENGINE=InnoDB;

CREATE TABLE student_status_history (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    old_status VARCHAR(32),
    new_status VARCHAR(32) NOT NULL,
    effective_date DATE NOT NULL,
    reason TEXT,
    changed_by BIGINT,
    CONSTRAINT fk_ssh_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 7. FACULTY ALLOCATION & TEACHING ASSIGNMENTS
-- ------------------------------------------------------------------------------
CREATE TABLE faculty_allocations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    student_id BIGINT NULL,
    department_id BIGINT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    section_id BIGINT NULL,
    subject_id BIGINT NULL,
    role_type VARCHAR(32) NOT NULL, -- 'HOD', 'CLASS_COORDINATOR', 'MENTOR', 'SUBJECT_FACULTY'
    start_date DATE NOT NULL,
    end_date DATE NULL,
    allocation_status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    CONSTRAINT fk_fa_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id),
    CONSTRAINT fk_fa_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_fa_dept FOREIGN KEY (department_id) REFERENCES departments(id),
    CONSTRAINT fk_fa_ay FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    CONSTRAINT fk_fa_sem FOREIGN KEY (semester_id) REFERENCES semesters(id),
    CONSTRAINT fk_fa_sec FOREIGN KEY (section_id) REFERENCES sections(id),
    CONSTRAINT fk_fa_sub FOREIGN KEY (subject_id) REFERENCES subjects(id)
) ENGINE=InnoDB;

CREATE TABLE faculty_subjects (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    subject_id BIGINT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    section_id BIGINT NOT NULL,
    weekly_hours INT NOT NULL DEFAULT 4,
    CONSTRAINT fk_fs_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id),
    CONSTRAINT fk_fs_sub FOREIGN KEY (subject_id) REFERENCES subjects(id),
    CONSTRAINT fk_fs_ay FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    CONSTRAINT fk_fs_sec FOREIGN KEY (section_id) REFERENCES sections(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 8. ACADEMICS, ATTENDANCE, EXAMINATIONS & MARKS
-- ------------------------------------------------------------------------------
CREATE TABLE course_registrations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    subject_id BIGINT NOT NULL,
    academic_year_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'REGISTERED',
    CONSTRAINT fk_cr_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_cr_sub FOREIGN KEY (subject_id) REFERENCES subjects(id),
    CONSTRAINT fk_cr_ay FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    CONSTRAINT fk_cr_sem FOREIGN KEY (semester_id) REFERENCES semesters(id)
) ENGINE=InnoDB;

CREATE TABLE attendance (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    subject_id BIGINT NOT NULL,
    faculty_id BIGINT NOT NULL,
    session_date DATE NOT NULL,
    session_hour INT NOT NULL DEFAULT 1,
    status VARCHAR(16) NOT NULL, -- 'PRESENT', 'ABSENT', 'ON_DUTY'
    CONSTRAINT fk_att_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_att_sub FOREIGN KEY (subject_id) REFERENCES subjects(id),
    CONSTRAINT fk_att_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

CREATE TABLE examinations (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    exam_name VARCHAR(64) NOT NULL,
    exam_type VARCHAR(32) NOT NULL, -- 'INTERNAL_1', 'INTERNAL_2', 'SEMESTER_FINAL'
    academic_year_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    max_marks DECIMAL(5,2) NOT NULL DEFAULT 100.00,
    CONSTRAINT fk_exam_ay FOREIGN KEY (academic_year_id) REFERENCES academic_years(id),
    CONSTRAINT fk_exam_sem FOREIGN KEY (semester_id) REFERENCES semesters(id)
) ENGINE=InnoDB;

CREATE TABLE marks (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    subject_id BIGINT NOT NULL,
    examination_id BIGINT NOT NULL,
    marks_obtained DECIMAL(5,2) NOT NULL,
    grade VARCHAR(8) NOT NULL DEFAULT 'B',
    is_absent BOOLEAN NOT NULL DEFAULT FALSE,
    CONSTRAINT fk_mrk_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_mrk_sub FOREIGN KEY (subject_id) REFERENCES subjects(id),
    CONSTRAINT fk_mrk_exam FOREIGN KEY (examination_id) REFERENCES examinations(id)
) ENGINE=InnoDB;

CREATE TABLE results (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    sgpa DECIMAL(4,2) NOT NULL,
    cgpa DECIMAL(4,2) NOT NULL,
    total_credits_registered INT NOT NULL DEFAULT 24,
    total_credits_earned INT NOT NULL DEFAULT 24,
    result_status VARCHAR(16) NOT NULL DEFAULT 'PASSED',
    CONSTRAINT fk_res_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_res_sem FOREIGN KEY (semester_id) REFERENCES semesters(id)
) ENGINE=InnoDB;

CREATE TABLE arrears (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL,
    subject_id BIGINT NOT NULL,
    semester_id BIGINT NOT NULL,
    is_cleared BOOLEAN NOT NULL DEFAULT FALSE,
    cleared_in_exam_id BIGINT NULL,
    CONSTRAINT fk_arr_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_arr_sub FOREIGN KEY (subject_id) REFERENCES subjects(id),
    CONSTRAINT fk_arr_sem FOREIGN KEY (semester_id) REFERENCES semesters(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 9. FINANCIAL GOVERNANCE
-- ------------------------------------------------------------------------------
CREATE TABLE fee_structures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    department_id BIGINT NOT NULL,
    admission_year INT NOT NULL,
    tuition_fee DECIMAL(10,2) NOT NULL,
    lab_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    development_fee DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    total_annual_fee DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_fs_dept FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE student_fee_accounts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL UNIQUE,
    fee_structure_id BIGINT NOT NULL,
    total_payable DECIMAL(10,2) NOT NULL,
    total_paid DECIMAL(10,2) NOT NULL DEFAULT 0.00,
    balance_due DECIMAL(10,2) NOT NULL,
    payment_status VARCHAR(32) NOT NULL DEFAULT 'PENDING',
    CONSTRAINT fk_sfa_stu FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE,
    CONSTRAINT fk_sfa_fs FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(id)
) ENGINE=InnoDB;

CREATE TABLE fee_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_fee_account_id BIGINT NOT NULL,
    payment_amount DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(32) NOT NULL DEFAULT 'ONLINE',
    payment_date DATE NOT NULL,
    transaction_ref VARCHAR(64) NOT NULL UNIQUE,
    receipt_number VARCHAR(64) NOT NULL UNIQUE,
    CONSTRAINT fk_fp_sfa FOREIGN KEY (student_fee_account_id) REFERENCES student_fee_accounts(id)
) ENGINE=InnoDB;

CREATE TABLE salary_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    faculty_id BIGINT NOT NULL,
    month INT NOT NULL,
    year INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL,
    transaction_ref VARCHAR(64) NOT NULL UNIQUE,
    status VARCHAR(32) NOT NULL DEFAULT 'DISBURSED',
    CONSTRAINT fk_sp_fac FOREIGN KEY (faculty_id) REFERENCES faculty(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 10. SENSITIVE DATA ENCRYPTION & SECURITY AUDIT
-- ------------------------------------------------------------------------------
CREATE TABLE sensitive_data (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    entity_type VARCHAR(32) NOT NULL, -- 'STUDENT', 'FACULTY'
    entity_id BIGINT NOT NULL,
    field_name VARCHAR(64) NOT NULL,  -- 'AADHAAR', 'BANK_ACCOUNT'
    encrypted_value TEXT NOT NULL,    -- AES-256-GCM cipher
    key_version VARCHAR(16) NOT NULL DEFAULT 'v1',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_entity_field UNIQUE (entity_type, entity_id, field_name)
) ENGINE=InnoDB;

CREATE TABLE id_sequences (
    sequence_name VARCHAR(64) PRIMARY KEY,
    current_value BIGINT NOT NULL DEFAULT 0,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE login_attempts (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    identifier VARCHAR(191) NOT NULL,
    role VARCHAR(32) NULL,
    attempt_status VARCHAR(16) NOT NULL, -- 'SUCCESS', 'FAILED'
    failure_reason VARCHAR(255) NULL,
    ip_address VARCHAR(45) NULL,
    user_agent TEXT NULL,
    timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    action VARCHAR(64) NOT NULL,
    entity_name VARCHAR(64) NOT NULL,
    entity_id VARCHAR(64) NULL,
    details TEXT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_audit_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE announcements (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(191) NOT NULL,
    content TEXT NOT NULL,
    posted_by BIGINT NOT NULL,
    audience VARCHAR(32) NOT NULL DEFAULT 'ALL',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_ann_user FOREIGN KEY (posted_by) REFERENCES users(id)
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

-- ------------------------------------------------------------------------------
-- PERFORMANCE INDEXES
-- ------------------------------------------------------------------------------
CREATE INDEX idx_students_reg ON students(registration_number);
CREATE INDEX idx_students_adm ON students(admission_number);
CREATE INDEX idx_students_year_dept ON students(admission_year, department_id);
CREATE INDEX idx_students_status ON students(status, current_year_of_study);
CREATE INDEX idx_faculty_emp ON faculty(employee_code);
CREATE INDEX idx_faculty_dept ON faculty(department_id, employment_status);
CREATE INDEX idx_fa_lookup ON faculty_allocations(department_id, role_type, academic_year_id);
CREATE INDEX idx_att_lookup ON attendance(student_id, session_date);
CREATE INDEX idx_mrk_lookup ON marks(student_id, examination_id);
CREATE INDEX idx_users_login ON users(email, account_status);
