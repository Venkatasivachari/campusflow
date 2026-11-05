import os
import pandas as pd

def generate():
    base_dir = os.path.join(os.path.dirname(__file__), "..", "database")
    data_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    os.makedirs(base_dir, exist_ok=True)

    # --------------------------------------------------------------------------
    # 1. college_database_schema.sql
    # --------------------------------------------------------------------------
    schema_sql = """-- ==============================================================================
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
"""

    with open(os.path.join(base_dir, "college_database_schema.sql"), "w", encoding="utf-8") as f:
        f.write(schema_sql)
    print("Generated college_database_schema.sql")

    # --------------------------------------------------------------------------
    # 2. faculty_student_allocation.sql
    # --------------------------------------------------------------------------
    alloc_sql = """-- ==============================================================================
-- IMPERIAL INSTITUTE - FACULTY-STUDENT ALLOCATION & ACADEMIC HIERARCHY
-- Implements complete mapping:
-- Institution -> Department -> Academic Year -> Batch -> Section
--             -> Class Coordinator -> Class Mentor -> Subject Faculty -> Students
-- ==============================================================================

USE college_management_system;

-- 1. Active Faculty Allocations View
CREATE OR REPLACE VIEW v_active_faculty_allocations AS
SELECT 
    fa.id AS allocation_id,
    f.employee_code,
    f.full_name AS faculty_name,
    d.department_code,
    d.department_name,
    fa.role_type,
    ay.year_name AS academic_year,
    sem.semester_number,
    sec.section_name,
    sub.subject_code,
    sub.subject_name,
    COUNT(DISTINCT s.id) AS assigned_students_count
FROM faculty_allocations fa
JOIN faculty f ON fa.faculty_id = f.id
JOIN departments d ON fa.department_id = d.id
JOIN academic_years ay ON fa.academic_year_id = ay.id
JOIN semesters sem ON fa.semester_id = sem.id
LEFT JOIN sections sec ON fa.section_id = sec.id
LEFT JOIN subjects sub ON fa.subject_id = sub.id
LEFT JOIN students s ON s.section_id = sec.id AND s.status = 'ACTIVE'
WHERE fa.allocation_status = 'ACTIVE'
GROUP BY fa.id, f.employee_code, f.full_name, d.department_code, d.department_name,
         fa.role_type, ay.year_name, sem.semester_number, sec.section_name,
         sub.subject_code, sub.subject_name;

-- 2. Student Mentor & Coordinator Mapping View
CREATE OR REPLACE VIEW v_student_academic_advisors AS
SELECT 
    s.id AS student_id,
    s.registration_number,
    s.full_name AS student_name,
    s.gender,
    d.department_code,
    s.current_year_of_study,
    s.current_semester,
    sec.section_name,
    hod.full_name AS hod_name,
    hod.email AS hod_email,
    coord.full_name AS class_coordinator_name,
    coord.email AS coordinator_email,
    mentor.full_name AS mentor_name,
    mentor.email AS mentor_email,
    mentor.phone AS mentor_phone
FROM students s
JOIN departments d ON s.department_id = d.id
JOIN sections sec ON s.section_id = sec.id
-- HOD mapping
LEFT JOIN faculty hod ON hod.department_id = d.id AND hod.designation LIKE '%HOD%'
-- Class Coordinator mapping
LEFT JOIN faculty_allocations fa_coord ON fa_coord.section_id = sec.id 
     AND fa_coord.role_type = 'CLASS_COORDINATOR' AND fa_coord.allocation_status = 'ACTIVE'
LEFT JOIN faculty coord ON fa_coord.faculty_id = coord.id
-- Class Mentor mapping
LEFT JOIN faculty_allocations fa_mentor ON fa_mentor.student_id = s.id 
     AND fa_mentor.role_type = 'MENTOR' AND fa_mentor.allocation_status = 'ACTIVE'
LEFT JOIN faculty mentor ON fa_mentor.faculty_id = mentor.id
WHERE s.status = 'ACTIVE';

-- 3. Stored Procedure: Allocate Faculty to Section and Students
DELIMITER //

DROP PROCEDURE IF EXISTS sp_allocate_faculty_cohort //
CREATE PROCEDURE sp_allocate_faculty_cohort(
    IN in_faculty_id BIGINT,
    IN in_section_id BIGINT,
    IN in_role_type VARCHAR(32),
    IN in_ay_id BIGINT,
    IN in_sem_id BIGINT
)
BEGIN
    DECLARE v_dept_id BIGINT;
    SELECT department_id INTO v_dept_id FROM sections WHERE id = in_section_id;

    -- Create Section Allocation
    INSERT INTO faculty_allocations (faculty_id, department_id, academic_year_id, semester_id, section_id, role_type, start_date)
    VALUES (in_faculty_id, v_dept_id, in_ay_id, in_sem_id, in_section_id, in_role_type, CURDATE());

    -- If Role is MENTOR, link each student in section to this mentor
    IF in_role_type = 'MENTOR' THEN
        INSERT INTO faculty_allocations (faculty_id, student_id, department_id, academic_year_id, semester_id, section_id, role_type, start_date)
        SELECT in_faculty_id, s.id, v_dept_id, in_ay_id, in_sem_id, in_section_id, 'MENTOR', CURDATE()
        FROM students s
        WHERE s.section_id = in_section_id AND s.status = 'ACTIVE';
    END IF;
END //

DELIMITER ;
"""
    with open(os.path.join(base_dir, "faculty_student_allocation.sql"), "w", encoding="utf-8") as f:
        f.write(alloc_sql)
    print("Generated faculty_student_allocation.sql")

    # --------------------------------------------------------------------------
    # 3. historical_analytics.sql
    # --------------------------------------------------------------------------
    history_sql = """-- ==============================================================================
-- IMPERIAL INSTITUTE - HISTORICAL ANALYTICS & EXECUTIVE REPORTS (2015-2026)
-- Complete reporting suite across 12 Annual Cohorts, 9,000 Students
-- ==============================================================================

USE college_management_system;

-- 1. Historical Cohort Progression Summary (2015-2026)
CREATE OR REPLACE VIEW v_historical_cohort_progression AS
SELECT 
    s.admission_year,
    CONCAT(s.admission_year, '–', RIGHT(s.admission_year + 1, 2)) AS admission_batch,
    COUNT(s.id) AS total_admissions,
    SUM(CASE WHEN s.gender = 'Male' THEN 1 ELSE 0 END) AS male_students,
    SUM(CASE WHEN s.gender = 'Female' THEN 1 ELSE 0 END) AS female_students,
    ROUND(SUM(CASE WHEN s.gender = 'Female' THEN 1 ELSE 0 END) * 100.0 / COUNT(s.id), 2) AS female_percentage,
    SUM(CASE WHEN s.status = 'GRADUATED' THEN 1 ELSE 0 END) AS graduated_count,
    SUM(CASE WHEN s.status = 'ACTIVE' THEN 1 ELSE 0 END) AS currently_enrolled_count,
    SUM(CASE WHEN s.status = 'DISCONTINUED' THEN 1 ELSE 0 END) AS discontinued_count,
    ROUND(AVG(sah.cgpa), 2) AS average_cgpa,
    ROUND(AVG(sah.attendance_pct), 1) AS average_attendance_pct
FROM students s
LEFT JOIN student_academic_history sah ON sah.student_id = s.id
GROUP BY s.admission_year
ORDER BY s.admission_year DESC;

-- 2. Department-Wise Historical Strength
CREATE OR REPLACE VIEW v_department_historical_strength AS
SELECT 
    s.admission_year,
    d.department_code,
    d.department_name,
    COUNT(s.id) AS enrolled_students,
    SUM(CASE WHEN s.gender = 'Male' THEN 1 ELSE 0 END) AS males,
    SUM(CASE WHEN s.gender = 'Female' THEN 1 ELSE 0 END) AS females,
    SUM(CASE WHEN s.status = 'ACTIVE' THEN 1 ELSE 0 END) AS active_students,
    SUM(CASE WHEN s.status = 'GRADUATED' THEN 1 ELSE 0 END) AS graduated_alumni
FROM students s
JOIN departments d ON s.department_id = d.id
GROUP BY s.admission_year, d.department_code, d.department_name
ORDER BY s.admission_year DESC, d.department_code ASC;

-- 3. Current 1st to 4th Year Student Strength (Active Enrolled)
CREATE OR REPLACE VIEW v_current_academic_year_strength AS
SELECT 
    s.current_year_of_study,
    s.current_semester,
    d.department_code,
    COUNT(s.id) AS student_count,
    SUM(CASE WHEN s.gender = 'Male' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN s.gender = 'Female' THEN 1 ELSE 0 END) AS female_count,
    ROUND(AVG(sah.cgpa), 2) AS avg_cgpa,
    ROUND(AVG(sah.attendance_pct), 1) AS avg_attendance
FROM students s
JOIN departments d ON s.department_id = d.id
LEFT JOIN student_academic_history sah ON sah.student_id = s.id
WHERE s.status = 'ACTIVE'
GROUP BY s.current_year_of_study, s.current_semester, d.department_code
ORDER BY s.current_semester ASC, d.department_code ASC;

-- 4. Institutional Faculty-to-Student Ratios
CREATE OR REPLACE VIEW v_institutional_faculty_ratios AS
SELECT 
    d.department_code,
    d.department_name,
    COUNT(DISTINCT f.id) AS total_faculty,
    COUNT(DISTINCT CASE WHEN s.status = 'ACTIVE' THEN s.id END) AS active_students,
    ROUND(COUNT(DISTINCT CASE WHEN s.status = 'ACTIVE' THEN s.id END) / GREATEST(COUNT(DISTINCT f.id), 1), 1) AS student_faculty_ratio,
    SUM(CASE WHEN f.designation LIKE '%Professor%' AND f.designation NOT LIKE '%Assistant%' THEN 1 ELSE 0 END) AS professors,
    SUM(CASE WHEN f.designation LIKE '%Assistant%' THEN 1 ELSE 0 END) AS assistant_professors
FROM departments d
LEFT JOIN faculty f ON f.department_id = d.id AND f.employment_status = 'ACTIVE'
LEFT JOIN students s ON s.department_id = d.id
GROUP BY d.department_code, d.department_name;

-- 5. Financial Tuition Revenue & Outstanding Balances Summary
CREATE OR REPLACE VIEW v_financial_revenue_summary AS
SELECT 
    s.admission_year,
    d.department_code,
    COUNT(sfa.id) AS total_student_accounts,
    SUM(sfa.total_payable) AS gross_tuition_billed,
    SUM(sfa.total_paid) AS total_tuition_collected,
    SUM(sfa.balance_due) AS total_tuition_outstanding,
    ROUND(SUM(sfa.total_paid) * 100.0 / GREATEST(SUM(sfa.total_payable), 1), 1) AS collection_percentage
FROM student_fee_accounts sfa
JOIN students s ON sfa.student_id = s.id
JOIN departments d ON s.department_id = d.id
GROUP BY s.admission_year, d.department_code
ORDER BY s.admission_year DESC, d.department_code ASC;
"""
    with open(os.path.join(base_dir, "historical_analytics.sql"), "w", encoding="utf-8") as f:
        f.write(history_sql)
    print("Generated historical_analytics.sql")

    # --------------------------------------------------------------------------
    # 4. Generate master sample_data.sql with 9,000 Students & 60 Faculty
    # --------------------------------------------------------------------------
    print("Reading enriched student dataset...")
    enriched_df = pd.read_excel(os.path.join(data_dir, "enriched_student_dataset.xlsx"))
    faculty_df = pd.read_excel(os.path.join(data_dir, "faculty_demo_dataset.xlsx"))

    # Password hashes
    owner_hash = "$2b$12$w26zKtTNmtSoLiKfZ1/tu.f2NFXHSKHXLCTfORWge9YTdzBAQwFRu"
    admin_hash = "$2b$12$rd/jnbF/5dat4VgWlr.j/OVsDunUuSGqhgzsw//DnCrQmOyf.u5oq"
    demo_hash  = "$2b$12$r6aBSC3sD0sVfV2.GypzwucbnRe6plUnNG1997YhpSOvEQnKtUVF."

    sql_parts = []
    sql_parts.append("""-- ==============================================================================
-- IMPERIAL INSTITUTE - COMPLETE SAMPLE DATA POPULATION (2015-2026)
-- Populates 1 Institution, 1 Root Owner, Administrators, 60 Faculty Members,
-- and 9,000 Enriched Students from student_dataset_v1.xlsx
-- ==============================================================================

USE college_management_system;

SET FOREIGN_KEY_CHECKS = 0;

-- 1. INSTITUTION
INSERT INTO institutions (id, name, code, established_year, email, phone, website, address) VALUES
(1, 'Imperial Institute of Technology and Management', 'IITM-2026', 2014, 'chancellor@college.local', '+91 98490 12345', 'https://imperial.edu.in', 'Tech Knowledge Park, Cyber City, Hyderabad, India')
ON DUPLICATE KEY UPDATE name=VALUES(name);

-- 2. DEPARTMENTS
INSERT INTO departments (id, department_code, department_name, status, established_year) VALUES
(1, 'CSE', 'Computer Science and Engineering', 'ACTIVE', 2014),
(2, 'ECE', 'Electronics and Communication Engineering', 'ACTIVE', 2014),
(3, 'IT', 'Information Technology', 'ACTIVE', 2014),
(4, 'EEE', 'Electrical and Electronics Engineering', 'ACTIVE', 2014),
(5, 'MECH', 'Mechanical Engineering', 'ACTIVE', 2014),
(6, 'CIVIL', 'Civil Engineering', 'ACTIVE', 2014)
ON DUPLICATE KEY UPDATE department_name=VALUES(department_name);

-- 3. COURSES & DEGREE
INSERT INTO courses (id, course_code, course_name, degree, duration_years, total_semesters) VALUES
(1, 'BTECH-CSE', 'Bachelor of Technology in Computer Science', 'B.Tech', 4, 8),
(2, 'BTECH-ECE', 'Bachelor of Technology in Electronics & Comm', 'B.Tech', 4, 8),
(3, 'BTECH-IT', 'Bachelor of Technology in Information Technology', 'B.Tech', 4, 8),
(4, 'BTECH-EEE', 'Bachelor of Technology in Electrical & Electronics', 'B.Tech', 4, 8),
(5, 'BTECH-MECH', 'Bachelor of Technology in Mechanical Engineering', 'B.Tech', 4, 8),
(6, 'BTECH-CIVIL', 'Bachelor of Technology in Civil Engineering', 'B.Tech', 4, 8)
ON DUPLICATE KEY UPDATE course_name=VALUES(course_name);

-- 4. ACADEMIC YEARS (2015 to 2027)
INSERT INTO academic_years (id, year_name, start_date, end_date, is_current) VALUES
(1, '2015–16', '2015-07-01', '2016-06-30', FALSE),
(2, '2016–17', '2016-07-01', '2017-06-30', FALSE),
(3, '2017–18', '2017-07-01', '2018-06-30', FALSE),
(4, '2018–19', '2018-07-01', '2019-06-30', FALSE),
(5, '2019–20', '2019-07-01', '2020-06-30', FALSE),
(6, '2020–21', '2020-07-01', '2021-06-30', FALSE),
(7, '2021–22', '2021-07-01', '2022-06-30', FALSE),
(8, '2022–23', '2022-07-01', '2023-06-30', FALSE),
(9, '2023–24', '2023-07-01', '2024-06-30', FALSE),
(10, '2024–25', '2024-07-01', '2025-06-30', FALSE),
(11, '2025–26', '2025-07-01', '2026-06-30', FALSE),
(12, '2026–27', '2026-07-01', '2027-06-30', TRUE)
ON DUPLICATE KEY UPDATE year_name=VALUES(year_name);

-- 5. SEMESTERS FOR CURRENT AY (2026-27)
INSERT INTO semesters (id, semester_number, academic_year_id, term_type) VALUES
(1, 1, 12, 'ODD'), (2, 2, 12, 'EVEN'),
(3, 3, 12, 'ODD'), (4, 4, 12, 'EVEN'),
(5, 5, 12, 'ODD'), (6, 6, 12, 'EVEN'),
(7, 7, 12, 'ODD'), (8, 8, 12, 'EVEN')
ON DUPLICATE KEY UPDATE semester_number=VALUES(semester_number);

-- 6. DESIGNATIONS
INSERT INTO designations (id, designation_name, hierarchy_level, category) VALUES
(1, 'Chancellor / Root Owner', 1, 'GOVERNANCE'),
(2, 'Principal / Director', 2, 'EXECUTIVE'),
(3, 'Dean of Academics', 3, 'ACADEMIC'),
(4, 'Professor & HOD', 4, 'DEPARTMENT_HEAD'),
(5, 'Professor', 5, 'TEACHING'),
(6, 'Associate Professor', 6, 'TEACHING'),
(7, 'Assistant Professor', 7, 'TEACHING')
ON DUPLICATE KEY UPDATE designation_name=VALUES(designation_name);

-- 7. ROLES & PERMISSIONS
INSERT INTO roles (id, role_code, role_name, description) VALUES
(1, 'ROLE_OWNER', 'Root Owner', 'Supreme Authority'),
(2, 'ROLE_SUPER_ADMIN', 'Super Admin', 'Platform Tech Administrator'),
(3, 'ROLE_PRINCIPAL', 'Principal', 'Executive Head'),
(4, 'ROLE_DEAN', 'Dean', 'Dean of Academics'),
(5, 'ROLE_ADMIN', 'Admin', 'Institutional Operations'),
(6, 'ROLE_HOD', 'HOD', 'Department Head'),
(7, 'ROLE_FACULTY', 'Faculty', 'Teaching Staff'),
(8, 'ROLE_STUDENT', 'Student', 'Enrolled Student')
ON DUPLICATE KEY UPDATE role_name=VALUES(role_name);

-- 8. ROOT OWNER & ADMINISTRATIVE USERS
INSERT INTO users (id, public_id, email, password_hash, role, account_status, must_change_password) VALUES
(1, 'USR_OWN_001', 'owner@college.local', '""" + owner_hash + """', 'OWNER', 'ACTIVE', FALSE),
(2, 'USR_ADM_001', 'admin@college.local', '""" + admin_hash + """', 'ADMIN', 'ACTIVE', FALSE),
(3, 'USR_PRN_001', 'principal@college.local', '""" + admin_hash + """', 'ADMIN', 'ACTIVE', FALSE),
(4, 'USR_DEN_001', 'dean.academic@college.local', '""" + admin_hash + """', 'ADMIN', 'ACTIVE', FALSE)
ON DUPLICATE KEY UPDATE password_hash=VALUES(password_hash);

-- Root Owner Record
INSERT INTO owners (id, user_id, owner_id, full_name, email, phone, designation, status, institution_id) VALUES
(1, 1, 'OWN0001', 'Dr. Rajeshwar Rao', 'owner@college.local', '+91 98490 12345', 'Root Owner & Chancellor', 'ACTIVE', 1)
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);

-- Root Owner Singleton Enforcement
INSERT INTO root_owner_control (singleton_id, user_id, owner_id) VALUES
(1, 1, 'OWN0001')
ON DUPLICATE KEY UPDATE owner_id='OWN0001';

INSERT INTO ownership_history (id, previous_owner_id, new_owner_id, approved_by, transfer_reason) VALUES
(1, 'NONE', 'OWN0001', 'SYSTEM_INIT', 'Initial Foundation of Imperial Institute')
ON DUPLICATE KEY UPDATE new_owner_id='OWN0001';
""")

    # 9. FACULTY SEED (60 Faculty)
    print("Generating SQL for Faculty...")
    sql_parts.append("\n-- 9. FACULTY USERS & PROFILES (60 MEMBERS)\n")
    
    dept_map = {"CSE": 1, "ECE": 2, "IT": 3, "EEE": 4, "MECH": 5, "CIVIL": 6}
    
    fac_user_ids = []
    for f_idx, f in faculty_df.iterrows():
        uid = 100 + f_idx + 1
        fac_user_ids.append(uid)
        sql_parts.append(f"""INSERT INTO users (id, public_id, email, password_hash, role, account_status) VALUES
({uid}, 'USR_FAC_{f_idx+1:03d}', '{f['Official_Email']}', '{demo_hash}', 'FACULTY', 'ACTIVE')
ON DUPLICATE KEY UPDATE email=VALUES(email);
INSERT INTO faculty (id, user_id, employee_code, full_name, gender, email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, employment_status, data_status) VALUES
({f_idx+1}, {uid}, '{f['Employee_ID']}', '{f['Full_Name']}', '{f['Gender']}', '{f['Official_Email']}', '{f['Phone_No']}', {dept_map[f['Department_Code']]}, '{f['Designation']}', '{f['Highest_Qualification']}', '{f['Specialization']}', '{f['Joining_Date']}', {f['Experience_Years']}, 'ACTIVE', 'SYNTHETIC_DEMO')
ON DUPLICATE KEY UPDATE full_name=VALUES(full_name);
INSERT INTO faculty_salary_history (faculty_id, basic_salary, gross_salary, net_salary, effective_from) VALUES
({f_idx+1}, {f['Basic_Salary']}, {f['Gross_Salary']}, {f['Net_Salary']}, '{f['Joining_Date']}')
ON DUPLICATE KEY UPDATE gross_salary=VALUES(gross_salary);
""")

    # 10. BATCHES & SECTIONS
    print("Generating Batches & Sections...")
    sql_parts.append("\n-- 10. STUDENT BATCHES & SECTIONS\n")
    b_id = 1
    sec_id = 1
    batch_map = {} # (adm_year, dept_id) -> batch_id
    section_map = {} # (batch_id, sec_letter) -> sec_id

    for adm_year in range(2015, 2027):
        for d_code, d_id in dept_map.items():
            b_code = f"BATCH-{adm_year}-{d_code}"
            sql_parts.append(f"""INSERT INTO student_batches (id, batch_code, admission_year, graduation_year, department_id) VALUES
({b_id}, '{b_code}', {adm_year}, {adm_year+4}, {d_id}) ON DUPLICATE KEY UPDATE batch_code=VALUES(batch_code);
""")
            batch_map[(adm_year, d_id)] = b_id
            
            for sec_letter in ["A", "B", "C"]:
                sql_parts.append(f"""INSERT INTO sections (id, batch_id, section_name, capacity, department_id) VALUES
({sec_id}, {b_id}, 'Section {sec_letter}', 60, {d_id}) ON DUPLICATE KEY UPDATE section_name=VALUES(section_name);
""")
                section_map[(b_id, sec_letter)] = sec_id
                sec_id += 1
            b_id += 1

    # 11. FEE STRUCTURES
    sql_parts.append("\n-- 11. FEE STRUCTURES\n")
    for adm_year in range(2015, 2027):
        for d_code, d_id in dept_map.items():
            fs_id = (adm_year - 2015) * 6 + d_id
            sql_parts.append(f"""INSERT INTO fee_structures (id, department_id, admission_year, tuition_fee, lab_fee, development_fee, total_annual_fee) VALUES
({fs_id}, {d_id}, {adm_year}, 75000.00, 5000.00, 5000.00, 85000.00) ON DUPLICATE KEY UPDATE total_annual_fee=VALUES(total_annual_fee);
""")

    # 12. 9,000 STUDENTS, SOURCE RECORDS, ACCOUNTS, & ACADEMIC STATUS
    print("Generating SQL bulk statements for 9,000 students...")
    sql_parts.append("\n-- 12. 9,000 STUDENTS & SOURCE DATA INTEGRATION\n")

    # In chunks of 500 rows for high-speed MySQL Workbench execution
    chunk_size = 500
    for start in range(0, len(enriched_df), chunk_size):
        chunk = enriched_df.iloc[start:start+chunk_size]
        
        # Insert student_source_records
        src_vals = []
        user_vals = []
        student_vals = []
        sah_vals = []
        sfa_vals = []

        for _, row in chunk.iterrows():
            sid = int(row['Student_Database_ID'])
            uid = 1000 + sid
            d_id = dept_map[row['Department_Code']]
            b_id = batch_map[(int(row['Admission_Year']), d_id)]
            sec_letter = row['Section'].replace('Section ', '')
            sc_id = section_map[(b_id, sec_letter)]
            ay_id = int(row['Admission_Year']) - 2015 + 1
            fs_id = (int(row['Admission_Year']) - 2015) * 6 + d_id

            # Escape quotes
            orig_name = str(row['Original_Name']).replace("'", "''")
            clean_name = str(row['Cleaned_Name']).replace("'", "''")
            phone = str(row['Phone_No']).replace("'", "''")

            src_vals.append(f"({sid}, {sid}, '{orig_name}', '{phone}', '{row['Gender']}', FALSE, 'INITIAL_EXCEL_V1')")
            user_vals.append(f"({uid}, 'USR_STU_{sid:06d}', '{row['Institutional_Email']}', '{demo_hash}', 'STUDENT', 'ACTIVE')")
            student_vals.append(f"({sid}, {uid}, {sid}, '{row['Student_ID']}', '{row['Admission_Number']}', '{row['Registration_Number']}', '{row['Roll_Number']}', '{orig_name}', '{clean_name}', '{row['Gender']}', '{row['Institutional_Email']}', '{phone}', {d_id}, {d_id}, {b_id}, {row['Admission_Year']}, {row['Expected_Graduation_Year']}, '{row['Current_Year_of_Study']}', {row['Current_Semester']}, {sc_id}, '{row['Academic_Status']}', 'EXCEL_SOURCE_VERIFIED', 'SYNTHETIC_ACADEMIC_DEMO')")
            sah_vals.append(f"({sid}, {sid}, {ay_id}, {row['Current_Semester']}, '{row['Current_Year_of_Study']}', {sc_id}, 'PROMOTED', {row['CGPA']}, {row['Attendance_Percentage']})")
            sfa_vals.append(f"({sid}, {sid}, {fs_id}, {row['Total_Fee_Payable']}, {row['Total_Fee_Paid']}, {row['Fee_Balance_Due']}, '{row['Fee_Status']}')")

        sql_parts.append(f"INSERT INTO student_source_records (id, source_row_index, source_name, source_phone, source_gender, has_encoding_anomaly, import_batch_ref) VALUES\n" + ",\n".join(src_vals) + "\nON DUPLICATE KEY UPDATE source_name=VALUES(source_name);\n")
        sql_parts.append(f"INSERT INTO users (id, public_id, email, password_hash, role, account_status) VALUES\n" + ",\n".join(user_vals) + "\nON DUPLICATE KEY UPDATE email=VALUES(email);\n")
        sql_parts.append(f"INSERT INTO students (id, user_id, source_record_id, student_id, admission_number, registration_number, roll_number, full_name, display_name, gender, email, phone, department_id, course_id, batch_id, admission_year, graduation_year, current_year_of_study, current_semester, section_id, status, data_origin, academic_data_type) VALUES\n" + ",\n".join(student_vals) + "\nON DUPLICATE KEY UPDATE display_name=VALUES(display_name);\n")
        sql_parts.append(f"INSERT INTO student_academic_history (id, student_id, academic_year_id, semester_id, year_of_study, section_id, status, cgpa, attendance_pct) VALUES\n" + ",\n".join(sah_vals) + "\nON DUPLICATE KEY UPDATE cgpa=VALUES(cgpa);\n")
        sql_parts.append(f"INSERT INTO student_fee_accounts (id, student_id, fee_structure_id, total_payable, total_paid, balance_due, payment_status) VALUES\n" + ",\n".join(sfa_vals) + "\nON DUPLICATE KEY UPDATE total_paid=VALUES(total_paid);\n")

    sql_parts.append("\nSET FOREIGN_KEY_CHECKS = 1;\n-- END OF SCRIPT\n")

    content = "".join(sql_parts)
    out_path = os.path.join(base_dir, "sample_data.sql")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(content)
    print(f"Generated sample_data.sql ({len(content)} bytes)")

if __name__ == "__main__":
    generate()

