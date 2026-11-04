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

INSERT INTO institutions (id, name, code, website, address) VALUES
(1, 'Imperial Institute of Technology and Management', 'IITM-2026', 'https://imperial.edu.in', 'Tech Knowledge Park, Cyber City, Hyderabad, India');

CREATE TABLE departments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    description TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

INSERT INTO departments (id, code, name, description) VALUES
(1, 'CSE', 'Computer Science and Engineering', 'Department of Computer Science and Engineering'),
(2, 'ECE', 'Electronics and Communication Engineering', 'Department of Electronics and Communication'),
(3, 'EEE', 'Electrical and Electronics Engineering', 'Department of Electrical and Electronics'),
(4, 'MECH', 'Mechanical Engineering', 'Department of Mechanical Engineering'),
(5, 'CIVIL', 'Civil Engineering', 'Department of Civil Engineering'),
(6, 'IT', 'Information Technology', 'Department of Information Technology');

CREATE TABLE programmes (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(32) NOT NULL UNIQUE,
    name VARCHAR(128) NOT NULL,
    department_id BIGINT NOT NULL,
    duration_years INT NOT NULL DEFAULT 4,
    total_semesters INT NOT NULL DEFAULT 8,
    degree_type VARCHAR(32) NOT NULL DEFAULT 'B.Tech',
    FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

INSERT INTO programmes (id, code, name, department_id, duration_years, total_semesters, degree_type) VALUES
(1, 'BTECH-CSE', 'Bachelor of Technology in Computer Science', 1, 4, 8, 'B.Tech'),
(2, 'BTECH-ECE', 'Bachelor of Technology in Electronics & Comm', 2, 4, 8, 'B.Tech'),
(3, 'BTECH-EEE', 'Bachelor of Technology in Electrical & Electronics', 3, 4, 8, 'B.Tech'),
(4, 'BTECH-MECH', 'Bachelor of Technology in Mechanical Engg', 4, 4, 8, 'B.Tech'),
(5, 'BTECH-CIVIL', 'Bachelor of Technology in Civil Engineering', 5, 4, 8, 'B.Tech'),
(6, 'BTECH-IT', 'Bachelor of Technology in Information Technology', 6, 4, 8, 'B.Tech');

-- ------------------------------------------------------------------------------
-- 2. ACADEMIC YEARS & BATCHES (2015 - 2026)
-- ------------------------------------------------------------------------------
CREATE TABLE academic_years (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(32) NOT NULL UNIQUE,
    start_date DATE NOT NULL,
    end_date DATE NOT NULL,
    is_current BOOLEAN NOT NULL DEFAULT FALSE
) ENGINE=InnoDB;

INSERT INTO academic_years (name, start_date, end_date, is_current) VALUES
('2015-2016', '2015-08-01', '2016-05-31', FALSE),
('2016-2017', '2016-08-01', '2017-05-31', FALSE),
('2017-2018', '2017-08-01', '2018-05-31', FALSE),
('2018-2019', '2018-08-01', '2019-05-31', FALSE),
('2019-2020', '2019-08-01', '2020-05-31', FALSE),
('2020-2021', '2020-08-01', '2021-05-31', FALSE),
('2021-2022', '2021-08-01', '2022-05-31', FALSE),
('2022-2023', '2022-08-01', '2023-05-31', FALSE),
('2023-2024', '2023-08-01', '2024-05-31', FALSE),
('2024-2025', '2024-08-01', '2025-05-31', FALSE),
('2025-2026', '2025-08-01', '2026-05-31', TRUE),
('2026-2027', '2026-08-01', '2027-05-31', FALSE);

CREATE TABLE batches (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL,
    department_id BIGINT NOT NULL,
    start_year INT NOT NULL,
    end_year INT NOT NULL,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE sections (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(16) NOT NULL,
    batch_id BIGINT NOT NULL,
    capacity INT NOT NULL DEFAULT 60,
    FOREIGN KEY (batch_id) REFERENCES batches(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 3. USERS, ROLES & PERMISSIONS
-- ------------------------------------------------------------------------------
CREATE TABLE roles (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(64) NOT NULL UNIQUE,
    description VARCHAR(255) NULL
) ENGINE=InnoDB;

INSERT INTO roles (id, name, description) VALUES
(1, 'ROLE_OWNER', 'Root Owner / Supreme institutional governance and full system control'),
(2, 'ROLE_SUPER_ADMIN', 'Super Administrator with system-wide configuration rights'),
(3, 'ROLE_PRINCIPAL', 'Principal / Director presiding over campus administration and deans'),
(4, 'ROLE_DEAN', 'Academic Dean coordinating academic operations'),
(5, 'ROLE_ADMIN', 'General institutional management officer'),
(6, 'ROLE_HOD', 'Head of Department managing faculty, curriculum, and students'),
(7, 'ROLE_FACULTY', 'Faculty member handling classes, attendance, grading, and mentorship'),
(8, 'ROLE_STUDENT', 'Student participating in coursework, submissions, and feedback');

CREATE TABLE users (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(191) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    role VARCHAR(32) NOT NULL,
    must_change_password BOOLEAN NOT NULL DEFAULT FALSE,
    is_blocked BOOLEAN NOT NULL DEFAULT FALSE,
    failed_login_count INT NOT NULL DEFAULT 0,
    lockout_until DATETIME NULL,
    last_login_at DATETIME NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 4. ROOT OWNER & EXECUTIVE PROFILES
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
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
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
-- 5. FACULTY & HR
-- ------------------------------------------------------------------------------
CREATE TABLE faculty (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    employee_id VARCHAR(32) NOT NULL UNIQUE,
    full_name VARCHAR(128) NOT NULL,
    college_email VARCHAR(191) NOT NULL UNIQUE,
    personal_email VARCHAR(191),
    phone VARCHAR(32) NOT NULL,
    dob DATE,
    gender VARCHAR(16),
    department_id BIGINT NOT NULL,
    designation VARCHAR(64) NOT NULL,
    qualification VARCHAR(128) NOT NULL,
    specialization VARCHAR(128) NOT NULL,
    joining_date DATE NOT NULL,
    experience_years INT NOT NULL DEFAULT 5,
    employment_type VARCHAR(32) NOT NULL DEFAULT 'PERMANENT',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 6. STUDENTS & ACADEMICS
-- ------------------------------------------------------------------------------
CREATE TABLE students (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL UNIQUE,
    registration_number VARCHAR(32) NOT NULL UNIQUE,
    roll_number VARCHAR(32) NOT NULL,
    full_name VARCHAR(128) NOT NULL,
    college_email VARCHAR(191) NOT NULL,
    personal_email VARCHAR(191),
    phone VARCHAR(32) NOT NULL,
    dob DATE NOT NULL,
    gender VARCHAR(16) NOT NULL,
    address TEXT NOT NULL,
    programme_id BIGINT NOT NULL,
    department_id BIGINT NOT NULL,
    admission_year INT NOT NULL,
    expected_graduation_year INT NOT NULL,
    current_semester INT NOT NULL DEFAULT 1,
    current_year_of_study INT NOT NULL DEFAULT 1,
    section_id BIGINT NULL,
    admission_type VARCHAR(32) NOT NULL DEFAULT 'REGULAR',
    status VARCHAR(32) NOT NULL DEFAULT 'ACTIVE',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    deleted_at DATETIME NULL,
    FOREIGN KEY (user_id) REFERENCES users(id),
    FOREIGN KEY (programme_id) REFERENCES programmes(id),
    FOREIGN KEY (department_id) REFERENCES departments(id)
) ENGINE=InnoDB;

CREATE TABLE student_parent_info (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL UNIQUE,
    father_name VARCHAR(128),
    father_phone VARCHAR(32),
    mother_name VARCHAR(128),
    mother_phone VARCHAR(32),
    guardian_name VARCHAR(128),
    guardian_phone VARCHAR(32),
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE student_academic_status (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id BIGINT NOT NULL UNIQUE,
    current_cgpa DECIMAL(4,2) DEFAULT 7.50,
    total_credits_earned INT DEFAULT 20,
    attendance_percentage DECIMAL(5,2) DEFAULT 85.00,
    active_arrears_count INT DEFAULT 0,
    FOREIGN KEY (student_id) REFERENCES students(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 7. FEES & FINANCE
-- ------------------------------------------------------------------------------
CREATE TABLE fee_structures (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    programme_id BIGINT NOT NULL,
    semester_number INT NOT NULL,
    academic_year VARCHAR(32) NOT NULL,
    tuition_fee DECIMAL(10,2) NOT NULL,
    exam_fee DECIMAL(10,2) NOT NULL DEFAULT 2000.00,
    library_fee DECIMAL(10,2) NOT NULL DEFAULT 1500.00,
    total_amount DECIMAL(10,2) NOT NULL,
    due_date DATE NOT NULL,
    FOREIGN KEY (programme_id) REFERENCES programmes(id)
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
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (fee_structure_id) REFERENCES fee_structures(id)
) ENGINE=InnoDB;

CREATE TABLE fee_payments (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_fee_id BIGINT NOT NULL,
    receipt_number VARCHAR(64) NOT NULL UNIQUE,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_mode VARCHAR(32) NOT NULL,
    payment_date DATE NOT NULL,
    status VARCHAR(32) NOT NULL DEFAULT 'SUCCESS',
    FOREIGN KEY (student_fee_id) REFERENCES student_fees(id)
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 8. AUDIT LOGS & NOTIFICATIONS
-- ------------------------------------------------------------------------------
CREATE TABLE audit_logs (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NULL,
    action VARCHAR(64) NOT NULL,
    entity_name VARCHAR(64) NOT NULL,
    entity_id VARCHAR(64) NULL,
    details TEXT NULL,
    ip_address VARCHAR(45) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

CREATE TABLE notifications (
    id BIGINT AUTO_INCREMENT PRIMARY KEY,
    recipient_id BIGINT NOT NULL,
    title VARCHAR(128) NOT NULL,
    message TEXT NOT NULL,
    type VARCHAR(32) NOT NULL DEFAULT 'INFO',
    is_read BOOLEAN NOT NULL DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (recipient_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB;

-- ------------------------------------------------------------------------------
-- 9. ANALYTICAL VIEWS
-- ------------------------------------------------------------------------------
CREATE OR REPLACE VIEW v_historical_enrollment_summary AS
SELECT 
    s.admission_year,
    d.code AS department_code,
    d.name AS department_name,
    s.gender,
    s.status,
    s.current_year_of_study,
    COUNT(s.id) AS student_count,
    ROUND(AVG(COALESCE(att.current_cgpa, 7.5)), 2) AS avg_cgpa,
    ROUND(AVG(COALESCE(att.attendance_percentage, 82.0)), 1) AS avg_attendance
FROM students s
JOIN departments d ON d.id = s.department_id
LEFT JOIN student_academic_status att ON att.student_id = s.id
GROUP BY s.admission_year, d.code, d.name, s.gender, s.status, s.current_year_of_study;

CREATE OR REPLACE VIEW v_department_faculty_ratios AS
SELECT 
    d.id AS department_id,
    d.code AS department_code,
    d.name AS department_name,
    COUNT(DISTINCT f.id) AS total_faculty,
    COUNT(DISTINCT s.id) AS total_active_students,
    ROUND(COUNT(DISTINCT s.id) / GREATEST(COUNT(DISTINCT f.id), 1), 1) AS student_faculty_ratio
FROM departments d
LEFT JOIN faculty f ON f.department_id = d.id AND f.deleted_at IS NULL
LEFT JOIN students s ON s.department_id = d.id AND s.status = 'ACTIVE' AND s.deleted_at IS NULL
GROUP BY d.id, d.code, d.name;

CREATE OR REPLACE VIEW v_gender_distribution AS
SELECT 
    s.admission_year,
    s.current_year_of_study,
    d.code AS department_code,
    SUM(CASE WHEN UPPER(s.gender) = 'MALE' THEN 1 ELSE 0 END) AS male_students,
    SUM(CASE WHEN UPPER(s.gender) = 'FEMALE' THEN 1 ELSE 0 END) AS female_students,
    COUNT(s.id) AS total_students,
    ROUND((SUM(CASE WHEN UPPER(s.gender) = 'FEMALE' THEN 1 ELSE 0 END) / COUNT(s.id)) * 100, 1) AS female_percentage
FROM students s
JOIN departments d ON d.id = s.department_id
GROUP BY s.admission_year, s.current_year_of_study, d.code;

-- ------------------------------------------------------------------------------
-- 10. SEEDING CORE ADMINISTRATIVE HIERARCHY
-- ------------------------------------------------------------------------------
-- Root Owner (OWN0001)
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(100, 'owner@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'OWNER', FALSE),
(101, 'admin@college.local', '$2b$12$rd/jnbF/5dat4VgWlr.j/OVsDunUuSGqhgzsw//DnCrQmOyf.u5oq', 'ADMIN', FALSE),
(102, 'principal@college.local', '$2b$12$rd/jnbF/5dat4VgWlr.j/OVsDunUuSGqhgzsw//DnCrQmOyf.u5oq', 'ADMIN', FALSE),
(103, 'dean.academic@college.local', '$2b$12$rd/jnbF/5dat4VgWlr.j/OVsDunUuSGqhgzsw//DnCrQmOyf.u5oq', 'ADMIN', FALSE);

INSERT INTO owners (id, user_id, owner_code, full_name, official_email, phone, designation, status, institution_id) VALUES
(1, 100, 'OWN0001', 'Dr. Rajeshwar Rao', 'owner@college.local', '+91 98490 12345', 'Root Owner & Chancellor', 'ACTIVE', 1);

INSERT INTO root_owner_control (singleton_id, user_id, owner_id) VALUES
(1, 100, 'OWN0001');

INSERT INTO ownership_history (previous_owner_id, new_owner_id, approved_by, transfer_reason) VALUES
('NONE', 'OWN0001', 'SYSTEM_INIT', 'Initial Institution Foundation and Appointment of Dr. Rajeshwar Rao');

-- ------------------------------------------------------------------------------
-- 11. SEEDING FACULTY ACROSS ALL DEPARTMENTS (HODs & Professors)
-- ------------------------------------------------------------------------------
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(201, 'hod.cse@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(201, 'HODCSE001', 'Dr. Anita Rao', 'hod.cse@college.local', '+91 98765 43210', 1, 'Professor & HOD', 'Ph.D. in Computer Science', 'AI & Distributed Systems', '2016-07-01', 18, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(202, 'teacher.cse1@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(202, 'FAC2018001', 'Prof. Rahul Mehta', 'teacher.cse1@college.local', '+91 98765 43210', 1, 'Associate Professor', 'M.Tech, Ph.D.', 'Cloud Computing & Networks', '2016-07-01', 12, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(203, 'teacher.cse2@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(203, 'FAC2021002', 'Dr. Vikram Sethi', 'teacher.cse2@college.local', '+91 98765 43210', 1, 'Assistant Professor', 'Ph.D.', 'Machine Learning & NLP', '2016-07-01', 6, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(204, 'hod.ece@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(204, 'HODECE001', 'Dr. Suresh Varma', 'hod.ece@college.local', '+91 98765 43210', 2, 'Professor & HOD', 'Ph.D. in VLSI Design', 'Embedded Systems & IoT', '2016-07-01', 16, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(205, 'teacher.ece1@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(205, 'FAC2019001', 'Prof. Priya Nambiar', 'teacher.ece1@college.local', '+91 98765 43210', 2, 'Associate Professor', 'M.Tech', 'Wireless Communication', '2016-07-01', 10, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(206, 'hod.eee@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(206, 'HODEEE001', 'Dr. K. Srinivas', 'hod.eee@college.local', '+91 98765 43210', 3, 'Professor & HOD', 'Ph.D. in Power Systems', 'Smart Grid & Renewable Energy', '2016-07-01', 17, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(207, 'teacher.eee1@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(207, 'FAC2020001', 'Prof. Swati Joshi', 'teacher.eee1@college.local', '+91 98765 43210', 3, 'Assistant Professor', 'M.Tech', 'Control Systems', '2016-07-01', 7, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(208, 'hod.mech@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(208, 'HODMECH001', 'Dr. M. S. Deshmukh', 'hod.mech@college.local', '+91 98765 43210', 4, 'Professor & HOD', 'Ph.D. in Thermal Engg', 'Thermodynamics & Robotics', '2016-07-01', 20, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(209, 'teacher.mech1@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(209, 'FAC2019002', 'Prof. Arun Pillai', 'teacher.mech1@college.local', '+91 98765 43210', 4, 'Associate Professor', 'M.Tech', 'CAD/CAM & Mechatronics', '2016-07-01', 11, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(210, 'hod.civil@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(210, 'HODCIVIL001', 'Dr. Radhika Sen', 'hod.civil@college.local', '+91 98765 43210', 5, 'Professor & HOD', 'Ph.D. in Structural Engg', 'Earthquake Engineering', '2016-07-01', 15, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(211, 'teacher.civil1@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(211, 'FAC2022001', 'Prof. Manoj Kumar', 'teacher.civil1@college.local', '+91 98765 43210', 5, 'Assistant Professor', 'M.Tech', 'Geotechnical Engineering', '2016-07-01', 5, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(212, 'hod.it@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(212, 'HODIT001', 'Dr. B. K. Bannerjee', 'hod.it@college.local', '+91 98765 43210', 6, 'Professor & HOD', 'Ph.D. in Cyber Security', 'Cryptography & Blockchain', '2016-07-01', 16, 'ACTIVE');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(213, 'teacher.it1@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'FACULTY', FALSE);
INSERT INTO faculty (user_id, employee_id, full_name, college_email, phone, department_id, designation, qualification, specialization, joining_date, experience_years, status) VALUES
(213, 'FAC2020002', 'Prof. Sneha Kulkarni', 'teacher.it1@college.local', '+91 98765 43210', 6, 'Associate Professor', 'M.Tech', 'Full Stack Web Engineering', '2016-07-01', 9, 'ACTIVE');

-- ------------------------------------------------------------------------------
-- 12. SEEDING STANDARD FEE STRUCTURES
-- ------------------------------------------------------------------------------
INSERT INTO fee_structures (id, programme_id, semester_number, academic_year, tuition_fee, exam_fee, library_fee, total_amount, due_date) VALUES
(1, 1, 1, '2025-2026', 65000, 2500, 1500, 69000, '2025-09-30'),
(2, 1, 2, '2025-2026', 65000, 2500, 1500, 69000, '2026-02-28'),
(3, 1, 3, '2025-2026', 65000, 2500, 1500, 69000, '2025-09-30'),
(4, 1, 4, '2025-2026', 65000, 2500, 1500, 69000, '2026-02-28'),
(5, 1, 5, '2025-2026', 65000, 2500, 1500, 69000, '2025-09-30'),
(6, 1, 6, '2025-2026', 65000, 2500, 1500, 69000, '2026-02-28'),
(7, 1, 7, '2025-2026', 65000, 2500, 1500, 69000, '2025-09-30'),
(8, 1, 8, '2025-2026', 65000, 2500, 1500, 69000, '2026-02-28');

-- ------------------------------------------------------------------------------
-- 13. SEEDING HISTORICAL STUDENT RECORDS (2015 to 2026)
-- Both Boys & Girls across 1st Year, 2nd Year, 3rd Year, 4th Year and Graduated
-- ------------------------------------------------------------------------------
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1001, 'kian.chowdhury2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(1, 1001, '15CSE0001', 'CSE-01', 'Kian Chowdhury', 'kian.chowdhury2015@college.local', '+91 91501 00001', '1997-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(1, 6.85, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(1, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1002, 'anjali.kulkarni2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(2, 1002, '15CSE0002', 'CSE-02', 'Anjali Kulkarni', 'anjali.kulkarni2015@college.local', '+91 91501 00002', '1997-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(2, 7.2, 94.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(2, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1003, 'manish.hegde2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(3, 1003, '15CSE0003', 'CSE-03', 'Manish Hegde', 'manish.hegde2015@college.local', '+91 91501 00003', '1997-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(3, 7.55, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(3, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1004, 'ananya.das2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(4, 1004, '15CSE0004', 'CSE-04', 'Ananya Das', 'ananya.das2015@college.local', '+91 91501 00004', '1997-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(4, 7.9, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(4, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1005, 'aarav.mukherjee2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(5, 1005, '15CSE0005', 'CSE-05', 'Aarav Mukherjee', 'aarav.mukherjee2015@college.local', '+91 91501 00005', '1997-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(5, 8.25, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(5, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1006, 'anvi.ghosh2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(6, 1006, '15CSE0006', 'CSE-06', 'Anvi Ghosh', 'anvi.ghosh2015@college.local', '+91 91501 00006', '1997-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(6, 8.6, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(6, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1007, 'shaurya.chakraborty2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(7, 1007, '15CSE0007', 'CSE-07', 'Shaurya Chakraborty', 'shaurya.chakraborty2015@college.local', '+91 91501 00007', '1997-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(7, 8.95, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(7, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1008, 'harini.verma2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(8, 1008, '15CSE0008', 'CSE-08', 'Harini Verma', 'harini.verma2015@college.local', '+91 91501 00008', '1997-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(8, 9.3, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(8, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1009, 'kian.joshi2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(9, 1009, '15ECE0001', 'ECE-01', 'Kian Joshi', 'kian.joshi2015@college.local', '+91 91502 00001', '1997-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(9, 6.85, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(9, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1010, 'anjali.bhat2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(10, 1010, '15ECE0002', 'ECE-02', 'Anjali Bhat', 'anjali.bhat2015@college.local', '+91 91502 00002', '1997-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(10, 7.2, 94.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(10, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1011, 'manish.menon2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(11, 1011, '15ECE0003', 'ECE-03', 'Manish Menon', 'manish.menon2015@college.local', '+91 91502 00003', '1997-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(11, 7.55, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(11, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1012, 'ananya.chatterjee2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(12, 1012, '15ECE0004', 'ECE-04', 'Ananya Chatterjee', 'ananya.chatterjee2015@college.local', '+91 91502 00004', '1997-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(12, 7.9, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(12, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1013, 'aarav.bose2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(13, 1013, '15ECE0005', 'ECE-05', 'Aarav Bose', 'aarav.bose2015@college.local', '+91 91502 00005', '1997-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(13, 8.25, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(13, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1014, 'anvi.roy2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(14, 1014, '15ECE0006', 'ECE-06', 'Anvi Roy', 'anvi.roy2015@college.local', '+91 91502 00006', '1997-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(14, 8.6, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(14, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1015, 'shaurya.sharma2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(15, 1015, '15ECE0007', 'ECE-07', 'Shaurya Sharma', 'shaurya.sharma2015@college.local', '+91 91502 00007', '1997-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(15, 8.95, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(15, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1016, 'harini.patel2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(16, 1016, '15ECE0008', 'ECE-08', 'Harini Patel', 'harini.patel2015@college.local', '+91 91502 00008', '1997-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(16, 9.3, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(16, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1017, 'kian.deshmukh2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(17, 1017, '15EEE0001', 'EEE-01', 'Kian Deshmukh', 'kian.deshmukh2015@college.local', '+91 91503 00001', '1997-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(17, 6.85, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(17, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1018, 'anjali.pillai2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(18, 1018, '15EEE0002', 'EEE-02', 'Anjali Pillai', 'anjali.pillai2015@college.local', '+91 91503 00002', '1997-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(18, 7.2, 94.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(18, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1019, 'manish.banerjee2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(19, 1019, '15EEE0003', 'EEE-03', 'Manish Banerjee', 'manish.banerjee2015@college.local', '+91 91503 00003', '1997-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(19, 7.55, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(19, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1020, 'ananya.sen2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(20, 1020, '15EEE0004', 'EEE-04', 'Ananya Sen', 'ananya.sen2015@college.local', '+91 91503 00004', '1997-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(20, 7.9, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(20, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1021, 'aarav.dutta2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(21, 1021, '15EEE0005', 'EEE-05', 'Aarav Dutta', 'aarav.dutta2015@college.local', '+91 91503 00005', '1997-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(21, 8.25, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(21, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1022, 'anvi.mitra2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(22, 1022, '15EEE0006', 'EEE-06', 'Anvi Mitra', 'anvi.mitra2015@college.local', '+91 91503 00006', '1997-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(22, 8.6, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(22, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1023, 'shaurya.reddy2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(23, 1023, '15EEE0007', 'EEE-07', 'Shaurya Reddy', 'shaurya.reddy2015@college.local', '+91 91503 00007', '1997-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(23, 8.95, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(23, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1024, 'harini.nair2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(24, 1024, '15EEE0008', 'EEE-08', 'Harini Nair', 'harini.nair2015@college.local', '+91 91503 00008', '1997-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(24, 9.3, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(24, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1025, 'kian.hegde2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(25, 1025, '15MECH0001', 'MECH-01', 'Kian Hegde', 'kian.hegde2015@college.local', '+91 91504 00001', '1997-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(25, 6.85, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(25, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1026, 'anjali.das2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(26, 1026, '15MECH0002', 'MECH-02', 'Anjali Das', 'anjali.das2015@college.local', '+91 91504 00002', '1997-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(26, 7.2, 94.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(26, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1027, 'manish.mukherjee2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(27, 1027, '15MECH0003', 'MECH-03', 'Manish Mukherjee', 'manish.mukherjee2015@college.local', '+91 91504 00003', '1997-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(27, 7.55, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(27, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1028, 'ananya.ghosh2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(28, 1028, '15MECH0004', 'MECH-04', 'Ananya Ghosh', 'ananya.ghosh2015@college.local', '+91 91504 00004', '1997-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(28, 7.9, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(28, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1029, 'aarav.chakraborty2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(29, 1029, '15MECH0005', 'MECH-05', 'Aarav Chakraborty', 'aarav.chakraborty2015@college.local', '+91 91504 00005', '1997-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(29, 8.25, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(29, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1030, 'anvi.verma2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(30, 1030, '15MECH0006', 'MECH-06', 'Anvi Verma', 'anvi.verma2015@college.local', '+91 91504 00006', '1997-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(30, 8.6, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(30, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1031, 'shaurya.rao2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(31, 1031, '15MECH0007', 'MECH-07', 'Shaurya Rao', 'shaurya.rao2015@college.local', '+91 91504 00007', '1997-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(31, 8.95, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(31, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1032, 'harini.gupta2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(32, 1032, '15MECH0008', 'MECH-08', 'Harini Gupta', 'harini.gupta2015@college.local', '+91 91504 00008', '1997-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(32, 9.3, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(32, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1033, 'kian.menon2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(33, 1033, '15CIVIL0001', 'CIVIL-01', 'Kian Menon', 'kian.menon2015@college.local', '+91 91505 00001', '1997-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(33, 6.85, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(33, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1034, 'anjali.chatterjee2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(34, 1034, '15CIVIL0002', 'CIVIL-02', 'Anjali Chatterjee', 'anjali.chatterjee2015@college.local', '+91 91505 00002', '1997-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(34, 7.2, 94.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(34, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1035, 'manish.bose2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(35, 1035, '15CIVIL0003', 'CIVIL-03', 'Manish Bose', 'manish.bose2015@college.local', '+91 91505 00003', '1997-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(35, 7.55, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(35, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1036, 'ananya.roy2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(36, 1036, '15CIVIL0004', 'CIVIL-04', 'Ananya Roy', 'ananya.roy2015@college.local', '+91 91505 00004', '1997-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(36, 7.9, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(36, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1037, 'aarav.sharma2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(37, 1037, '15CIVIL0005', 'CIVIL-05', 'Aarav Sharma', 'aarav.sharma2015@college.local', '+91 91505 00005', '1997-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(37, 8.25, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(37, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1038, 'anvi.patel2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(38, 1038, '15CIVIL0006', 'CIVIL-06', 'Anvi Patel', 'anvi.patel2015@college.local', '+91 91505 00006', '1997-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(38, 8.6, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(38, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1039, 'shaurya.iyer2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(39, 1039, '15CIVIL0007', 'CIVIL-07', 'Shaurya Iyer', 'shaurya.iyer2015@college.local', '+91 91505 00007', '1997-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(39, 8.95, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(39, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1040, 'harini.kumar2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(40, 1040, '15CIVIL0008', 'CIVIL-08', 'Harini Kumar', 'harini.kumar2015@college.local', '+91 91505 00008', '1997-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(40, 9.3, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(40, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1041, 'kian.banerjee2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(41, 1041, '15IT0001', 'IT-01', 'Kian Banerjee', 'kian.banerjee2015@college.local', '+91 91506 00001', '1997-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(41, 6.85, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(41, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1042, 'anjali.sen2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(42, 1042, '15IT0002', 'IT-02', 'Anjali Sen', 'anjali.sen2015@college.local', '+91 91506 00002', '1997-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(42, 7.2, 94.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(42, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1043, 'manish.dutta2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(43, 1043, '15IT0003', 'IT-03', 'Manish Dutta', 'manish.dutta2015@college.local', '+91 91506 00003', '1997-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(43, 7.55, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(43, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1044, 'ananya.mitra2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(44, 1044, '15IT0004', 'IT-04', 'Ananya Mitra', 'ananya.mitra2015@college.local', '+91 91506 00004', '1997-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(44, 7.9, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(44, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1045, 'aarav.reddy2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(45, 1045, '15IT0005', 'IT-05', 'Aarav Reddy', 'aarav.reddy2015@college.local', '+91 91506 00005', '1997-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(45, 8.25, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(45, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1046, 'anvi.nair2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(46, 1046, '15IT0006', 'IT-06', 'Anvi Nair', 'anvi.nair2015@college.local', '+91 91506 00006', '1997-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(46, 8.6, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(46, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1047, 'shaurya.singh2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(47, 1047, '15IT0007', 'IT-07', 'Shaurya Singh', 'shaurya.singh2015@college.local', '+91 91506 00007', '1997-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(47, 8.95, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(47, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1048, 'harini.mishra2015@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(48, 1048, '15IT0008', 'IT-08', 'Harini Mishra', 'harini.mishra2015@college.local', '+91 91506 00008', '1997-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2015, 2019, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(48, 9.3, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(48, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1049, 'rudra.mishra2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(49, 1049, '16CSE0001', 'CSE-01', 'Rudra Mishra', 'rudra.mishra2016@college.local', '+91 91601 00001', '1998-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(49, 7.05, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(49, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1050, 'bhavana.deshmukh2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(50, 1050, '16CSE0002', 'CSE-02', 'Bhavana Deshmukh', 'bhavana.deshmukh2016@college.local', '+91 91601 00002', '1998-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(50, 7.4, 95.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(50, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1051, 'gautam.pillai2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(51, 1051, '16CSE0003', 'CSE-03', 'Gautam Pillai', 'gautam.pillai2016@college.local', '+91 91601 00003', '1998-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(51, 7.75, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(51, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1052, 'diya.banerjee2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(52, 1052, '16CSE0004', 'CSE-04', 'Diya Banerjee', 'diya.banerjee2016@college.local', '+91 91601 00004', '1998-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(52, 8.1, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(52, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1053, 'vivaan.sen2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(53, 1053, '16CSE0005', 'CSE-05', 'Vivaan Sen', 'vivaan.sen2016@college.local', '+91 91601 00005', '1998-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(53, 8.45, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(53, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1054, 'aavya.dutta2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(54, 1054, '16CSE0006', 'CSE-06', 'Aavya Dutta', 'aavya.dutta2016@college.local', '+91 91601 00006', '1998-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(54, 8.8, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(54, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1055, 'atharv.mitra2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(55, 1055, '16CSE0007', 'CSE-07', 'Atharv Mitra', 'atharv.mitra2016@college.local', '+91 91601 00007', '1998-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(55, 9.15, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(55, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1056, 'keerthi.reddy2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(56, 1056, '16CSE0008', 'CSE-08', 'Keerthi Reddy', 'keerthi.reddy2016@college.local', '+91 91601 00008', '1998-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(56, 9.5, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(56, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1057, 'rudra.kulkarni2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(57, 1057, '16ECE0001', 'ECE-01', 'Rudra Kulkarni', 'rudra.kulkarni2016@college.local', '+91 91602 00001', '1998-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(57, 7.05, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(57, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1058, 'bhavana.hegde2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(58, 1058, '16ECE0002', 'ECE-02', 'Bhavana Hegde', 'bhavana.hegde2016@college.local', '+91 91602 00002', '1998-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(58, 7.4, 95.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(58, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1059, 'gautam.das2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(59, 1059, '16ECE0003', 'ECE-03', 'Gautam Das', 'gautam.das2016@college.local', '+91 91602 00003', '1998-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(59, 7.75, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(59, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1060, 'diya.mukherjee2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(60, 1060, '16ECE0004', 'ECE-04', 'Diya Mukherjee', 'diya.mukherjee2016@college.local', '+91 91602 00004', '1998-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(60, 8.1, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(60, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1061, 'vivaan.ghosh2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(61, 1061, '16ECE0005', 'ECE-05', 'Vivaan Ghosh', 'vivaan.ghosh2016@college.local', '+91 91602 00005', '1998-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(61, 8.45, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(61, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1062, 'aavya.chakraborty2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(62, 1062, '16ECE0006', 'ECE-06', 'Aavya Chakraborty', 'aavya.chakraborty2016@college.local', '+91 91602 00006', '1998-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(62, 8.8, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(62, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1063, 'atharv.verma2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(63, 1063, '16ECE0007', 'ECE-07', 'Atharv Verma', 'atharv.verma2016@college.local', '+91 91602 00007', '1998-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(63, 9.15, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(63, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1064, 'keerthi.rao2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(64, 1064, '16ECE0008', 'ECE-08', 'Keerthi Rao', 'keerthi.rao2016@college.local', '+91 91602 00008', '1998-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(64, 9.5, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(64, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1065, 'rudra.bhat2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(65, 1065, '16EEE0001', 'EEE-01', 'Rudra Bhat', 'rudra.bhat2016@college.local', '+91 91603 00001', '1998-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(65, 7.05, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(65, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1066, 'bhavana.menon2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(66, 1066, '16EEE0002', 'EEE-02', 'Bhavana Menon', 'bhavana.menon2016@college.local', '+91 91603 00002', '1998-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(66, 7.4, 95.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(66, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1067, 'gautam.chatterjee2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(67, 1067, '16EEE0003', 'EEE-03', 'Gautam Chatterjee', 'gautam.chatterjee2016@college.local', '+91 91603 00003', '1998-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(67, 7.75, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(67, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1068, 'diya.bose2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(68, 1068, '16EEE0004', 'EEE-04', 'Diya Bose', 'diya.bose2016@college.local', '+91 91603 00004', '1998-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(68, 8.1, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(68, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1069, 'vivaan.roy2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(69, 1069, '16EEE0005', 'EEE-05', 'Vivaan Roy', 'vivaan.roy2016@college.local', '+91 91603 00005', '1998-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(69, 8.45, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(69, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1070, 'aavya.sharma2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(70, 1070, '16EEE0006', 'EEE-06', 'Aavya Sharma', 'aavya.sharma2016@college.local', '+91 91603 00006', '1998-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(70, 8.8, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(70, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1071, 'atharv.patel2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(71, 1071, '16EEE0007', 'EEE-07', 'Atharv Patel', 'atharv.patel2016@college.local', '+91 91603 00007', '1998-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(71, 9.15, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(71, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1072, 'keerthi.iyer2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(72, 1072, '16EEE0008', 'EEE-08', 'Keerthi Iyer', 'keerthi.iyer2016@college.local', '+91 91603 00008', '1998-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(72, 9.5, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(72, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1073, 'rudra.pillai2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(73, 1073, '16MECH0001', 'MECH-01', 'Rudra Pillai', 'rudra.pillai2016@college.local', '+91 91604 00001', '1998-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(73, 7.05, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(73, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1074, 'bhavana.banerjee2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(74, 1074, '16MECH0002', 'MECH-02', 'Bhavana Banerjee', 'bhavana.banerjee2016@college.local', '+91 91604 00002', '1998-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(74, 7.4, 95.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(74, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1075, 'gautam.sen2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(75, 1075, '16MECH0003', 'MECH-03', 'Gautam Sen', 'gautam.sen2016@college.local', '+91 91604 00003', '1998-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(75, 7.75, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(75, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1076, 'diya.dutta2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(76, 1076, '16MECH0004', 'MECH-04', 'Diya Dutta', 'diya.dutta2016@college.local', '+91 91604 00004', '1998-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(76, 8.1, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(76, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1077, 'vivaan.mitra2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(77, 1077, '16MECH0005', 'MECH-05', 'Vivaan Mitra', 'vivaan.mitra2016@college.local', '+91 91604 00005', '1998-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(77, 8.45, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(77, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1078, 'aavya.reddy2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(78, 1078, '16MECH0006', 'MECH-06', 'Aavya Reddy', 'aavya.reddy2016@college.local', '+91 91604 00006', '1998-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(78, 8.8, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(78, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1079, 'atharv.nair2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(79, 1079, '16MECH0007', 'MECH-07', 'Atharv Nair', 'atharv.nair2016@college.local', '+91 91604 00007', '1998-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(79, 9.15, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(79, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1080, 'keerthi.singh2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(80, 1080, '16MECH0008', 'MECH-08', 'Keerthi Singh', 'keerthi.singh2016@college.local', '+91 91604 00008', '1998-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(80, 9.5, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(80, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1081, 'rudra.das2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(81, 1081, '16CIVIL0001', 'CIVIL-01', 'Rudra Das', 'rudra.das2016@college.local', '+91 91605 00001', '1998-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(81, 7.05, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(81, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1082, 'bhavana.mukherjee2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(82, 1082, '16CIVIL0002', 'CIVIL-02', 'Bhavana Mukherjee', 'bhavana.mukherjee2016@college.local', '+91 91605 00002', '1998-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(82, 7.4, 95.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(82, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1083, 'gautam.ghosh2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(83, 1083, '16CIVIL0003', 'CIVIL-03', 'Gautam Ghosh', 'gautam.ghosh2016@college.local', '+91 91605 00003', '1998-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(83, 7.75, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(83, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1084, 'diya.chakraborty2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(84, 1084, '16CIVIL0004', 'CIVIL-04', 'Diya Chakraborty', 'diya.chakraborty2016@college.local', '+91 91605 00004', '1998-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(84, 8.1, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(84, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1085, 'vivaan.verma2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(85, 1085, '16CIVIL0005', 'CIVIL-05', 'Vivaan Verma', 'vivaan.verma2016@college.local', '+91 91605 00005', '1998-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(85, 8.45, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(85, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1086, 'aavya.rao2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(86, 1086, '16CIVIL0006', 'CIVIL-06', 'Aavya Rao', 'aavya.rao2016@college.local', '+91 91605 00006', '1998-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(86, 8.8, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(86, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1087, 'atharv.gupta2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(87, 1087, '16CIVIL0007', 'CIVIL-07', 'Atharv Gupta', 'atharv.gupta2016@college.local', '+91 91605 00007', '1998-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(87, 9.15, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(87, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1088, 'keerthi.chowdhury2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(88, 1088, '16CIVIL0008', 'CIVIL-08', 'Keerthi Chowdhury', 'keerthi.chowdhury2016@college.local', '+91 91605 00008', '1998-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(88, 9.5, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(88, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1089, 'rudra.chatterjee2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(89, 1089, '16IT0001', 'IT-01', 'Rudra Chatterjee', 'rudra.chatterjee2016@college.local', '+91 91606 00001', '1998-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(89, 7.05, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(89, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1090, 'bhavana.bose2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(90, 1090, '16IT0002', 'IT-02', 'Bhavana Bose', 'bhavana.bose2016@college.local', '+91 91606 00002', '1998-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(90, 7.4, 95.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(90, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1091, 'gautam.roy2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(91, 1091, '16IT0003', 'IT-03', 'Gautam Roy', 'gautam.roy2016@college.local', '+91 91606 00003', '1998-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(91, 7.75, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(91, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1092, 'diya.sharma2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(92, 1092, '16IT0004', 'IT-04', 'Diya Sharma', 'diya.sharma2016@college.local', '+91 91606 00004', '1998-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(92, 8.1, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(92, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1093, 'vivaan.patel2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(93, 1093, '16IT0005', 'IT-05', 'Vivaan Patel', 'vivaan.patel2016@college.local', '+91 91606 00005', '1998-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(93, 8.45, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(93, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1094, 'aavya.iyer2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(94, 1094, '16IT0006', 'IT-06', 'Aavya Iyer', 'aavya.iyer2016@college.local', '+91 91606 00006', '1998-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(94, 8.8, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(94, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1095, 'atharv.kumar2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(95, 1095, '16IT0007', 'IT-07', 'Atharv Kumar', 'atharv.kumar2016@college.local', '+91 91606 00007', '1998-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(95, 9.15, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(95, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1096, 'keerthi.joshi2016@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(96, 1096, '16IT0008', 'IT-08', 'Keerthi Joshi', 'keerthi.joshi2016@college.local', '+91 91606 00008', '1998-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2016, 2020, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(96, 9.5, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(96, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1097, 'nihanth.joshi2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(97, 1097, '17CSE0001', 'CSE-01', 'Nihanth Joshi', 'nihanth.joshi2017@college.local', '+91 91701 00001', '1999-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(97, 7.25, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(97, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1098, 'harini.bhat2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(98, 1098, '17CSE0002', 'CSE-02', 'Harini Bhat', 'harini.bhat2017@college.local', '+91 91701 00002', '1999-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(98, 7.6, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(98, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1099, 'harish.menon2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(99, 1099, '17CSE0003', 'CSE-03', 'Harish Menon', 'harish.menon2017@college.local', '+91 91701 00003', '1999-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(99, 7.95, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(99, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1100, 'gauri.chatterjee2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(100, 1100, '17CSE0004', 'CSE-04', 'Gauri Chatterjee', 'gauri.chatterjee2017@college.local', '+91 91701 00004', '1999-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(100, 8.3, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(100, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1101, 'aditya.bose2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(101, 1101, '17CSE0005', 'CSE-05', 'Aditya Bose', 'aditya.bose2017@college.local', '+91 91701 00005', '1999-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(101, 8.65, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(101, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1102, 'vanya.roy2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(102, 1102, '17CSE0006', 'CSE-06', 'Vanya Roy', 'vanya.roy2017@college.local', '+91 91701 00006', '1999-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(102, 9.0, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(102, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1103, 'advik.sharma2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(103, 1103, '17CSE0007', 'CSE-07', 'Advik Sharma', 'advik.sharma2017@college.local', '+91 91701 00007', '1999-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(103, 9.35, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(103, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1104, 'lavanya.patel2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(104, 1104, '17CSE0008', 'CSE-08', 'Lavanya Patel', 'lavanya.patel2017@college.local', '+91 91701 00008', '1999-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(104, 9.7, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(104, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1105, 'nihanth.deshmukh2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(105, 1105, '17ECE0001', 'ECE-01', 'Nihanth Deshmukh', 'nihanth.deshmukh2017@college.local', '+91 91702 00001', '1999-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(105, 7.25, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(105, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1106, 'harini.pillai2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(106, 1106, '17ECE0002', 'ECE-02', 'Harini Pillai', 'harini.pillai2017@college.local', '+91 91702 00002', '1999-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(106, 7.6, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(106, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1107, 'harish.banerjee2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(107, 1107, '17ECE0003', 'ECE-03', 'Harish Banerjee', 'harish.banerjee2017@college.local', '+91 91702 00003', '1999-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(107, 7.95, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(107, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1108, 'gauri.sen2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(108, 1108, '17ECE0004', 'ECE-04', 'Gauri Sen', 'gauri.sen2017@college.local', '+91 91702 00004', '1999-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(108, 8.3, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(108, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1109, 'aditya.dutta2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(109, 1109, '17ECE0005', 'ECE-05', 'Aditya Dutta', 'aditya.dutta2017@college.local', '+91 91702 00005', '1999-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(109, 8.65, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(109, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1110, 'vanya.mitra2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(110, 1110, '17ECE0006', 'ECE-06', 'Vanya Mitra', 'vanya.mitra2017@college.local', '+91 91702 00006', '1999-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(110, 9.0, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(110, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1111, 'advik.reddy2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(111, 1111, '17ECE0007', 'ECE-07', 'Advik Reddy', 'advik.reddy2017@college.local', '+91 91702 00007', '1999-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(111, 9.35, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(111, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1112, 'lavanya.nair2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(112, 1112, '17ECE0008', 'ECE-08', 'Lavanya Nair', 'lavanya.nair2017@college.local', '+91 91702 00008', '1999-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(112, 9.7, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(112, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1113, 'nihanth.hegde2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(113, 1113, '17EEE0001', 'EEE-01', 'Nihanth Hegde', 'nihanth.hegde2017@college.local', '+91 91703 00001', '1999-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(113, 7.25, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(113, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1114, 'harini.das2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(114, 1114, '17EEE0002', 'EEE-02', 'Harini Das', 'harini.das2017@college.local', '+91 91703 00002', '1999-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(114, 7.6, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(114, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1115, 'harish.mukherjee2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(115, 1115, '17EEE0003', 'EEE-03', 'Harish Mukherjee', 'harish.mukherjee2017@college.local', '+91 91703 00003', '1999-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(115, 7.95, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(115, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1116, 'gauri.ghosh2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(116, 1116, '17EEE0004', 'EEE-04', 'Gauri Ghosh', 'gauri.ghosh2017@college.local', '+91 91703 00004', '1999-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(116, 8.3, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(116, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1117, 'aditya.chakraborty2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(117, 1117, '17EEE0005', 'EEE-05', 'Aditya Chakraborty', 'aditya.chakraborty2017@college.local', '+91 91703 00005', '1999-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(117, 8.65, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(117, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1118, 'vanya.verma2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(118, 1118, '17EEE0006', 'EEE-06', 'Vanya Verma', 'vanya.verma2017@college.local', '+91 91703 00006', '1999-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(118, 9.0, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(118, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1119, 'advik.rao2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(119, 1119, '17EEE0007', 'EEE-07', 'Advik Rao', 'advik.rao2017@college.local', '+91 91703 00007', '1999-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(119, 9.35, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(119, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1120, 'lavanya.gupta2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(120, 1120, '17EEE0008', 'EEE-08', 'Lavanya Gupta', 'lavanya.gupta2017@college.local', '+91 91703 00008', '1999-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(120, 9.7, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(120, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1121, 'nihanth.menon2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(121, 1121, '17MECH0001', 'MECH-01', 'Nihanth Menon', 'nihanth.menon2017@college.local', '+91 91704 00001', '1999-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(121, 7.25, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(121, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1122, 'harini.chatterjee2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(122, 1122, '17MECH0002', 'MECH-02', 'Harini Chatterjee', 'harini.chatterjee2017@college.local', '+91 91704 00002', '1999-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(122, 7.6, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(122, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1123, 'harish.bose2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(123, 1123, '17MECH0003', 'MECH-03', 'Harish Bose', 'harish.bose2017@college.local', '+91 91704 00003', '1999-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(123, 7.95, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(123, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1124, 'gauri.roy2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(124, 1124, '17MECH0004', 'MECH-04', 'Gauri Roy', 'gauri.roy2017@college.local', '+91 91704 00004', '1999-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(124, 8.3, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(124, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1125, 'aditya.sharma2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(125, 1125, '17MECH0005', 'MECH-05', 'Aditya Sharma', 'aditya.sharma2017@college.local', '+91 91704 00005', '1999-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(125, 8.65, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(125, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1126, 'vanya.patel2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(126, 1126, '17MECH0006', 'MECH-06', 'Vanya Patel', 'vanya.patel2017@college.local', '+91 91704 00006', '1999-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(126, 9.0, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(126, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1127, 'advik.iyer2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(127, 1127, '17MECH0007', 'MECH-07', 'Advik Iyer', 'advik.iyer2017@college.local', '+91 91704 00007', '1999-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(127, 9.35, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(127, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1128, 'lavanya.kumar2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(128, 1128, '17MECH0008', 'MECH-08', 'Lavanya Kumar', 'lavanya.kumar2017@college.local', '+91 91704 00008', '1999-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(128, 9.7, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(128, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1129, 'nihanth.banerjee2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(129, 1129, '17CIVIL0001', 'CIVIL-01', 'Nihanth Banerjee', 'nihanth.banerjee2017@college.local', '+91 91705 00001', '1999-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(129, 7.25, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(129, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1130, 'harini.sen2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(130, 1130, '17CIVIL0002', 'CIVIL-02', 'Harini Sen', 'harini.sen2017@college.local', '+91 91705 00002', '1999-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(130, 7.6, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(130, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1131, 'harish.dutta2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(131, 1131, '17CIVIL0003', 'CIVIL-03', 'Harish Dutta', 'harish.dutta2017@college.local', '+91 91705 00003', '1999-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(131, 7.95, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(131, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1132, 'gauri.mitra2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(132, 1132, '17CIVIL0004', 'CIVIL-04', 'Gauri Mitra', 'gauri.mitra2017@college.local', '+91 91705 00004', '1999-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(132, 8.3, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(132, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1133, 'aditya.reddy2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(133, 1133, '17CIVIL0005', 'CIVIL-05', 'Aditya Reddy', 'aditya.reddy2017@college.local', '+91 91705 00005', '1999-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(133, 8.65, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(133, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1134, 'vanya.nair2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(134, 1134, '17CIVIL0006', 'CIVIL-06', 'Vanya Nair', 'vanya.nair2017@college.local', '+91 91705 00006', '1999-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(134, 9.0, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(134, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1135, 'advik.singh2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(135, 1135, '17CIVIL0007', 'CIVIL-07', 'Advik Singh', 'advik.singh2017@college.local', '+91 91705 00007', '1999-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(135, 9.35, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(135, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1136, 'lavanya.mishra2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(136, 1136, '17CIVIL0008', 'CIVIL-08', 'Lavanya Mishra', 'lavanya.mishra2017@college.local', '+91 91705 00008', '1999-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(136, 9.7, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(136, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1137, 'nihanth.mukherjee2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(137, 1137, '17IT0001', 'IT-01', 'Nihanth Mukherjee', 'nihanth.mukherjee2017@college.local', '+91 91706 00001', '1999-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(137, 7.25, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(137, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1138, 'harini.ghosh2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(138, 1138, '17IT0002', 'IT-02', 'Harini Ghosh', 'harini.ghosh2017@college.local', '+91 91706 00002', '1999-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(138, 7.6, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(138, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1139, 'harish.chakraborty2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(139, 1139, '17IT0003', 'IT-03', 'Harish Chakraborty', 'harish.chakraborty2017@college.local', '+91 91706 00003', '1999-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(139, 7.95, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(139, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1140, 'gauri.verma2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(140, 1140, '17IT0004', 'IT-04', 'Gauri Verma', 'gauri.verma2017@college.local', '+91 91706 00004', '1999-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(140, 8.3, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(140, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1141, 'aditya.rao2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(141, 1141, '17IT0005', 'IT-05', 'Aditya Rao', 'aditya.rao2017@college.local', '+91 91706 00005', '1999-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(141, 8.65, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(141, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1142, 'vanya.gupta2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(142, 1142, '17IT0006', 'IT-06', 'Vanya Gupta', 'vanya.gupta2017@college.local', '+91 91706 00006', '1999-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(142, 9.0, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(142, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1143, 'advik.chowdhury2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(143, 1143, '17IT0007', 'IT-07', 'Advik Chowdhury', 'advik.chowdhury2017@college.local', '+91 91706 00007', '1999-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(143, 9.35, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(143, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1144, 'lavanya.kulkarni2017@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(144, 1144, '17IT0008', 'IT-08', 'Lavanya Kulkarni', 'lavanya.kulkarni2017@college.local', '+91 91706 00008', '1999-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2017, 2021, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(144, 9.7, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(144, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1145, 'rohan.kulkarni2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(145, 1145, '18CSE0001', 'CSE-01', 'Rohan Kulkarni', 'rohan.kulkarni2018@college.local', '+91 91801 00001', '2000-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(145, 7.45, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(145, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1146, 'keerthi.hegde2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(146, 1146, '18CSE0002', 'CSE-02', 'Keerthi Hegde', 'keerthi.hegde2018@college.local', '+91 91801 00002', '2000-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(146, 7.8, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(146, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1147, 'naveen.das2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(147, 1147, '18CSE0003', 'CSE-03', 'Naveen Das', 'naveen.das2018@college.local', '+91 91801 00003', '2000-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(147, 8.15, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(147, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1148, 'pari.mukherjee2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(148, 1148, '18CSE0004', 'CSE-04', 'Pari Mukherjee', 'pari.mukherjee2018@college.local', '+91 91801 00004', '2000-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(148, 8.5, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(148, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1149, 'vihaan.ghosh2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(149, 1149, '18CSE0005', 'CSE-05', 'Vihaan Ghosh', 'vihaan.ghosh2018@college.local', '+91 91801 00005', '2000-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(149, 8.85, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(149, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1150, 'pooja.chakraborty2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(150, 1150, '18CSE0006', 'CSE-06', 'Pooja Chakraborty', 'pooja.chakraborty2018@college.local', '+91 91801 00006', '2000-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(150, 9.2, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(150, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1151, 'pranav.verma2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(151, 1151, '18CSE0007', 'CSE-07', 'Pranav Verma', 'pranav.verma2018@college.local', '+91 91801 00007', '2000-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(151, 9.55, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(151, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1152, 'pallavi.rao2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(152, 1152, '18CSE0008', 'CSE-08', 'Pallavi Rao', 'pallavi.rao2018@college.local', '+91 91801 00008', '2000-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(152, 6.5, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(152, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1153, 'rohan.bhat2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(153, 1153, '18ECE0001', 'ECE-01', 'Rohan Bhat', 'rohan.bhat2018@college.local', '+91 91802 00001', '2000-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(153, 7.45, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(153, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1154, 'keerthi.menon2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(154, 1154, '18ECE0002', 'ECE-02', 'Keerthi Menon', 'keerthi.menon2018@college.local', '+91 91802 00002', '2000-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(154, 7.8, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(154, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1155, 'naveen.chatterjee2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(155, 1155, '18ECE0003', 'ECE-03', 'Naveen Chatterjee', 'naveen.chatterjee2018@college.local', '+91 91802 00003', '2000-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(155, 8.15, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(155, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1156, 'pari.bose2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(156, 1156, '18ECE0004', 'ECE-04', 'Pari Bose', 'pari.bose2018@college.local', '+91 91802 00004', '2000-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(156, 8.5, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(156, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1157, 'vihaan.roy2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(157, 1157, '18ECE0005', 'ECE-05', 'Vihaan Roy', 'vihaan.roy2018@college.local', '+91 91802 00005', '2000-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(157, 8.85, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(157, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1158, 'pooja.sharma2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(158, 1158, '18ECE0006', 'ECE-06', 'Pooja Sharma', 'pooja.sharma2018@college.local', '+91 91802 00006', '2000-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(158, 9.2, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(158, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1159, 'pranav.patel2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(159, 1159, '18ECE0007', 'ECE-07', 'Pranav Patel', 'pranav.patel2018@college.local', '+91 91802 00007', '2000-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(159, 9.55, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(159, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1160, 'pallavi.iyer2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(160, 1160, '18ECE0008', 'ECE-08', 'Pallavi Iyer', 'pallavi.iyer2018@college.local', '+91 91802 00008', '2000-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(160, 6.5, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(160, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1161, 'rohan.pillai2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(161, 1161, '18EEE0001', 'EEE-01', 'Rohan Pillai', 'rohan.pillai2018@college.local', '+91 91803 00001', '2000-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(161, 7.45, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(161, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1162, 'keerthi.banerjee2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(162, 1162, '18EEE0002', 'EEE-02', 'Keerthi Banerjee', 'keerthi.banerjee2018@college.local', '+91 91803 00002', '2000-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(162, 7.8, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(162, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1163, 'naveen.sen2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(163, 1163, '18EEE0003', 'EEE-03', 'Naveen Sen', 'naveen.sen2018@college.local', '+91 91803 00003', '2000-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(163, 8.15, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(163, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1164, 'pari.dutta2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(164, 1164, '18EEE0004', 'EEE-04', 'Pari Dutta', 'pari.dutta2018@college.local', '+91 91803 00004', '2000-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(164, 8.5, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(164, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1165, 'vihaan.mitra2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(165, 1165, '18EEE0005', 'EEE-05', 'Vihaan Mitra', 'vihaan.mitra2018@college.local', '+91 91803 00005', '2000-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(165, 8.85, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(165, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1166, 'pooja.reddy2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(166, 1166, '18EEE0006', 'EEE-06', 'Pooja Reddy', 'pooja.reddy2018@college.local', '+91 91803 00006', '2000-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(166, 9.2, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(166, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1167, 'pranav.nair2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(167, 1167, '18EEE0007', 'EEE-07', 'Pranav Nair', 'pranav.nair2018@college.local', '+91 91803 00007', '2000-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(167, 9.55, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(167, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1168, 'pallavi.singh2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(168, 1168, '18EEE0008', 'EEE-08', 'Pallavi Singh', 'pallavi.singh2018@college.local', '+91 91803 00008', '2000-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(168, 6.5, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(168, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1169, 'rohan.das2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(169, 1169, '18MECH0001', 'MECH-01', 'Rohan Das', 'rohan.das2018@college.local', '+91 91804 00001', '2000-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(169, 7.45, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(169, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1170, 'keerthi.mukherjee2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(170, 1170, '18MECH0002', 'MECH-02', 'Keerthi Mukherjee', 'keerthi.mukherjee2018@college.local', '+91 91804 00002', '2000-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(170, 7.8, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(170, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1171, 'naveen.ghosh2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(171, 1171, '18MECH0003', 'MECH-03', 'Naveen Ghosh', 'naveen.ghosh2018@college.local', '+91 91804 00003', '2000-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(171, 8.15, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(171, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1172, 'pari.chakraborty2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(172, 1172, '18MECH0004', 'MECH-04', 'Pari Chakraborty', 'pari.chakraborty2018@college.local', '+91 91804 00004', '2000-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(172, 8.5, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(172, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1173, 'vihaan.verma2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(173, 1173, '18MECH0005', 'MECH-05', 'Vihaan Verma', 'vihaan.verma2018@college.local', '+91 91804 00005', '2000-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(173, 8.85, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(173, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1174, 'pooja.rao2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(174, 1174, '18MECH0006', 'MECH-06', 'Pooja Rao', 'pooja.rao2018@college.local', '+91 91804 00006', '2000-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(174, 9.2, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(174, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1175, 'pranav.gupta2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(175, 1175, '18MECH0007', 'MECH-07', 'Pranav Gupta', 'pranav.gupta2018@college.local', '+91 91804 00007', '2000-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(175, 9.55, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(175, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1176, 'pallavi.chowdhury2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(176, 1176, '18MECH0008', 'MECH-08', 'Pallavi Chowdhury', 'pallavi.chowdhury2018@college.local', '+91 91804 00008', '2000-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(176, 6.5, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(176, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1177, 'rohan.chatterjee2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(177, 1177, '18CIVIL0001', 'CIVIL-01', 'Rohan Chatterjee', 'rohan.chatterjee2018@college.local', '+91 91805 00001', '2000-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(177, 7.45, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(177, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1178, 'keerthi.bose2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(178, 1178, '18CIVIL0002', 'CIVIL-02', 'Keerthi Bose', 'keerthi.bose2018@college.local', '+91 91805 00002', '2000-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(178, 7.8, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(178, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1179, 'naveen.roy2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(179, 1179, '18CIVIL0003', 'CIVIL-03', 'Naveen Roy', 'naveen.roy2018@college.local', '+91 91805 00003', '2000-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(179, 8.15, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(179, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1180, 'pari.sharma2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(180, 1180, '18CIVIL0004', 'CIVIL-04', 'Pari Sharma', 'pari.sharma2018@college.local', '+91 91805 00004', '2000-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(180, 8.5, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(180, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1181, 'vihaan.patel2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(181, 1181, '18CIVIL0005', 'CIVIL-05', 'Vihaan Patel', 'vihaan.patel2018@college.local', '+91 91805 00005', '2000-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(181, 8.85, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(181, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1182, 'pooja.iyer2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(182, 1182, '18CIVIL0006', 'CIVIL-06', 'Pooja Iyer', 'pooja.iyer2018@college.local', '+91 91805 00006', '2000-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(182, 9.2, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(182, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1183, 'pranav.kumar2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(183, 1183, '18CIVIL0007', 'CIVIL-07', 'Pranav Kumar', 'pranav.kumar2018@college.local', '+91 91805 00007', '2000-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(183, 9.55, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(183, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1184, 'pallavi.joshi2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(184, 1184, '18CIVIL0008', 'CIVIL-08', 'Pallavi Joshi', 'pallavi.joshi2018@college.local', '+91 91805 00008', '2000-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(184, 6.5, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(184, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1185, 'rohan.sen2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(185, 1185, '18IT0001', 'IT-01', 'Rohan Sen', 'rohan.sen2018@college.local', '+91 91806 00001', '2000-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(185, 7.45, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(185, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1186, 'keerthi.dutta2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(186, 1186, '18IT0002', 'IT-02', 'Keerthi Dutta', 'keerthi.dutta2018@college.local', '+91 91806 00002', '2000-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(186, 7.8, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(186, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1187, 'naveen.mitra2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(187, 1187, '18IT0003', 'IT-03', 'Naveen Mitra', 'naveen.mitra2018@college.local', '+91 91806 00003', '2000-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(187, 8.15, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(187, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1188, 'pari.reddy2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(188, 1188, '18IT0004', 'IT-04', 'Pari Reddy', 'pari.reddy2018@college.local', '+91 91806 00004', '2000-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(188, 8.5, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(188, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1189, 'vihaan.nair2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(189, 1189, '18IT0005', 'IT-05', 'Vihaan Nair', 'vihaan.nair2018@college.local', '+91 91806 00005', '2000-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(189, 8.85, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(189, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1190, 'pooja.singh2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(190, 1190, '18IT0006', 'IT-06', 'Pooja Singh', 'pooja.singh2018@college.local', '+91 91806 00006', '2000-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(190, 9.2, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(190, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1191, 'pranav.mishra2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(191, 1191, '18IT0007', 'IT-07', 'Pranav Mishra', 'pranav.mishra2018@college.local', '+91 91806 00007', '2000-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(191, 9.55, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(191, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1192, 'pallavi.deshmukh2018@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(192, 1192, '18IT0008', 'IT-08', 'Pallavi Deshmukh', 'pallavi.deshmukh2018@college.local', '+91 91806 00008', '2000-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2018, 2022, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(192, 6.5, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(192, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1193, 'siddharth.deshmukh2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(193, 1193, '19CSE0001', 'CSE-01', 'Siddharth Deshmukh', 'siddharth.deshmukh2019@college.local', '+91 91901 00001', '2001-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(193, 7.65, 95.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(193, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1194, 'lavanya.pillai2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(194, 1194, '19CSE0002', 'CSE-02', 'Lavanya Pillai', 'lavanya.pillai2019@college.local', '+91 91901 00002', '2001-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(194, 8.0, 75.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(194, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1195, 'praveen.banerjee2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(195, 1195, '19CSE0003', 'CSE-03', 'Praveen Banerjee', 'praveen.banerjee2019@college.local', '+91 91901 00003', '2001-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(195, 8.35, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(195, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1196, 'anika.sen2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(196, 1196, '19CSE0004', 'CSE-04', 'Anika Sen', 'anika.sen2019@college.local', '+91 91901 00004', '2001-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(196, 8.7, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(196, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1197, 'arjun.dutta2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(197, 1197, '19CSE0005', 'CSE-05', 'Arjun Dutta', 'arjun.dutta2019@college.local', '+91 91901 00005', '2001-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(197, 9.05, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(197, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1198, 'deepika.mitra2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(198, 1198, '19CSE0006', 'CSE-06', 'Deepika Mitra', 'deepika.mitra2019@college.local', '+91 91901 00006', '2001-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(198, 9.4, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(198, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1199, 'advaith.reddy2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(199, 1199, '19CSE0007', 'CSE-07', 'Advaith Reddy', 'advaith.reddy2019@college.local', '+91 91901 00007', '2001-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(199, 9.75, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(199, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1200, 'ramya.nair2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(200, 1200, '19CSE0008', 'CSE-08', 'Ramya Nair', 'ramya.nair2019@college.local', '+91 91901 00008', '2001-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(200, 6.7, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(200, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1201, 'siddharth.hegde2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(201, 1201, '19ECE0001', 'ECE-01', 'Siddharth Hegde', 'siddharth.hegde2019@college.local', '+91 91902 00001', '2001-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(201, 7.65, 95.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(201, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1202, 'lavanya.das2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(202, 1202, '19ECE0002', 'ECE-02', 'Lavanya Das', 'lavanya.das2019@college.local', '+91 91902 00002', '2001-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(202, 8.0, 75.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(202, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1203, 'praveen.mukherjee2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(203, 1203, '19ECE0003', 'ECE-03', 'Praveen Mukherjee', 'praveen.mukherjee2019@college.local', '+91 91902 00003', '2001-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(203, 8.35, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(203, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1204, 'anika.ghosh2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(204, 1204, '19ECE0004', 'ECE-04', 'Anika Ghosh', 'anika.ghosh2019@college.local', '+91 91902 00004', '2001-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(204, 8.7, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(204, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1205, 'arjun.chakraborty2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(205, 1205, '19ECE0005', 'ECE-05', 'Arjun Chakraborty', 'arjun.chakraborty2019@college.local', '+91 91902 00005', '2001-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(205, 9.05, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(205, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1206, 'deepika.verma2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(206, 1206, '19ECE0006', 'ECE-06', 'Deepika Verma', 'deepika.verma2019@college.local', '+91 91902 00006', '2001-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(206, 9.4, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(206, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1207, 'advaith.rao2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(207, 1207, '19ECE0007', 'ECE-07', 'Advaith Rao', 'advaith.rao2019@college.local', '+91 91902 00007', '2001-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(207, 9.75, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(207, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1208, 'ramya.gupta2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(208, 1208, '19ECE0008', 'ECE-08', 'Ramya Gupta', 'ramya.gupta2019@college.local', '+91 91902 00008', '2001-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(208, 6.7, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(208, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1209, 'siddharth.menon2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(209, 1209, '19EEE0001', 'EEE-01', 'Siddharth Menon', 'siddharth.menon2019@college.local', '+91 91903 00001', '2001-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(209, 7.65, 95.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(209, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1210, 'lavanya.chatterjee2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(210, 1210, '19EEE0002', 'EEE-02', 'Lavanya Chatterjee', 'lavanya.chatterjee2019@college.local', '+91 91903 00002', '2001-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(210, 8.0, 75.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(210, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1211, 'praveen.bose2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(211, 1211, '19EEE0003', 'EEE-03', 'Praveen Bose', 'praveen.bose2019@college.local', '+91 91903 00003', '2001-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(211, 8.35, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(211, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1212, 'anika.roy2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(212, 1212, '19EEE0004', 'EEE-04', 'Anika Roy', 'anika.roy2019@college.local', '+91 91903 00004', '2001-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(212, 8.7, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(212, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1213, 'arjun.sharma2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(213, 1213, '19EEE0005', 'EEE-05', 'Arjun Sharma', 'arjun.sharma2019@college.local', '+91 91903 00005', '2001-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(213, 9.05, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(213, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1214, 'deepika.patel2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(214, 1214, '19EEE0006', 'EEE-06', 'Deepika Patel', 'deepika.patel2019@college.local', '+91 91903 00006', '2001-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(214, 9.4, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(214, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1215, 'advaith.iyer2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(215, 1215, '19EEE0007', 'EEE-07', 'Advaith Iyer', 'advaith.iyer2019@college.local', '+91 91903 00007', '2001-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(215, 9.75, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(215, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1216, 'ramya.kumar2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(216, 1216, '19EEE0008', 'EEE-08', 'Ramya Kumar', 'ramya.kumar2019@college.local', '+91 91903 00008', '2001-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(216, 6.7, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(216, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1217, 'siddharth.banerjee2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(217, 1217, '19MECH0001', 'MECH-01', 'Siddharth Banerjee', 'siddharth.banerjee2019@college.local', '+91 91904 00001', '2001-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(217, 7.65, 95.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(217, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1218, 'lavanya.sen2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(218, 1218, '19MECH0002', 'MECH-02', 'Lavanya Sen', 'lavanya.sen2019@college.local', '+91 91904 00002', '2001-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(218, 8.0, 75.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(218, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1219, 'praveen.dutta2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(219, 1219, '19MECH0003', 'MECH-03', 'Praveen Dutta', 'praveen.dutta2019@college.local', '+91 91904 00003', '2001-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(219, 8.35, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(219, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1220, 'anika.mitra2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(220, 1220, '19MECH0004', 'MECH-04', 'Anika Mitra', 'anika.mitra2019@college.local', '+91 91904 00004', '2001-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(220, 8.7, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(220, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1221, 'arjun.reddy2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(221, 1221, '19MECH0005', 'MECH-05', 'Arjun Reddy', 'arjun.reddy2019@college.local', '+91 91904 00005', '2001-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(221, 9.05, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(221, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1222, 'deepika.nair2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(222, 1222, '19MECH0006', 'MECH-06', 'Deepika Nair', 'deepika.nair2019@college.local', '+91 91904 00006', '2001-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(222, 9.4, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(222, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1223, 'advaith.singh2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(223, 1223, '19MECH0007', 'MECH-07', 'Advaith Singh', 'advaith.singh2019@college.local', '+91 91904 00007', '2001-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(223, 9.75, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(223, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1224, 'ramya.mishra2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(224, 1224, '19MECH0008', 'MECH-08', 'Ramya Mishra', 'ramya.mishra2019@college.local', '+91 91904 00008', '2001-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(224, 6.7, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(224, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1225, 'siddharth.mukherjee2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(225, 1225, '19CIVIL0001', 'CIVIL-01', 'Siddharth Mukherjee', 'siddharth.mukherjee2019@college.local', '+91 91905 00001', '2001-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(225, 7.65, 95.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(225, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1226, 'lavanya.ghosh2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(226, 1226, '19CIVIL0002', 'CIVIL-02', 'Lavanya Ghosh', 'lavanya.ghosh2019@college.local', '+91 91905 00002', '2001-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(226, 8.0, 75.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(226, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1227, 'praveen.chakraborty2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(227, 1227, '19CIVIL0003', 'CIVIL-03', 'Praveen Chakraborty', 'praveen.chakraborty2019@college.local', '+91 91905 00003', '2001-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(227, 8.35, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(227, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1228, 'anika.verma2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(228, 1228, '19CIVIL0004', 'CIVIL-04', 'Anika Verma', 'anika.verma2019@college.local', '+91 91905 00004', '2001-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(228, 8.7, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(228, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1229, 'arjun.rao2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(229, 1229, '19CIVIL0005', 'CIVIL-05', 'Arjun Rao', 'arjun.rao2019@college.local', '+91 91905 00005', '2001-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(229, 9.05, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(229, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1230, 'deepika.gupta2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(230, 1230, '19CIVIL0006', 'CIVIL-06', 'Deepika Gupta', 'deepika.gupta2019@college.local', '+91 91905 00006', '2001-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(230, 9.4, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(230, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1231, 'advaith.chowdhury2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(231, 1231, '19CIVIL0007', 'CIVIL-07', 'Advaith Chowdhury', 'advaith.chowdhury2019@college.local', '+91 91905 00007', '2001-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(231, 9.75, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(231, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1232, 'ramya.kulkarni2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(232, 1232, '19CIVIL0008', 'CIVIL-08', 'Ramya Kulkarni', 'ramya.kulkarni2019@college.local', '+91 91905 00008', '2001-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(232, 6.7, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(232, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1233, 'siddharth.bose2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(233, 1233, '19IT0001', 'IT-01', 'Siddharth Bose', 'siddharth.bose2019@college.local', '+91 91906 00001', '2001-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(233, 7.65, 95.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(233, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1234, 'lavanya.roy2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(234, 1234, '19IT0002', 'IT-02', 'Lavanya Roy', 'lavanya.roy2019@college.local', '+91 91906 00002', '2001-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(234, 8.0, 75.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(234, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1235, 'praveen.sharma2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(235, 1235, '19IT0003', 'IT-03', 'Praveen Sharma', 'praveen.sharma2019@college.local', '+91 91906 00003', '2001-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(235, 8.35, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(235, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1236, 'anika.patel2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(236, 1236, '19IT0004', 'IT-04', 'Anika Patel', 'anika.patel2019@college.local', '+91 91906 00004', '2001-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(236, 8.7, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(236, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1237, 'arjun.iyer2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(237, 1237, '19IT0005', 'IT-05', 'Arjun Iyer', 'arjun.iyer2019@college.local', '+91 91906 00005', '2001-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(237, 9.05, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(237, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1238, 'deepika.kumar2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(238, 1238, '19IT0006', 'IT-06', 'Deepika Kumar', 'deepika.kumar2019@college.local', '+91 91906 00006', '2001-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(238, 9.4, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(238, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1239, 'advaith.joshi2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(239, 1239, '19IT0007', 'IT-07', 'Advaith Joshi', 'advaith.joshi2019@college.local', '+91 91906 00007', '2001-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(239, 9.75, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(239, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1240, 'ramya.bhat2019@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(240, 1240, '19IT0008', 'IT-08', 'Ramya Bhat', 'ramya.bhat2019@college.local', '+91 91906 00008', '2001-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2019, 2023, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(240, 6.7, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(240, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1241, 'rahul.bhat2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(241, 1241, '20CSE0001', 'CSE-01', 'Rahul Bhat', 'rahul.bhat2020@college.local', '+91 92001 00001', '2002-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(241, 6.85, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(241, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1242, 'pallavi.menon2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(242, 1242, '20CSE0002', 'CSE-02', 'Pallavi Menon', 'pallavi.menon2020@college.local', '+91 92001 00002', '2002-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(242, 7.2, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(242, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1243, 'rakesh.chatterjee2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(243, 1243, '20CSE0003', 'CSE-03', 'Rakesh Chatterjee', 'rakesh.chatterjee2020@college.local', '+91 92001 00003', '2002-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(243, 7.55, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(243, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1244, 'navya.bose2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(244, 1244, '20CSE0004', 'CSE-04', 'Navya Bose', 'navya.bose2020@college.local', '+91 92001 00004', '2002-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(244, 7.9, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(244, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1245, 'sai.roy2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(245, 1245, '20CSE0005', 'CSE-05', 'Sai Roy', 'sai.roy2020@college.local', '+91 92001 00005', '2002-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(245, 8.25, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(245, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1246, 'kavya.sharma2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(246, 1246, '20CSE0006', 'CSE-06', 'Kavya Sharma', 'kavya.sharma2020@college.local', '+91 92001 00006', '2002-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(246, 8.6, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(246, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1247, 'aaryan.patel2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(247, 1247, '20CSE0007', 'CSE-07', 'Aaryan Patel', 'aaryan.patel2020@college.local', '+91 92001 00007', '2002-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(247, 8.95, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(247, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1248, 'sandhya.iyer2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(248, 1248, '20CSE0008', 'CSE-08', 'Sandhya Iyer', 'sandhya.iyer2020@college.local', '+91 92001 00008', '2002-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(248, 9.3, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(248, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1249, 'rahul.pillai2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(249, 1249, '20ECE0001', 'ECE-01', 'Rahul Pillai', 'rahul.pillai2020@college.local', '+91 92002 00001', '2002-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(249, 6.85, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(249, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1250, 'pallavi.banerjee2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(250, 1250, '20ECE0002', 'ECE-02', 'Pallavi Banerjee', 'pallavi.banerjee2020@college.local', '+91 92002 00002', '2002-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(250, 7.2, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(250, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1251, 'rakesh.sen2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(251, 1251, '20ECE0003', 'ECE-03', 'Rakesh Sen', 'rakesh.sen2020@college.local', '+91 92002 00003', '2002-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(251, 7.55, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(251, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1252, 'navya.dutta2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(252, 1252, '20ECE0004', 'ECE-04', 'Navya Dutta', 'navya.dutta2020@college.local', '+91 92002 00004', '2002-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(252, 7.9, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(252, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1253, 'sai.mitra2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(253, 1253, '20ECE0005', 'ECE-05', 'Sai Mitra', 'sai.mitra2020@college.local', '+91 92002 00005', '2002-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(253, 8.25, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(253, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1254, 'kavya.reddy2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(254, 1254, '20ECE0006', 'ECE-06', 'Kavya Reddy', 'kavya.reddy2020@college.local', '+91 92002 00006', '2002-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(254, 8.6, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(254, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1255, 'aaryan.nair2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(255, 1255, '20ECE0007', 'ECE-07', 'Aaryan Nair', 'aaryan.nair2020@college.local', '+91 92002 00007', '2002-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(255, 8.95, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(255, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1256, 'sandhya.singh2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(256, 1256, '20ECE0008', 'ECE-08', 'Sandhya Singh', 'sandhya.singh2020@college.local', '+91 92002 00008', '2002-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(256, 9.3, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(256, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1257, 'rahul.das2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(257, 1257, '20EEE0001', 'EEE-01', 'Rahul Das', 'rahul.das2020@college.local', '+91 92003 00001', '2002-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(257, 6.85, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(257, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1258, 'pallavi.mukherjee2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(258, 1258, '20EEE0002', 'EEE-02', 'Pallavi Mukherjee', 'pallavi.mukherjee2020@college.local', '+91 92003 00002', '2002-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(258, 7.2, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(258, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1259, 'rakesh.ghosh2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(259, 1259, '20EEE0003', 'EEE-03', 'Rakesh Ghosh', 'rakesh.ghosh2020@college.local', '+91 92003 00003', '2002-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(259, 7.55, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(259, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1260, 'navya.chakraborty2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(260, 1260, '20EEE0004', 'EEE-04', 'Navya Chakraborty', 'navya.chakraborty2020@college.local', '+91 92003 00004', '2002-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(260, 7.9, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(260, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1261, 'sai.verma2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(261, 1261, '20EEE0005', 'EEE-05', 'Sai Verma', 'sai.verma2020@college.local', '+91 92003 00005', '2002-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(261, 8.25, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(261, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1262, 'kavya.rao2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(262, 1262, '20EEE0006', 'EEE-06', 'Kavya Rao', 'kavya.rao2020@college.local', '+91 92003 00006', '2002-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(262, 8.6, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(262, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1263, 'aaryan.gupta2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(263, 1263, '20EEE0007', 'EEE-07', 'Aaryan Gupta', 'aaryan.gupta2020@college.local', '+91 92003 00007', '2002-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(263, 8.95, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(263, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1264, 'sandhya.chowdhury2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(264, 1264, '20EEE0008', 'EEE-08', 'Sandhya Chowdhury', 'sandhya.chowdhury2020@college.local', '+91 92003 00008', '2002-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(264, 9.3, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(264, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1265, 'rahul.chatterjee2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(265, 1265, '20MECH0001', 'MECH-01', 'Rahul Chatterjee', 'rahul.chatterjee2020@college.local', '+91 92004 00001', '2002-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(265, 6.85, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(265, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1266, 'pallavi.bose2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(266, 1266, '20MECH0002', 'MECH-02', 'Pallavi Bose', 'pallavi.bose2020@college.local', '+91 92004 00002', '2002-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(266, 7.2, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(266, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1267, 'rakesh.roy2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(267, 1267, '20MECH0003', 'MECH-03', 'Rakesh Roy', 'rakesh.roy2020@college.local', '+91 92004 00003', '2002-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(267, 7.55, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(267, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1268, 'navya.sharma2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(268, 1268, '20MECH0004', 'MECH-04', 'Navya Sharma', 'navya.sharma2020@college.local', '+91 92004 00004', '2002-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(268, 7.9, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(268, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1269, 'sai.patel2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(269, 1269, '20MECH0005', 'MECH-05', 'Sai Patel', 'sai.patel2020@college.local', '+91 92004 00005', '2002-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(269, 8.25, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(269, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1270, 'kavya.iyer2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(270, 1270, '20MECH0006', 'MECH-06', 'Kavya Iyer', 'kavya.iyer2020@college.local', '+91 92004 00006', '2002-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(270, 8.6, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(270, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1271, 'aaryan.kumar2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(271, 1271, '20MECH0007', 'MECH-07', 'Aaryan Kumar', 'aaryan.kumar2020@college.local', '+91 92004 00007', '2002-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(271, 8.95, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(271, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1272, 'sandhya.joshi2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(272, 1272, '20MECH0008', 'MECH-08', 'Sandhya Joshi', 'sandhya.joshi2020@college.local', '+91 92004 00008', '2002-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(272, 9.3, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(272, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1273, 'rahul.sen2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(273, 1273, '20CIVIL0001', 'CIVIL-01', 'Rahul Sen', 'rahul.sen2020@college.local', '+91 92005 00001', '2002-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(273, 6.85, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(273, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1274, 'pallavi.dutta2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(274, 1274, '20CIVIL0002', 'CIVIL-02', 'Pallavi Dutta', 'pallavi.dutta2020@college.local', '+91 92005 00002', '2002-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(274, 7.2, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(274, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1275, 'rakesh.mitra2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(275, 1275, '20CIVIL0003', 'CIVIL-03', 'Rakesh Mitra', 'rakesh.mitra2020@college.local', '+91 92005 00003', '2002-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(275, 7.55, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(275, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1276, 'navya.reddy2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(276, 1276, '20CIVIL0004', 'CIVIL-04', 'Navya Reddy', 'navya.reddy2020@college.local', '+91 92005 00004', '2002-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(276, 7.9, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(276, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1277, 'sai.nair2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(277, 1277, '20CIVIL0005', 'CIVIL-05', 'Sai Nair', 'sai.nair2020@college.local', '+91 92005 00005', '2002-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(277, 8.25, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(277, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1278, 'kavya.singh2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(278, 1278, '20CIVIL0006', 'CIVIL-06', 'Kavya Singh', 'kavya.singh2020@college.local', '+91 92005 00006', '2002-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(278, 8.6, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(278, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1279, 'aaryan.mishra2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(279, 1279, '20CIVIL0007', 'CIVIL-07', 'Aaryan Mishra', 'aaryan.mishra2020@college.local', '+91 92005 00007', '2002-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(279, 8.95, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(279, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1280, 'sandhya.deshmukh2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(280, 1280, '20CIVIL0008', 'CIVIL-08', 'Sandhya Deshmukh', 'sandhya.deshmukh2020@college.local', '+91 92005 00008', '2002-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(280, 9.3, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(280, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1281, 'rahul.ghosh2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(281, 1281, '20IT0001', 'IT-01', 'Rahul Ghosh', 'rahul.ghosh2020@college.local', '+91 92006 00001', '2002-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(281, 6.85, 96.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(281, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1282, 'pallavi.chakraborty2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(282, 1282, '20IT0002', 'IT-02', 'Pallavi Chakraborty', 'pallavi.chakraborty2020@college.local', '+91 92006 00002', '2002-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(282, 7.2, 76.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(282, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1283, 'rakesh.verma2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(283, 1283, '20IT0003', 'IT-03', 'Rakesh Verma', 'rakesh.verma2020@college.local', '+91 92006 00003', '2002-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(283, 7.55, 78.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(283, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1284, 'navya.rao2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(284, 1284, '20IT0004', 'IT-04', 'Navya Rao', 'navya.rao2020@college.local', '+91 92006 00004', '2002-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(284, 7.9, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(284, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1285, 'sai.gupta2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(285, 1285, '20IT0005', 'IT-05', 'Sai Gupta', 'sai.gupta2020@college.local', '+91 92006 00005', '2002-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(285, 8.25, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(285, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1286, 'kavya.chowdhury2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(286, 1286, '20IT0006', 'IT-06', 'Kavya Chowdhury', 'kavya.chowdhury2020@college.local', '+91 92006 00006', '2002-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(286, 8.6, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(286, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1287, 'aaryan.kulkarni2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(287, 1287, '20IT0007', 'IT-07', 'Aaryan Kulkarni', 'aaryan.kulkarni2020@college.local', '+91 92006 00007', '2002-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(287, 8.95, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(287, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1288, 'sandhya.hegde2020@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(288, 1288, '20IT0008', 'IT-08', 'Sandhya Hegde', 'sandhya.hegde2020@college.local', '+91 92006 00008', '2002-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2020, 2024, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(288, 9.3, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(288, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1289, 'varun.hegde2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(289, 1289, '21CSE0001', 'CSE-01', 'Varun Hegde', 'varun.hegde2021@college.local', '+91 92101 00001', '2003-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(289, 7.05, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(289, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1290, 'ramya.das2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(290, 1290, '21CSE0002', 'CSE-02', 'Ramya Das', 'ramya.das2021@college.local', '+91 92101 00002', '2003-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(290, 7.4, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(290, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1291, 'suresh.mukherjee2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(291, 1291, '21CSE0003', 'CSE-03', 'Suresh Mukherjee', 'suresh.mukherjee2021@college.local', '+91 92101 00003', '2003-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(291, 7.75, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(291, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1292, 'angel.ghosh2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(292, 1292, '21CSE0004', 'CSE-04', 'Angel Ghosh', 'angel.ghosh2021@college.local', '+91 92101 00004', '2003-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(292, 8.1, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(292, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1293, 'reyansh.chakraborty2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(293, 1293, '21CSE0005', 'CSE-05', 'Reyansh Chakraborty', 'reyansh.chakraborty2021@college.local', '+91 92101 00005', '2003-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(293, 8.45, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(293, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1294, 'swati.verma2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(294, 1294, '21CSE0006', 'CSE-06', 'Swati Verma', 'swati.verma2021@college.local', '+91 92101 00006', '2003-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(294, 8.8, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(294, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1295, 'dhruv.rao2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(295, 1295, '21CSE0007', 'CSE-07', 'Dhruv Rao', 'dhruv.rao2021@college.local', '+91 92101 00007', '2003-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(295, 9.15, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(295, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1296, 'tejaswi.gupta2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(296, 1296, '21CSE0008', 'CSE-08', 'Tejaswi Gupta', 'tejaswi.gupta2021@college.local', '+91 92101 00008', '2003-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(296, 9.5, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(296, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1297, 'varun.menon2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(297, 1297, '21ECE0001', 'ECE-01', 'Varun Menon', 'varun.menon2021@college.local', '+91 92102 00001', '2003-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(297, 7.05, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(297, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1298, 'ramya.chatterjee2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(298, 1298, '21ECE0002', 'ECE-02', 'Ramya Chatterjee', 'ramya.chatterjee2021@college.local', '+91 92102 00002', '2003-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(298, 7.4, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(298, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1299, 'suresh.bose2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(299, 1299, '21ECE0003', 'ECE-03', 'Suresh Bose', 'suresh.bose2021@college.local', '+91 92102 00003', '2003-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(299, 7.75, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(299, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1300, 'angel.roy2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(300, 1300, '21ECE0004', 'ECE-04', 'Angel Roy', 'angel.roy2021@college.local', '+91 92102 00004', '2003-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(300, 8.1, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(300, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1301, 'reyansh.sharma2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(301, 1301, '21ECE0005', 'ECE-05', 'Reyansh Sharma', 'reyansh.sharma2021@college.local', '+91 92102 00005', '2003-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(301, 8.45, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(301, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1302, 'swati.patel2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(302, 1302, '21ECE0006', 'ECE-06', 'Swati Patel', 'swati.patel2021@college.local', '+91 92102 00006', '2003-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(302, 8.8, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(302, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1303, 'dhruv.iyer2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(303, 1303, '21ECE0007', 'ECE-07', 'Dhruv Iyer', 'dhruv.iyer2021@college.local', '+91 92102 00007', '2003-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(303, 9.15, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(303, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1304, 'tejaswi.kumar2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(304, 1304, '21ECE0008', 'ECE-08', 'Tejaswi Kumar', 'tejaswi.kumar2021@college.local', '+91 92102 00008', '2003-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(304, 9.5, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(304, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1305, 'varun.banerjee2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(305, 1305, '21EEE0001', 'EEE-01', 'Varun Banerjee', 'varun.banerjee2021@college.local', '+91 92103 00001', '2003-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(305, 7.05, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(305, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1306, 'ramya.sen2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(306, 1306, '21EEE0002', 'EEE-02', 'Ramya Sen', 'ramya.sen2021@college.local', '+91 92103 00002', '2003-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(306, 7.4, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(306, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1307, 'suresh.dutta2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(307, 1307, '21EEE0003', 'EEE-03', 'Suresh Dutta', 'suresh.dutta2021@college.local', '+91 92103 00003', '2003-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(307, 7.75, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(307, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1308, 'angel.mitra2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(308, 1308, '21EEE0004', 'EEE-04', 'Angel Mitra', 'angel.mitra2021@college.local', '+91 92103 00004', '2003-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(308, 8.1, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(308, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1309, 'reyansh.reddy2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(309, 1309, '21EEE0005', 'EEE-05', 'Reyansh Reddy', 'reyansh.reddy2021@college.local', '+91 92103 00005', '2003-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(309, 8.45, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(309, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1310, 'swati.nair2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(310, 1310, '21EEE0006', 'EEE-06', 'Swati Nair', 'swati.nair2021@college.local', '+91 92103 00006', '2003-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(310, 8.8, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(310, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1311, 'dhruv.singh2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(311, 1311, '21EEE0007', 'EEE-07', 'Dhruv Singh', 'dhruv.singh2021@college.local', '+91 92103 00007', '2003-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(311, 9.15, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(311, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1312, 'tejaswi.mishra2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(312, 1312, '21EEE0008', 'EEE-08', 'Tejaswi Mishra', 'tejaswi.mishra2021@college.local', '+91 92103 00008', '2003-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(312, 9.5, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(312, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1313, 'varun.mukherjee2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(313, 1313, '21MECH0001', 'MECH-01', 'Varun Mukherjee', 'varun.mukherjee2021@college.local', '+91 92104 00001', '2003-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(313, 7.05, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(313, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1314, 'ramya.ghosh2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(314, 1314, '21MECH0002', 'MECH-02', 'Ramya Ghosh', 'ramya.ghosh2021@college.local', '+91 92104 00002', '2003-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(314, 7.4, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(314, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1315, 'suresh.chakraborty2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(315, 1315, '21MECH0003', 'MECH-03', 'Suresh Chakraborty', 'suresh.chakraborty2021@college.local', '+91 92104 00003', '2003-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(315, 7.75, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(315, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1316, 'angel.verma2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(316, 1316, '21MECH0004', 'MECH-04', 'Angel Verma', 'angel.verma2021@college.local', '+91 92104 00004', '2003-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(316, 8.1, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(316, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1317, 'reyansh.rao2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(317, 1317, '21MECH0005', 'MECH-05', 'Reyansh Rao', 'reyansh.rao2021@college.local', '+91 92104 00005', '2003-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(317, 8.45, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(317, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1318, 'swati.gupta2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(318, 1318, '21MECH0006', 'MECH-06', 'Swati Gupta', 'swati.gupta2021@college.local', '+91 92104 00006', '2003-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(318, 8.8, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(318, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1319, 'dhruv.chowdhury2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(319, 1319, '21MECH0007', 'MECH-07', 'Dhruv Chowdhury', 'dhruv.chowdhury2021@college.local', '+91 92104 00007', '2003-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(319, 9.15, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(319, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1320, 'tejaswi.kulkarni2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(320, 1320, '21MECH0008', 'MECH-08', 'Tejaswi Kulkarni', 'tejaswi.kulkarni2021@college.local', '+91 92104 00008', '2003-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(320, 9.5, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(320, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1321, 'varun.bose2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(321, 1321, '21CIVIL0001', 'CIVIL-01', 'Varun Bose', 'varun.bose2021@college.local', '+91 92105 00001', '2003-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(321, 7.05, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(321, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1322, 'ramya.roy2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(322, 1322, '21CIVIL0002', 'CIVIL-02', 'Ramya Roy', 'ramya.roy2021@college.local', '+91 92105 00002', '2003-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(322, 7.4, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(322, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1323, 'suresh.sharma2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(323, 1323, '21CIVIL0003', 'CIVIL-03', 'Suresh Sharma', 'suresh.sharma2021@college.local', '+91 92105 00003', '2003-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(323, 7.75, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(323, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1324, 'angel.patel2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(324, 1324, '21CIVIL0004', 'CIVIL-04', 'Angel Patel', 'angel.patel2021@college.local', '+91 92105 00004', '2003-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(324, 8.1, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(324, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1325, 'reyansh.iyer2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(325, 1325, '21CIVIL0005', 'CIVIL-05', 'Reyansh Iyer', 'reyansh.iyer2021@college.local', '+91 92105 00005', '2003-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(325, 8.45, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(325, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1326, 'swati.kumar2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(326, 1326, '21CIVIL0006', 'CIVIL-06', 'Swati Kumar', 'swati.kumar2021@college.local', '+91 92105 00006', '2003-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(326, 8.8, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(326, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1327, 'dhruv.joshi2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(327, 1327, '21CIVIL0007', 'CIVIL-07', 'Dhruv Joshi', 'dhruv.joshi2021@college.local', '+91 92105 00007', '2003-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(327, 9.15, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(327, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1328, 'tejaswi.bhat2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(328, 1328, '21CIVIL0008', 'CIVIL-08', 'Tejaswi Bhat', 'tejaswi.bhat2021@college.local', '+91 92105 00008', '2003-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(328, 9.5, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(328, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1329, 'varun.dutta2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(329, 1329, '21IT0001', 'IT-01', 'Varun Dutta', 'varun.dutta2021@college.local', '+91 92106 00001', '2003-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(329, 7.05, 97.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(329, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1330, 'ramya.mitra2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(330, 1330, '21IT0002', 'IT-02', 'Ramya Mitra', 'ramya.mitra2021@college.local', '+91 92106 00002', '2003-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(330, 7.4, 77.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(330, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1331, 'suresh.reddy2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(331, 1331, '21IT0003', 'IT-03', 'Suresh Reddy', 'suresh.reddy2021@college.local', '+91 92106 00003', '2003-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(331, 7.75, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(331, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1332, 'angel.nair2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(332, 1332, '21IT0004', 'IT-04', 'Angel Nair', 'angel.nair2021@college.local', '+91 92106 00004', '2003-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(332, 8.1, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(332, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1333, 'reyansh.singh2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(333, 1333, '21IT0005', 'IT-05', 'Reyansh Singh', 'reyansh.singh2021@college.local', '+91 92106 00005', '2003-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(333, 8.45, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(333, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1334, 'swati.mishra2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(334, 1334, '21IT0006', 'IT-06', 'Swati Mishra', 'swati.mishra2021@college.local', '+91 92106 00006', '2003-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(334, 8.8, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(334, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1335, 'dhruv.deshmukh2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(335, 1335, '21IT0007', 'IT-07', 'Dhruv Deshmukh', 'dhruv.deshmukh2021@college.local', '+91 92106 00007', '2003-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(335, 9.15, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(335, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1336, 'tejaswi.pillai2021@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(336, 1336, '21IT0008', 'IT-08', 'Tejaswi Pillai', 'tejaswi.pillai2021@college.local', '+91 92106 00008', '2003-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2021, 2025, 8, 4, 'GRADUATED');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(336, 9.5, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(336, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1337, 'karthik.pillai2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(337, 1337, '22CSE0001', 'CSE-01', 'Karthik Pillai', 'karthik.pillai2022@college.local', '+91 92201 00001', '2004-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(337, 7.25, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(337, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1338, 'sandhya.banerjee2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(338, 1338, '22CSE0002', 'CSE-02', 'Sandhya Banerjee', 'sandhya.banerjee2022@college.local', '+91 92201 00002', '2004-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(338, 7.6, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(338, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1339, 'ramesh.sen2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(339, 1339, '22CSE0003', 'CSE-03', 'Ramesh Sen', 'ramesh.sen2022@college.local', '+91 92201 00003', '2004-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(339, 7.95, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(339, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1340, 'myra.dutta2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(340, 1340, '22CSE0004', 'CSE-04', 'Myra Dutta', 'myra.dutta2022@college.local', '+91 92201 00004', '2004-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(340, 8.3, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(340, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1341, 'ayaan.mitra2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(341, 1341, '22CSE0005', 'CSE-05', 'Ayaan Mitra', 'ayaan.mitra2022@college.local', '+91 92201 00005', '2004-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(341, 8.65, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(341, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1342, 'sneha.reddy2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(342, 1342, '22CSE0006', 'CSE-06', 'Sneha Reddy', 'sneha.reddy2022@college.local', '+91 92201 00006', '2004-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(342, 9.0, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(342, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1343, 'kabir.nair2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(343, 1343, '22CSE0007', 'CSE-07', 'Kabir Nair', 'kabir.nair2022@college.local', '+91 92201 00007', '2004-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(343, 9.35, 90.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(343, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1344, 'vandana.singh2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(344, 1344, '22CSE0008', 'CSE-08', 'Vandana Singh', 'vandana.singh2022@college.local', '+91 92201 00008', '2004-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(344, 9.7, 93.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(344, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1345, 'karthik.das2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(345, 1345, '22ECE0001', 'ECE-01', 'Karthik Das', 'karthik.das2022@college.local', '+91 92202 00001', '2004-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(345, 7.25, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(345, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1346, 'sandhya.mukherjee2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(346, 1346, '22ECE0002', 'ECE-02', 'Sandhya Mukherjee', 'sandhya.mukherjee2022@college.local', '+91 92202 00002', '2004-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(346, 7.6, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(346, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1347, 'ramesh.ghosh2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(347, 1347, '22ECE0003', 'ECE-03', 'Ramesh Ghosh', 'ramesh.ghosh2022@college.local', '+91 92202 00003', '2004-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(347, 7.95, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(347, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1348, 'myra.chakraborty2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(348, 1348, '22ECE0004', 'ECE-04', 'Myra Chakraborty', 'myra.chakraborty2022@college.local', '+91 92202 00004', '2004-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(348, 8.3, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(348, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1349, 'ayaan.verma2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(349, 1349, '22ECE0005', 'ECE-05', 'Ayaan Verma', 'ayaan.verma2022@college.local', '+91 92202 00005', '2004-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(349, 8.65, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(349, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1350, 'sneha.rao2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(350, 1350, '22ECE0006', 'ECE-06', 'Sneha Rao', 'sneha.rao2022@college.local', '+91 92202 00006', '2004-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(350, 9.0, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(350, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1351, 'kabir.gupta2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(351, 1351, '22ECE0007', 'ECE-07', 'Kabir Gupta', 'kabir.gupta2022@college.local', '+91 92202 00007', '2004-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(351, 9.35, 90.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(351, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1352, 'vandana.chowdhury2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(352, 1352, '22ECE0008', 'ECE-08', 'Vandana Chowdhury', 'vandana.chowdhury2022@college.local', '+91 92202 00008', '2004-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(352, 9.7, 93.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(352, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1353, 'karthik.chatterjee2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(353, 1353, '22EEE0001', 'EEE-01', 'Karthik Chatterjee', 'karthik.chatterjee2022@college.local', '+91 92203 00001', '2004-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(353, 7.25, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(353, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1354, 'sandhya.bose2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(354, 1354, '22EEE0002', 'EEE-02', 'Sandhya Bose', 'sandhya.bose2022@college.local', '+91 92203 00002', '2004-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(354, 7.6, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(354, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1355, 'ramesh.roy2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(355, 1355, '22EEE0003', 'EEE-03', 'Ramesh Roy', 'ramesh.roy2022@college.local', '+91 92203 00003', '2004-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(355, 7.95, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(355, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1356, 'myra.sharma2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(356, 1356, '22EEE0004', 'EEE-04', 'Myra Sharma', 'myra.sharma2022@college.local', '+91 92203 00004', '2004-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(356, 8.3, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(356, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1357, 'ayaan.patel2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(357, 1357, '22EEE0005', 'EEE-05', 'Ayaan Patel', 'ayaan.patel2022@college.local', '+91 92203 00005', '2004-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(357, 8.65, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(357, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1358, 'sneha.iyer2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(358, 1358, '22EEE0006', 'EEE-06', 'Sneha Iyer', 'sneha.iyer2022@college.local', '+91 92203 00006', '2004-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(358, 9.0, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(358, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1359, 'kabir.kumar2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(359, 1359, '22EEE0007', 'EEE-07', 'Kabir Kumar', 'kabir.kumar2022@college.local', '+91 92203 00007', '2004-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(359, 9.35, 90.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(359, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1360, 'vandana.joshi2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(360, 1360, '22EEE0008', 'EEE-08', 'Vandana Joshi', 'vandana.joshi2022@college.local', '+91 92203 00008', '2004-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(360, 9.7, 93.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(360, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1361, 'karthik.sen2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(361, 1361, '22MECH0001', 'MECH-01', 'Karthik Sen', 'karthik.sen2022@college.local', '+91 92204 00001', '2004-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(361, 7.25, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(361, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1362, 'sandhya.dutta2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(362, 1362, '22MECH0002', 'MECH-02', 'Sandhya Dutta', 'sandhya.dutta2022@college.local', '+91 92204 00002', '2004-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(362, 7.6, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(362, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1363, 'ramesh.mitra2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(363, 1363, '22MECH0003', 'MECH-03', 'Ramesh Mitra', 'ramesh.mitra2022@college.local', '+91 92204 00003', '2004-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(363, 7.95, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(363, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1364, 'myra.reddy2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(364, 1364, '22MECH0004', 'MECH-04', 'Myra Reddy', 'myra.reddy2022@college.local', '+91 92204 00004', '2004-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(364, 8.3, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(364, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1365, 'ayaan.nair2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(365, 1365, '22MECH0005', 'MECH-05', 'Ayaan Nair', 'ayaan.nair2022@college.local', '+91 92204 00005', '2004-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(365, 8.65, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(365, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1366, 'sneha.singh2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(366, 1366, '22MECH0006', 'MECH-06', 'Sneha Singh', 'sneha.singh2022@college.local', '+91 92204 00006', '2004-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(366, 9.0, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(366, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1367, 'kabir.mishra2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(367, 1367, '22MECH0007', 'MECH-07', 'Kabir Mishra', 'kabir.mishra2022@college.local', '+91 92204 00007', '2004-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(367, 9.35, 90.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(367, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1368, 'vandana.deshmukh2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(368, 1368, '22MECH0008', 'MECH-08', 'Vandana Deshmukh', 'vandana.deshmukh2022@college.local', '+91 92204 00008', '2004-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(368, 9.7, 93.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(368, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1369, 'karthik.ghosh2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(369, 1369, '22CIVIL0001', 'CIVIL-01', 'Karthik Ghosh', 'karthik.ghosh2022@college.local', '+91 92205 00001', '2004-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(369, 7.25, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(369, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1370, 'sandhya.chakraborty2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(370, 1370, '22CIVIL0002', 'CIVIL-02', 'Sandhya Chakraborty', 'sandhya.chakraborty2022@college.local', '+91 92205 00002', '2004-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(370, 7.6, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(370, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1371, 'ramesh.verma2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(371, 1371, '22CIVIL0003', 'CIVIL-03', 'Ramesh Verma', 'ramesh.verma2022@college.local', '+91 92205 00003', '2004-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(371, 7.95, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(371, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1372, 'myra.rao2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(372, 1372, '22CIVIL0004', 'CIVIL-04', 'Myra Rao', 'myra.rao2022@college.local', '+91 92205 00004', '2004-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(372, 8.3, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(372, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1373, 'ayaan.gupta2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(373, 1373, '22CIVIL0005', 'CIVIL-05', 'Ayaan Gupta', 'ayaan.gupta2022@college.local', '+91 92205 00005', '2004-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(373, 8.65, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(373, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1374, 'sneha.chowdhury2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(374, 1374, '22CIVIL0006', 'CIVIL-06', 'Sneha Chowdhury', 'sneha.chowdhury2022@college.local', '+91 92205 00006', '2004-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(374, 9.0, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(374, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1375, 'kabir.kulkarni2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(375, 1375, '22CIVIL0007', 'CIVIL-07', 'Kabir Kulkarni', 'kabir.kulkarni2022@college.local', '+91 92205 00007', '2004-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(375, 9.35, 90.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(375, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1376, 'vandana.hegde2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(376, 1376, '22CIVIL0008', 'CIVIL-08', 'Vandana Hegde', 'vandana.hegde2022@college.local', '+91 92205 00008', '2004-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(376, 9.7, 93.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(376, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1377, 'karthik.roy2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(377, 1377, '22IT0001', 'IT-01', 'Karthik Roy', 'karthik.roy2022@college.local', '+91 92206 00001', '2004-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(377, 7.25, 75.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(377, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1378, 'sandhya.sharma2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(378, 1378, '22IT0002', 'IT-02', 'Sandhya Sharma', 'sandhya.sharma2022@college.local', '+91 92206 00002', '2004-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(378, 7.6, 78.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(378, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1379, 'ramesh.patel2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(379, 1379, '22IT0003', 'IT-03', 'Ramesh Patel', 'ramesh.patel2022@college.local', '+91 92206 00003', '2004-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(379, 7.95, 80.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(379, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1380, 'myra.iyer2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(380, 1380, '22IT0004', 'IT-04', 'Myra Iyer', 'myra.iyer2022@college.local', '+91 92206 00004', '2004-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(380, 8.3, 83.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(380, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1381, 'ayaan.kumar2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(381, 1381, '22IT0005', 'IT-05', 'Ayaan Kumar', 'ayaan.kumar2022@college.local', '+91 92206 00005', '2004-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(381, 8.65, 85.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(381, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1382, 'sneha.joshi2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(382, 1382, '22IT0006', 'IT-06', 'Sneha Joshi', 'sneha.joshi2022@college.local', '+91 92206 00006', '2004-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(382, 9.0, 88.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(382, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1383, 'kabir.bhat2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(383, 1383, '22IT0007', 'IT-07', 'Kabir Bhat', 'kabir.bhat2022@college.local', '+91 92206 00007', '2004-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(383, 9.35, 90.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(383, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1384, 'vandana.menon2022@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(384, 1384, '22IT0008', 'IT-08', 'Vandana Menon', 'vandana.menon2022@college.local', '+91 92206 00008', '2004-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2022, 2026, 7, 4, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(384, 9.7, 93.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(384, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1385, 'abhishek.menon2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(385, 1385, '23CSE0001', 'CSE-01', 'Abhishek Menon', 'abhishek.menon2023@college.local', '+91 92301 00001', '2005-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(385, 7.45, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(385, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1386, 'tejaswi.chatterjee2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(386, 1386, '23CSE0002', 'CSE-02', 'Tejaswi Chatterjee', 'tejaswi.chatterjee2023@college.local', '+91 92301 00002', '2005-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(386, 7.8, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(386, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1387, 'dinesh.bose2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(387, 1387, '23CSE0003', 'CSE-03', 'Dinesh Bose', 'dinesh.bose2023@college.local', '+91 92301 00003', '2005-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(387, 8.15, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(387, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1388, 'sara.roy2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(388, 1388, '23CSE0004', 'CSE-04', 'Sara Roy', 'sara.roy2023@college.local', '+91 92301 00004', '2005-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(388, 8.5, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(388, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1389, 'krishna.sharma2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(389, 1389, '23CSE0005', 'CSE-05', 'Krishna Sharma', 'krishna.sharma2023@college.local', '+91 92301 00005', '2005-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(389, 8.85, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(389, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1390, 'divya.patel2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(390, 1390, '23CSE0006', 'CSE-06', 'Divya Patel', 'divya.patel2023@college.local', '+91 92301 00006', '2005-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(390, 9.2, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(390, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1391, 'ritvik.iyer2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(391, 1391, '23CSE0007', 'CSE-07', 'Ritvik Iyer', 'ritvik.iyer2023@college.local', '+91 92301 00007', '2005-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(391, 9.55, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(391, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1392, 'yamini.kumar2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(392, 1392, '23CSE0008', 'CSE-08', 'Yamini Kumar', 'yamini.kumar2023@college.local', '+91 92301 00008', '2005-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(392, 6.5, 94.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(392, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1393, 'abhishek.banerjee2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(393, 1393, '23ECE0001', 'ECE-01', 'Abhishek Banerjee', 'abhishek.banerjee2023@college.local', '+91 92302 00001', '2005-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(393, 7.45, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(393, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1394, 'tejaswi.sen2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(394, 1394, '23ECE0002', 'ECE-02', 'Tejaswi Sen', 'tejaswi.sen2023@college.local', '+91 92302 00002', '2005-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(394, 7.8, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(394, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1395, 'dinesh.dutta2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(395, 1395, '23ECE0003', 'ECE-03', 'Dinesh Dutta', 'dinesh.dutta2023@college.local', '+91 92302 00003', '2005-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(395, 8.15, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(395, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1396, 'sara.mitra2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(396, 1396, '23ECE0004', 'ECE-04', 'Sara Mitra', 'sara.mitra2023@college.local', '+91 92302 00004', '2005-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(396, 8.5, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(396, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1397, 'krishna.reddy2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(397, 1397, '23ECE0005', 'ECE-05', 'Krishna Reddy', 'krishna.reddy2023@college.local', '+91 92302 00005', '2005-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(397, 8.85, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(397, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1398, 'divya.nair2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(398, 1398, '23ECE0006', 'ECE-06', 'Divya Nair', 'divya.nair2023@college.local', '+91 92302 00006', '2005-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(398, 9.2, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(398, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1399, 'ritvik.singh2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(399, 1399, '23ECE0007', 'ECE-07', 'Ritvik Singh', 'ritvik.singh2023@college.local', '+91 92302 00007', '2005-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(399, 9.55, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(399, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1400, 'yamini.mishra2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(400, 1400, '23ECE0008', 'ECE-08', 'Yamini Mishra', 'yamini.mishra2023@college.local', '+91 92302 00008', '2005-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(400, 6.5, 94.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(400, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1401, 'abhishek.mukherjee2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(401, 1401, '23EEE0001', 'EEE-01', 'Abhishek Mukherjee', 'abhishek.mukherjee2023@college.local', '+91 92303 00001', '2005-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(401, 7.45, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(401, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1402, 'tejaswi.ghosh2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(402, 1402, '23EEE0002', 'EEE-02', 'Tejaswi Ghosh', 'tejaswi.ghosh2023@college.local', '+91 92303 00002', '2005-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(402, 7.8, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(402, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1403, 'dinesh.chakraborty2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(403, 1403, '23EEE0003', 'EEE-03', 'Dinesh Chakraborty', 'dinesh.chakraborty2023@college.local', '+91 92303 00003', '2005-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(403, 8.15, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(403, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1404, 'sara.verma2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(404, 1404, '23EEE0004', 'EEE-04', 'Sara Verma', 'sara.verma2023@college.local', '+91 92303 00004', '2005-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(404, 8.5, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(404, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1405, 'krishna.rao2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(405, 1405, '23EEE0005', 'EEE-05', 'Krishna Rao', 'krishna.rao2023@college.local', '+91 92303 00005', '2005-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(405, 8.85, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(405, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1406, 'divya.gupta2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(406, 1406, '23EEE0006', 'EEE-06', 'Divya Gupta', 'divya.gupta2023@college.local', '+91 92303 00006', '2005-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(406, 9.2, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(406, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1407, 'ritvik.chowdhury2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(407, 1407, '23EEE0007', 'EEE-07', 'Ritvik Chowdhury', 'ritvik.chowdhury2023@college.local', '+91 92303 00007', '2005-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(407, 9.55, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(407, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1408, 'yamini.kulkarni2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(408, 1408, '23EEE0008', 'EEE-08', 'Yamini Kulkarni', 'yamini.kulkarni2023@college.local', '+91 92303 00008', '2005-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(408, 6.5, 94.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(408, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1409, 'abhishek.bose2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(409, 1409, '23MECH0001', 'MECH-01', 'Abhishek Bose', 'abhishek.bose2023@college.local', '+91 92304 00001', '2005-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(409, 7.45, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(409, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1410, 'tejaswi.roy2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(410, 1410, '23MECH0002', 'MECH-02', 'Tejaswi Roy', 'tejaswi.roy2023@college.local', '+91 92304 00002', '2005-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(410, 7.8, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(410, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1411, 'dinesh.sharma2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(411, 1411, '23MECH0003', 'MECH-03', 'Dinesh Sharma', 'dinesh.sharma2023@college.local', '+91 92304 00003', '2005-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(411, 8.15, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(411, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1412, 'sara.patel2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(412, 1412, '23MECH0004', 'MECH-04', 'Sara Patel', 'sara.patel2023@college.local', '+91 92304 00004', '2005-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(412, 8.5, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(412, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1413, 'krishna.iyer2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(413, 1413, '23MECH0005', 'MECH-05', 'Krishna Iyer', 'krishna.iyer2023@college.local', '+91 92304 00005', '2005-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(413, 8.85, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(413, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1414, 'divya.kumar2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(414, 1414, '23MECH0006', 'MECH-06', 'Divya Kumar', 'divya.kumar2023@college.local', '+91 92304 00006', '2005-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(414, 9.2, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(414, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1415, 'ritvik.joshi2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(415, 1415, '23MECH0007', 'MECH-07', 'Ritvik Joshi', 'ritvik.joshi2023@college.local', '+91 92304 00007', '2005-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(415, 9.55, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(415, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1416, 'yamini.bhat2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(416, 1416, '23MECH0008', 'MECH-08', 'Yamini Bhat', 'yamini.bhat2023@college.local', '+91 92304 00008', '2005-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(416, 6.5, 94.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(416, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1417, 'abhishek.dutta2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(417, 1417, '23CIVIL0001', 'CIVIL-01', 'Abhishek Dutta', 'abhishek.dutta2023@college.local', '+91 92305 00001', '2005-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(417, 7.45, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(417, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1418, 'tejaswi.mitra2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(418, 1418, '23CIVIL0002', 'CIVIL-02', 'Tejaswi Mitra', 'tejaswi.mitra2023@college.local', '+91 92305 00002', '2005-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(418, 7.8, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(418, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1419, 'dinesh.reddy2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(419, 1419, '23CIVIL0003', 'CIVIL-03', 'Dinesh Reddy', 'dinesh.reddy2023@college.local', '+91 92305 00003', '2005-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(419, 8.15, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(419, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1420, 'sara.nair2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(420, 1420, '23CIVIL0004', 'CIVIL-04', 'Sara Nair', 'sara.nair2023@college.local', '+91 92305 00004', '2005-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(420, 8.5, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(420, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1421, 'krishna.singh2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(421, 1421, '23CIVIL0005', 'CIVIL-05', 'Krishna Singh', 'krishna.singh2023@college.local', '+91 92305 00005', '2005-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(421, 8.85, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(421, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1422, 'divya.mishra2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(422, 1422, '23CIVIL0006', 'CIVIL-06', 'Divya Mishra', 'divya.mishra2023@college.local', '+91 92305 00006', '2005-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(422, 9.2, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(422, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1423, 'ritvik.deshmukh2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(423, 1423, '23CIVIL0007', 'CIVIL-07', 'Ritvik Deshmukh', 'ritvik.deshmukh2023@college.local', '+91 92305 00007', '2005-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(423, 9.55, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(423, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1424, 'yamini.pillai2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(424, 1424, '23CIVIL0008', 'CIVIL-08', 'Yamini Pillai', 'yamini.pillai2023@college.local', '+91 92305 00008', '2005-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(424, 6.5, 94.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(424, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1425, 'abhishek.chakraborty2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(425, 1425, '23IT0001', 'IT-01', 'Abhishek Chakraborty', 'abhishek.chakraborty2023@college.local', '+91 92306 00001', '2005-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(425, 7.45, 76.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(425, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1426, 'tejaswi.verma2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(426, 1426, '23IT0002', 'IT-02', 'Tejaswi Verma', 'tejaswi.verma2023@college.local', '+91 92306 00002', '2005-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(426, 7.8, 79.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(426, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1427, 'dinesh.rao2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(427, 1427, '23IT0003', 'IT-03', 'Dinesh Rao', 'dinesh.rao2023@college.local', '+91 92306 00003', '2005-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(427, 8.15, 81.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(427, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1428, 'sara.gupta2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(428, 1428, '23IT0004', 'IT-04', 'Sara Gupta', 'sara.gupta2023@college.local', '+91 92306 00004', '2005-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(428, 8.5, 84.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(428, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1429, 'krishna.chowdhury2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(429, 1429, '23IT0005', 'IT-05', 'Krishna Chowdhury', 'krishna.chowdhury2023@college.local', '+91 92306 00005', '2005-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(429, 8.85, 86.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(429, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1430, 'divya.kulkarni2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(430, 1430, '23IT0006', 'IT-06', 'Divya Kulkarni', 'divya.kulkarni2023@college.local', '+91 92306 00006', '2005-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(430, 9.2, 89.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(430, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1431, 'ritvik.hegde2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(431, 1431, '23IT0007', 'IT-07', 'Ritvik Hegde', 'ritvik.hegde2023@college.local', '+91 92306 00007', '2005-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(431, 9.55, 91.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(431, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1432, 'yamini.das2023@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(432, 1432, '23IT0008', 'IT-08', 'Yamini Das', 'yamini.das2023@college.local', '+91 92306 00008', '2005-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2023, 2027, 5, 3, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(432, 6.5, 94.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(432, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1433, 'venkatesh.das2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(433, 1433, '24CSE0001', 'CSE-01', 'Venkatesh Das', 'venkatesh.das2024@college.local', '+91 92401 00001', '2006-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(433, 7.65, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(433, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1434, 'vandana.mukherjee2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(434, 1434, '24CSE0002', 'CSE-02', 'Vandana Mukherjee', 'vandana.mukherjee2024@college.local', '+91 92401 00002', '2006-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(434, 8.0, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(434, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1435, 'kiran.ghosh2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(435, 1435, '24CSE0003', 'CSE-03', 'Kiran Ghosh', 'kiran.ghosh2024@college.local', '+91 92401 00003', '2006-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(435, 8.35, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(435, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1436, 'ira.chakraborty2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(436, 1436, '24CSE0004', 'CSE-04', 'Ira Chakraborty', 'ira.chakraborty2024@college.local', '+91 92401 00004', '2006-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(436, 8.7, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(436, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1437, 'ishaan.verma2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(437, 1437, '24CSE0005', 'CSE-05', 'Ishaan Verma', 'ishaan.verma2024@college.local', '+91 92401 00005', '2006-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(437, 9.05, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(437, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1438, 'meera.rao2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(438, 1438, '24CSE0006', 'CSE-06', 'Meera Rao', 'meera.rao2024@college.local', '+91 92401 00006', '2006-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(438, 9.4, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(438, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1439, 'darsh.gupta2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(439, 1439, '24CSE0007', 'CSE-07', 'Darsh Gupta', 'darsh.gupta2024@college.local', '+91 92401 00007', '2006-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(439, 9.75, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(439, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1440, 'aanya.chowdhury2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(440, 1440, '24CSE0008', 'CSE-08', 'Aanya Chowdhury', 'aanya.chowdhury2024@college.local', '+91 92401 00008', '2006-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(440, 6.7, 95.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(440, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1441, 'venkatesh.chatterjee2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(441, 1441, '24ECE0001', 'ECE-01', 'Venkatesh Chatterjee', 'venkatesh.chatterjee2024@college.local', '+91 92402 00001', '2006-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(441, 7.65, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(441, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1442, 'vandana.bose2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(442, 1442, '24ECE0002', 'ECE-02', 'Vandana Bose', 'vandana.bose2024@college.local', '+91 92402 00002', '2006-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(442, 8.0, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(442, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1443, 'kiran.roy2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(443, 1443, '24ECE0003', 'ECE-03', 'Kiran Roy', 'kiran.roy2024@college.local', '+91 92402 00003', '2006-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(443, 8.35, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(443, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1444, 'ira.sharma2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(444, 1444, '24ECE0004', 'ECE-04', 'Ira Sharma', 'ira.sharma2024@college.local', '+91 92402 00004', '2006-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(444, 8.7, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(444, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1445, 'ishaan.patel2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(445, 1445, '24ECE0005', 'ECE-05', 'Ishaan Patel', 'ishaan.patel2024@college.local', '+91 92402 00005', '2006-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(445, 9.05, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(445, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1446, 'meera.iyer2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(446, 1446, '24ECE0006', 'ECE-06', 'Meera Iyer', 'meera.iyer2024@college.local', '+91 92402 00006', '2006-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(446, 9.4, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(446, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1447, 'darsh.kumar2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(447, 1447, '24ECE0007', 'ECE-07', 'Darsh Kumar', 'darsh.kumar2024@college.local', '+91 92402 00007', '2006-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(447, 9.75, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(447, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1448, 'aanya.joshi2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(448, 1448, '24ECE0008', 'ECE-08', 'Aanya Joshi', 'aanya.joshi2024@college.local', '+91 92402 00008', '2006-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(448, 6.7, 95.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(448, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1449, 'venkatesh.sen2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(449, 1449, '24EEE0001', 'EEE-01', 'Venkatesh Sen', 'venkatesh.sen2024@college.local', '+91 92403 00001', '2006-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(449, 7.65, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(449, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1450, 'vandana.dutta2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(450, 1450, '24EEE0002', 'EEE-02', 'Vandana Dutta', 'vandana.dutta2024@college.local', '+91 92403 00002', '2006-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(450, 8.0, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(450, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1451, 'kiran.mitra2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(451, 1451, '24EEE0003', 'EEE-03', 'Kiran Mitra', 'kiran.mitra2024@college.local', '+91 92403 00003', '2006-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(451, 8.35, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(451, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1452, 'ira.reddy2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(452, 1452, '24EEE0004', 'EEE-04', 'Ira Reddy', 'ira.reddy2024@college.local', '+91 92403 00004', '2006-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(452, 8.7, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(452, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1453, 'ishaan.nair2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(453, 1453, '24EEE0005', 'EEE-05', 'Ishaan Nair', 'ishaan.nair2024@college.local', '+91 92403 00005', '2006-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(453, 9.05, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(453, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1454, 'meera.singh2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(454, 1454, '24EEE0006', 'EEE-06', 'Meera Singh', 'meera.singh2024@college.local', '+91 92403 00006', '2006-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(454, 9.4, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(454, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1455, 'darsh.mishra2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(455, 1455, '24EEE0007', 'EEE-07', 'Darsh Mishra', 'darsh.mishra2024@college.local', '+91 92403 00007', '2006-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(455, 9.75, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(455, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1456, 'aanya.deshmukh2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(456, 1456, '24EEE0008', 'EEE-08', 'Aanya Deshmukh', 'aanya.deshmukh2024@college.local', '+91 92403 00008', '2006-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(456, 6.7, 95.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(456, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1457, 'venkatesh.ghosh2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(457, 1457, '24MECH0001', 'MECH-01', 'Venkatesh Ghosh', 'venkatesh.ghosh2024@college.local', '+91 92404 00001', '2006-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(457, 7.65, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(457, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1458, 'vandana.chakraborty2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(458, 1458, '24MECH0002', 'MECH-02', 'Vandana Chakraborty', 'vandana.chakraborty2024@college.local', '+91 92404 00002', '2006-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(458, 8.0, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(458, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1459, 'kiran.verma2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(459, 1459, '24MECH0003', 'MECH-03', 'Kiran Verma', 'kiran.verma2024@college.local', '+91 92404 00003', '2006-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(459, 8.35, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(459, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1460, 'ira.rao2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(460, 1460, '24MECH0004', 'MECH-04', 'Ira Rao', 'ira.rao2024@college.local', '+91 92404 00004', '2006-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(460, 8.7, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(460, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1461, 'ishaan.gupta2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(461, 1461, '24MECH0005', 'MECH-05', 'Ishaan Gupta', 'ishaan.gupta2024@college.local', '+91 92404 00005', '2006-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(461, 9.05, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(461, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1462, 'meera.chowdhury2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(462, 1462, '24MECH0006', 'MECH-06', 'Meera Chowdhury', 'meera.chowdhury2024@college.local', '+91 92404 00006', '2006-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(462, 9.4, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(462, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1463, 'darsh.kulkarni2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(463, 1463, '24MECH0007', 'MECH-07', 'Darsh Kulkarni', 'darsh.kulkarni2024@college.local', '+91 92404 00007', '2006-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(463, 9.75, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(463, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1464, 'aanya.hegde2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(464, 1464, '24MECH0008', 'MECH-08', 'Aanya Hegde', 'aanya.hegde2024@college.local', '+91 92404 00008', '2006-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(464, 6.7, 95.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(464, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1465, 'venkatesh.roy2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(465, 1465, '24CIVIL0001', 'CIVIL-01', 'Venkatesh Roy', 'venkatesh.roy2024@college.local', '+91 92405 00001', '2006-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(465, 7.65, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(465, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1466, 'vandana.sharma2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(466, 1466, '24CIVIL0002', 'CIVIL-02', 'Vandana Sharma', 'vandana.sharma2024@college.local', '+91 92405 00002', '2006-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(466, 8.0, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(466, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1467, 'kiran.patel2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(467, 1467, '24CIVIL0003', 'CIVIL-03', 'Kiran Patel', 'kiran.patel2024@college.local', '+91 92405 00003', '2006-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(467, 8.35, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(467, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1468, 'ira.iyer2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(468, 1468, '24CIVIL0004', 'CIVIL-04', 'Ira Iyer', 'ira.iyer2024@college.local', '+91 92405 00004', '2006-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(468, 8.7, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(468, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1469, 'ishaan.kumar2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(469, 1469, '24CIVIL0005', 'CIVIL-05', 'Ishaan Kumar', 'ishaan.kumar2024@college.local', '+91 92405 00005', '2006-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(469, 9.05, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(469, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1470, 'meera.joshi2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(470, 1470, '24CIVIL0006', 'CIVIL-06', 'Meera Joshi', 'meera.joshi2024@college.local', '+91 92405 00006', '2006-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(470, 9.4, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(470, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1471, 'darsh.bhat2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(471, 1471, '24CIVIL0007', 'CIVIL-07', 'Darsh Bhat', 'darsh.bhat2024@college.local', '+91 92405 00007', '2006-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(471, 9.75, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(471, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1472, 'aanya.menon2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(472, 1472, '24CIVIL0008', 'CIVIL-08', 'Aanya Menon', 'aanya.menon2024@college.local', '+91 92405 00008', '2006-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(472, 6.7, 95.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(472, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1473, 'venkatesh.mitra2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(473, 1473, '24IT0001', 'IT-01', 'Venkatesh Mitra', 'venkatesh.mitra2024@college.local', '+91 92406 00001', '2006-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(473, 7.65, 77.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(473, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1474, 'vandana.reddy2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(474, 1474, '24IT0002', 'IT-02', 'Vandana Reddy', 'vandana.reddy2024@college.local', '+91 92406 00002', '2006-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(474, 8.0, 80.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(474, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1475, 'kiran.nair2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(475, 1475, '24IT0003', 'IT-03', 'Kiran Nair', 'kiran.nair2024@college.local', '+91 92406 00003', '2006-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(475, 8.35, 82.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(475, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1476, 'ira.singh2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(476, 1476, '24IT0004', 'IT-04', 'Ira Singh', 'ira.singh2024@college.local', '+91 92406 00004', '2006-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(476, 8.7, 85.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(476, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1477, 'ishaan.mishra2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(477, 1477, '24IT0005', 'IT-05', 'Ishaan Mishra', 'ishaan.mishra2024@college.local', '+91 92406 00005', '2006-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(477, 9.05, 87.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(477, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1478, 'meera.deshmukh2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(478, 1478, '24IT0006', 'IT-06', 'Meera Deshmukh', 'meera.deshmukh2024@college.local', '+91 92406 00006', '2006-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(478, 9.4, 90.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(478, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1479, 'darsh.pillai2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(479, 1479, '24IT0007', 'IT-07', 'Darsh Pillai', 'darsh.pillai2024@college.local', '+91 92406 00007', '2006-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(479, 9.75, 92.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(479, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1480, 'aanya.banerjee2024@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(480, 1480, '24IT0008', 'IT-08', 'Aanya Banerjee', 'aanya.banerjee2024@college.local', '+91 92406 00008', '2006-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2024, 2028, 3, 2, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(480, 6.7, 95.0, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(480, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1481, 'manish.banerjee2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(481, 1481, '25CSE0001', 'CSE-01', 'Manish Banerjee', 'manish.banerjee2025@college.local', '+91 92501 00001', '2007-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(481, 6.85, 78.5, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(481, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1482, 'yamini.sen2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(482, 1482, '25CSE0002', 'CSE-02', 'Yamini Sen', 'yamini.sen2025@college.local', '+91 92501 00002', '2007-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(482, 7.2, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(482, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1483, 'aarav.dutta2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(483, 1483, '25CSE0003', 'CSE-03', 'Aarav Dutta', 'aarav.dutta2025@college.local', '+91 92501 00003', '2007-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(483, 7.55, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(483, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1484, 'riya.mitra2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(484, 1484, '25CSE0004', 'CSE-04', 'Riya Mitra', 'riya.mitra2025@college.local', '+91 92501 00004', '2007-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(484, 7.9, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(484, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1485, 'shaurya.reddy2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(485, 1485, '25CSE0005', 'CSE-05', 'Shaurya Reddy', 'shaurya.reddy2025@college.local', '+91 92501 00005', '2007-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(485, 8.25, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(485, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1486, 'neha.nair2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(486, 1486, '25CSE0006', 'CSE-06', 'Neha Nair', 'neha.nair2025@college.local', '+91 92501 00006', '2007-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(486, 8.6, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(486, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1487, 'kian.singh2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(487, 1487, '25CSE0007', 'CSE-07', 'Kian Singh', 'kian.singh2025@college.local', '+91 92501 00007', '2007-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(487, 8.95, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(487, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1488, 'aadhya.mishra2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(488, 1488, '25CSE0008', 'CSE-08', 'Aadhya Mishra', 'aadhya.mishra2025@college.local', '+91 92501 00008', '2007-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(488, 9.3, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(488, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1489, 'manish.mukherjee2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(489, 1489, '25ECE0001', 'ECE-01', 'Manish Mukherjee', 'manish.mukherjee2025@college.local', '+91 92502 00001', '2007-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(489, 6.85, 78.5, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(489, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1490, 'yamini.ghosh2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(490, 1490, '25ECE0002', 'ECE-02', 'Yamini Ghosh', 'yamini.ghosh2025@college.local', '+91 92502 00002', '2007-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(490, 7.2, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(490, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1491, 'aarav.chakraborty2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(491, 1491, '25ECE0003', 'ECE-03', 'Aarav Chakraborty', 'aarav.chakraborty2025@college.local', '+91 92502 00003', '2007-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(491, 7.55, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(491, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1492, 'riya.verma2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(492, 1492, '25ECE0004', 'ECE-04', 'Riya Verma', 'riya.verma2025@college.local', '+91 92502 00004', '2007-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(492, 7.9, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(492, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1493, 'shaurya.rao2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(493, 1493, '25ECE0005', 'ECE-05', 'Shaurya Rao', 'shaurya.rao2025@college.local', '+91 92502 00005', '2007-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(493, 8.25, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(493, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1494, 'neha.gupta2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(494, 1494, '25ECE0006', 'ECE-06', 'Neha Gupta', 'neha.gupta2025@college.local', '+91 92502 00006', '2007-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(494, 8.6, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(494, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1495, 'kian.chowdhury2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(495, 1495, '25ECE0007', 'ECE-07', 'Kian Chowdhury', 'kian.chowdhury2025@college.local', '+91 92502 00007', '2007-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(495, 8.95, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(495, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1496, 'aadhya.kulkarni2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(496, 1496, '25ECE0008', 'ECE-08', 'Aadhya Kulkarni', 'aadhya.kulkarni2025@college.local', '+91 92502 00008', '2007-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(496, 9.3, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(496, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1497, 'manish.bose2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(497, 1497, '25EEE0001', 'EEE-01', 'Manish Bose', 'manish.bose2025@college.local', '+91 92503 00001', '2007-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(497, 6.85, 78.5, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(497, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1498, 'yamini.roy2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(498, 1498, '25EEE0002', 'EEE-02', 'Yamini Roy', 'yamini.roy2025@college.local', '+91 92503 00002', '2007-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(498, 7.2, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(498, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1499, 'aarav.sharma2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(499, 1499, '25EEE0003', 'EEE-03', 'Aarav Sharma', 'aarav.sharma2025@college.local', '+91 92503 00003', '2007-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(499, 7.55, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(499, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1500, 'riya.patel2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(500, 1500, '25EEE0004', 'EEE-04', 'Riya Patel', 'riya.patel2025@college.local', '+91 92503 00004', '2007-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(500, 7.9, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(500, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1501, 'shaurya.iyer2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(501, 1501, '25EEE0005', 'EEE-05', 'Shaurya Iyer', 'shaurya.iyer2025@college.local', '+91 92503 00005', '2007-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(501, 8.25, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(501, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1502, 'neha.kumar2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(502, 1502, '25EEE0006', 'EEE-06', 'Neha Kumar', 'neha.kumar2025@college.local', '+91 92503 00006', '2007-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(502, 8.6, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(502, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1503, 'kian.joshi2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(503, 1503, '25EEE0007', 'EEE-07', 'Kian Joshi', 'kian.joshi2025@college.local', '+91 92503 00007', '2007-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(503, 8.95, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(503, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1504, 'aadhya.bhat2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(504, 1504, '25EEE0008', 'EEE-08', 'Aadhya Bhat', 'aadhya.bhat2025@college.local', '+91 92503 00008', '2007-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(504, 9.3, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(504, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1505, 'manish.dutta2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(505, 1505, '25MECH0001', 'MECH-01', 'Manish Dutta', 'manish.dutta2025@college.local', '+91 92504 00001', '2007-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(505, 6.85, 78.5, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(505, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1506, 'yamini.mitra2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(506, 1506, '25MECH0002', 'MECH-02', 'Yamini Mitra', 'yamini.mitra2025@college.local', '+91 92504 00002', '2007-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(506, 7.2, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(506, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1507, 'aarav.reddy2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(507, 1507, '25MECH0003', 'MECH-03', 'Aarav Reddy', 'aarav.reddy2025@college.local', '+91 92504 00003', '2007-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(507, 7.55, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(507, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1508, 'riya.nair2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(508, 1508, '25MECH0004', 'MECH-04', 'Riya Nair', 'riya.nair2025@college.local', '+91 92504 00004', '2007-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(508, 7.9, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(508, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1509, 'shaurya.singh2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(509, 1509, '25MECH0005', 'MECH-05', 'Shaurya Singh', 'shaurya.singh2025@college.local', '+91 92504 00005', '2007-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(509, 8.25, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(509, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1510, 'neha.mishra2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(510, 1510, '25MECH0006', 'MECH-06', 'Neha Mishra', 'neha.mishra2025@college.local', '+91 92504 00006', '2007-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(510, 8.6, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(510, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1511, 'kian.deshmukh2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(511, 1511, '25MECH0007', 'MECH-07', 'Kian Deshmukh', 'kian.deshmukh2025@college.local', '+91 92504 00007', '2007-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(511, 8.95, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(511, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1512, 'aadhya.pillai2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(512, 1512, '25MECH0008', 'MECH-08', 'Aadhya Pillai', 'aadhya.pillai2025@college.local', '+91 92504 00008', '2007-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(512, 9.3, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(512, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1513, 'manish.chakraborty2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(513, 1513, '25CIVIL0001', 'CIVIL-01', 'Manish Chakraborty', 'manish.chakraborty2025@college.local', '+91 92505 00001', '2007-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(513, 6.85, 78.5, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(513, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1514, 'yamini.verma2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(514, 1514, '25CIVIL0002', 'CIVIL-02', 'Yamini Verma', 'yamini.verma2025@college.local', '+91 92505 00002', '2007-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(514, 7.2, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(514, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1515, 'aarav.rao2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(515, 1515, '25CIVIL0003', 'CIVIL-03', 'Aarav Rao', 'aarav.rao2025@college.local', '+91 92505 00003', '2007-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(515, 7.55, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(515, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1516, 'riya.gupta2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(516, 1516, '25CIVIL0004', 'CIVIL-04', 'Riya Gupta', 'riya.gupta2025@college.local', '+91 92505 00004', '2007-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(516, 7.9, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(516, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1517, 'shaurya.chowdhury2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(517, 1517, '25CIVIL0005', 'CIVIL-05', 'Shaurya Chowdhury', 'shaurya.chowdhury2025@college.local', '+91 92505 00005', '2007-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(517, 8.25, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(517, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1518, 'neha.kulkarni2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(518, 1518, '25CIVIL0006', 'CIVIL-06', 'Neha Kulkarni', 'neha.kulkarni2025@college.local', '+91 92505 00006', '2007-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(518, 8.6, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(518, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1519, 'kian.hegde2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(519, 1519, '25CIVIL0007', 'CIVIL-07', 'Kian Hegde', 'kian.hegde2025@college.local', '+91 92505 00007', '2007-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(519, 8.95, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(519, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1520, 'aadhya.das2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(520, 1520, '25CIVIL0008', 'CIVIL-08', 'Aadhya Das', 'aadhya.das2025@college.local', '+91 92505 00008', '2007-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(520, 9.3, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(520, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1521, 'manish.sharma2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(521, 1521, '25IT0001', 'IT-01', 'Manish Sharma', 'manish.sharma2025@college.local', '+91 92506 00001', '2007-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(521, 6.85, 78.5, 1);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(521, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1522, 'yamini.patel2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(522, 1522, '25IT0002', 'IT-02', 'Yamini Patel', 'yamini.patel2025@college.local', '+91 92506 00002', '2007-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(522, 7.2, 81.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(522, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1523, 'aarav.iyer2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(523, 1523, '25IT0003', 'IT-03', 'Aarav Iyer', 'aarav.iyer2025@college.local', '+91 92506 00003', '2007-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(523, 7.55, 83.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(523, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1524, 'riya.kumar2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(524, 1524, '25IT0004', 'IT-04', 'Riya Kumar', 'riya.kumar2025@college.local', '+91 92506 00004', '2007-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(524, 7.9, 86.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(524, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1525, 'shaurya.joshi2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(525, 1525, '25IT0005', 'IT-05', 'Shaurya Joshi', 'shaurya.joshi2025@college.local', '+91 92506 00005', '2007-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(525, 8.25, 88.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(525, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1526, 'neha.bhat2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(526, 1526, '25IT0006', 'IT-06', 'Neha Bhat', 'neha.bhat2025@college.local', '+91 92506 00006', '2007-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(526, 8.6, 91.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(526, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1527, 'kian.menon2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(527, 1527, '25IT0007', 'IT-07', 'Kian Menon', 'kian.menon2025@college.local', '+91 92506 00007', '2007-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(527, 8.95, 93.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(527, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1528, 'aadhya.chatterjee2025@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(528, 1528, '25IT0008', 'IT-08', 'Aadhya Chatterjee', 'aadhya.chatterjee2025@college.local', '+91 92506 00008', '2007-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2025, 2029, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(528, 9.3, 96.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(528, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1529, 'gautam.chatterjee2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(529, 1529, '26CSE0001', 'CSE-01', 'Gautam Chatterjee', 'gautam.chatterjee2026@college.local', '+91 92601 00001', '2008-02-04', 'MALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(529, 7.05, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(529, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1530, 'aanya.bose2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(530, 1530, '26CSE0002', 'CSE-02', 'Aanya Bose', 'aanya.bose2026@college.local', '+91 92601 00002', '2008-03-07', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(530, 7.4, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(530, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1531, 'vivaan.roy2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(531, 1531, '26CSE0003', 'CSE-03', 'Vivaan Roy', 'vivaan.roy2026@college.local', '+91 92601 00003', '2008-04-10', 'MALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(531, 7.75, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(531, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1532, 'kiara.sharma2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(532, 1532, '26CSE0004', 'CSE-04', 'Kiara Sharma', 'kiara.sharma2026@college.local', '+91 92601 00004', '2008-05-13', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(532, 8.1, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(532, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1533, 'atharv.patel2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(533, 1533, '26CSE0005', 'CSE-05', 'Atharv Patel', 'atharv.patel2026@college.local', '+91 92601 00005', '2008-06-16', 'MALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(533, 8.45, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(533, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1534, 'shreya.iyer2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(534, 1534, '26CSE0006', 'CSE-06', 'Shreya Iyer', 'shreya.iyer2026@college.local', '+91 92601 00006', '2008-07-19', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(534, 8.8, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(534, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1535, 'rudra.kumar2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(535, 1535, '26CSE0007', 'CSE-07', 'Rudra Kumar', 'rudra.kumar2026@college.local', '+91 92601 00007', '2008-08-22', 'MALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(535, 9.15, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(535, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1536, 'saanvi.joshi2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(536, 1536, '26CSE0008', 'CSE-08', 'Saanvi Joshi', 'saanvi.joshi2026@college.local', '+91 92601 00008', '2008-09-25', 'FEMALE', 'Hyderabad, Telangana', 1, 1, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(536, 9.5, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(536, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1537, 'gautam.sen2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(537, 1537, '26ECE0001', 'ECE-01', 'Gautam Sen', 'gautam.sen2026@college.local', '+91 92602 00001', '2008-02-04', 'MALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(537, 7.05, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(537, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1538, 'aanya.dutta2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(538, 1538, '26ECE0002', 'ECE-02', 'Aanya Dutta', 'aanya.dutta2026@college.local', '+91 92602 00002', '2008-03-07', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(538, 7.4, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(538, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1539, 'vivaan.mitra2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(539, 1539, '26ECE0003', 'ECE-03', 'Vivaan Mitra', 'vivaan.mitra2026@college.local', '+91 92602 00003', '2008-04-10', 'MALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(539, 7.75, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(539, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1540, 'kiara.reddy2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(540, 1540, '26ECE0004', 'ECE-04', 'Kiara Reddy', 'kiara.reddy2026@college.local', '+91 92602 00004', '2008-05-13', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(540, 8.1, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(540, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1541, 'atharv.nair2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(541, 1541, '26ECE0005', 'ECE-05', 'Atharv Nair', 'atharv.nair2026@college.local', '+91 92602 00005', '2008-06-16', 'MALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(541, 8.45, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(541, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1542, 'shreya.singh2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(542, 1542, '26ECE0006', 'ECE-06', 'Shreya Singh', 'shreya.singh2026@college.local', '+91 92602 00006', '2008-07-19', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(542, 8.8, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(542, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1543, 'rudra.mishra2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(543, 1543, '26ECE0007', 'ECE-07', 'Rudra Mishra', 'rudra.mishra2026@college.local', '+91 92602 00007', '2008-08-22', 'MALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(543, 9.15, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(543, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1544, 'saanvi.deshmukh2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(544, 1544, '26ECE0008', 'ECE-08', 'Saanvi Deshmukh', 'saanvi.deshmukh2026@college.local', '+91 92602 00008', '2008-09-25', 'FEMALE', 'Hyderabad, Telangana', 2, 2, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(544, 9.5, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(544, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1545, 'gautam.ghosh2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(545, 1545, '26EEE0001', 'EEE-01', 'Gautam Ghosh', 'gautam.ghosh2026@college.local', '+91 92603 00001', '2008-02-04', 'MALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(545, 7.05, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(545, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1546, 'aanya.chakraborty2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(546, 1546, '26EEE0002', 'EEE-02', 'Aanya Chakraborty', 'aanya.chakraborty2026@college.local', '+91 92603 00002', '2008-03-07', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(546, 7.4, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(546, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1547, 'vivaan.verma2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(547, 1547, '26EEE0003', 'EEE-03', 'Vivaan Verma', 'vivaan.verma2026@college.local', '+91 92603 00003', '2008-04-10', 'MALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(547, 7.75, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(547, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1548, 'kiara.rao2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(548, 1548, '26EEE0004', 'EEE-04', 'Kiara Rao', 'kiara.rao2026@college.local', '+91 92603 00004', '2008-05-13', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(548, 8.1, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(548, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1549, 'atharv.gupta2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(549, 1549, '26EEE0005', 'EEE-05', 'Atharv Gupta', 'atharv.gupta2026@college.local', '+91 92603 00005', '2008-06-16', 'MALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(549, 8.45, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(549, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1550, 'shreya.chowdhury2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(550, 1550, '26EEE0006', 'EEE-06', 'Shreya Chowdhury', 'shreya.chowdhury2026@college.local', '+91 92603 00006', '2008-07-19', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(550, 8.8, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(550, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1551, 'rudra.kulkarni2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(551, 1551, '26EEE0007', 'EEE-07', 'Rudra Kulkarni', 'rudra.kulkarni2026@college.local', '+91 92603 00007', '2008-08-22', 'MALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(551, 9.15, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(551, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1552, 'saanvi.hegde2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(552, 1552, '26EEE0008', 'EEE-08', 'Saanvi Hegde', 'saanvi.hegde2026@college.local', '+91 92603 00008', '2008-09-25', 'FEMALE', 'Hyderabad, Telangana', 3, 3, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(552, 9.5, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(552, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1553, 'gautam.roy2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(553, 1553, '26MECH0001', 'MECH-01', 'Gautam Roy', 'gautam.roy2026@college.local', '+91 92604 00001', '2008-02-04', 'MALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(553, 7.05, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(553, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1554, 'aanya.sharma2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(554, 1554, '26MECH0002', 'MECH-02', 'Aanya Sharma', 'aanya.sharma2026@college.local', '+91 92604 00002', '2008-03-07', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(554, 7.4, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(554, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1555, 'vivaan.patel2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(555, 1555, '26MECH0003', 'MECH-03', 'Vivaan Patel', 'vivaan.patel2026@college.local', '+91 92604 00003', '2008-04-10', 'MALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(555, 7.75, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(555, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1556, 'kiara.iyer2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(556, 1556, '26MECH0004', 'MECH-04', 'Kiara Iyer', 'kiara.iyer2026@college.local', '+91 92604 00004', '2008-05-13', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(556, 8.1, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(556, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1557, 'atharv.kumar2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(557, 1557, '26MECH0005', 'MECH-05', 'Atharv Kumar', 'atharv.kumar2026@college.local', '+91 92604 00005', '2008-06-16', 'MALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(557, 8.45, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(557, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1558, 'shreya.joshi2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(558, 1558, '26MECH0006', 'MECH-06', 'Shreya Joshi', 'shreya.joshi2026@college.local', '+91 92604 00006', '2008-07-19', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(558, 8.8, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(558, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1559, 'rudra.bhat2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(559, 1559, '26MECH0007', 'MECH-07', 'Rudra Bhat', 'rudra.bhat2026@college.local', '+91 92604 00007', '2008-08-22', 'MALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(559, 9.15, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(559, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1560, 'saanvi.menon2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(560, 1560, '26MECH0008', 'MECH-08', 'Saanvi Menon', 'saanvi.menon2026@college.local', '+91 92604 00008', '2008-09-25', 'FEMALE', 'Hyderabad, Telangana', 4, 4, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(560, 9.5, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(560, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1561, 'gautam.mitra2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(561, 1561, '26CIVIL0001', 'CIVIL-01', 'Gautam Mitra', 'gautam.mitra2026@college.local', '+91 92605 00001', '2008-02-04', 'MALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(561, 7.05, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(561, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1562, 'aanya.reddy2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(562, 1562, '26CIVIL0002', 'CIVIL-02', 'Aanya Reddy', 'aanya.reddy2026@college.local', '+91 92605 00002', '2008-03-07', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(562, 7.4, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(562, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1563, 'vivaan.nair2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(563, 1563, '26CIVIL0003', 'CIVIL-03', 'Vivaan Nair', 'vivaan.nair2026@college.local', '+91 92605 00003', '2008-04-10', 'MALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(563, 7.75, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(563, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1564, 'kiara.singh2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(564, 1564, '26CIVIL0004', 'CIVIL-04', 'Kiara Singh', 'kiara.singh2026@college.local', '+91 92605 00004', '2008-05-13', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(564, 8.1, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(564, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1565, 'atharv.mishra2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(565, 1565, '26CIVIL0005', 'CIVIL-05', 'Atharv Mishra', 'atharv.mishra2026@college.local', '+91 92605 00005', '2008-06-16', 'MALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(565, 8.45, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(565, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1566, 'shreya.deshmukh2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(566, 1566, '26CIVIL0006', 'CIVIL-06', 'Shreya Deshmukh', 'shreya.deshmukh2026@college.local', '+91 92605 00006', '2008-07-19', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(566, 8.8, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(566, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1567, 'rudra.pillai2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(567, 1567, '26CIVIL0007', 'CIVIL-07', 'Rudra Pillai', 'rudra.pillai2026@college.local', '+91 92605 00007', '2008-08-22', 'MALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(567, 9.15, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(567, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1568, 'saanvi.banerjee2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(568, 1568, '26CIVIL0008', 'CIVIL-08', 'Saanvi Banerjee', 'saanvi.banerjee2026@college.local', '+91 92605 00008', '2008-09-25', 'FEMALE', 'Hyderabad, Telangana', 5, 5, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(568, 9.5, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(568, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1569, 'gautam.verma2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(569, 1569, '26IT0001', 'IT-01', 'Gautam Verma', 'gautam.verma2026@college.local', '+91 92606 00001', '2008-02-04', 'MALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(569, 7.05, 79.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(569, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1570, 'aanya.rao2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(570, 1570, '26IT0002', 'IT-02', 'Aanya Rao', 'aanya.rao2026@college.local', '+91 92606 00002', '2008-03-07', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(570, 7.4, 82.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(570, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1571, 'vivaan.gupta2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(571, 1571, '26IT0003', 'IT-03', 'Vivaan Gupta', 'vivaan.gupta2026@college.local', '+91 92606 00003', '2008-04-10', 'MALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(571, 7.75, 84.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(571, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1572, 'kiara.chowdhury2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(572, 1572, '26IT0004', 'IT-04', 'Kiara Chowdhury', 'kiara.chowdhury2026@college.local', '+91 92606 00004', '2008-05-13', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(572, 8.1, 87.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(572, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1573, 'atharv.kulkarni2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(573, 1573, '26IT0005', 'IT-05', 'Atharv Kulkarni', 'atharv.kulkarni2026@college.local', '+91 92606 00005', '2008-06-16', 'MALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(573, 8.45, 89.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(573, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1574, 'shreya.hegde2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(574, 1574, '26IT0006', 'IT-06', 'Shreya Hegde', 'shreya.hegde2026@college.local', '+91 92606 00006', '2008-07-19', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(574, 8.8, 92.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(574, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1575, 'rudra.das2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(575, 1575, '26IT0007', 'IT-07', 'Rudra Das', 'rudra.das2026@college.local', '+91 92606 00007', '2008-08-22', 'MALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(575, 9.15, 94.5, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(575, 1, 69000.00, 69000.0, 0.0, 'PAID', '2025-09-30');
INSERT INTO users (id, email, password_hash, role, must_change_password) VALUES
(1576, 'saanvi.mukherjee2026@college.local', '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
INSERT INTO students (id, user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status) VALUES
(576, 1576, '26IT0008', 'IT-08', 'Saanvi Mukherjee', 'saanvi.mukherjee2026@college.local', '+91 92606 00008', '2008-09-25', 'FEMALE', 'Hyderabad, Telangana', 6, 6, 2026, 2030, 1, 1, 'ACTIVE');
INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count) VALUES
(576, 9.5, 97.0, 0);
INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date) VALUES
(576, 1, 69000.00, 35000.0, 34000.0, 'PARTIAL', '2025-09-30');

-- ------------------------------------------------------------------------------
-- 14. STORED PROCEDURE: MASS ANNUAL COHORT GENERATOR (1000+ Students per Year)
-- Call anytime in MySQL Workbench: CALL sp_generate_annual_cohort(2025, 200);
-- ------------------------------------------------------------------------------
DELIMITER //

DROP PROCEDURE IF EXISTS sp_generate_annual_cohort //
CREATE PROCEDURE sp_generate_annual_cohort(IN in_year INT, IN in_count_per_dept INT)
BEGIN
    DECLARE d_id INT DEFAULT 1;
    DECLARE s_idx INT;
    DECLARE v_uid BIGINT;
    DECLARE v_sid BIGINT;
    DECLARE v_dept_code VARCHAR(32);
    DECLARE v_gender VARCHAR(16);
    DECLARE v_name VARCHAR(128);
    DECLARE v_reg VARCHAR(32);
    DECLARE v_email VARCHAR(191);
    DECLARE v_status VARCHAR(32);
    DECLARE v_year_study INT;
    DECLARE v_sem INT;

    -- Determine study year & status
    IF in_year <= 2021 THEN
        SET v_status = 'GRADUATED';
        SET v_year_study = 4;
        SET v_sem = 8;
    ELSEIF in_year = 2022 THEN
        SET v_status = 'ACTIVE';
        SET v_year_study = 4;
        SET v_sem = 7;
    ELSEIF in_year = 2023 THEN
        SET v_status = 'ACTIVE';
        SET v_year_study = 3;
        SET v_sem = 5;
    ELSEIF in_year = 2024 THEN
        SET v_status = 'ACTIVE';
        SET v_year_study = 2;
        SET v_sem = 3;
    ELSE
        SET v_status = 'ACTIVE';
        SET v_year_study = 1;
        SET v_sem = 1;
    END IF;

    -- Iterate through 6 departments
    WHILE d_id <= 6 DO
        SELECT code INTO v_dept_code FROM departments WHERE id = d_id;
        SET s_idx = 1;

        WHILE s_idx <= in_count_per_dept DO
            -- Gender alternate
            IF s_idx % 2 = 0 THEN
                SET v_gender = 'FEMALE';
                SET v_name = CONCAT('Student Girl ', s_idx, ' ', v_dept_code);
            ELSE
                SET v_gender = 'MALE';
                SET v_name = CONCAT('Student Boy ', s_idx, ' ', v_dept_code);
            END IF;

            SET v_reg = CONCAT(RIGHT(in_year, 2), v_dept_code, LPAD(s_idx + 100, 4, '0'));
            SET v_email = CONCAT(LOWER(v_dept_code), '.', in_year, '.', s_idx, '@college.local');

            -- Insert user
            INSERT INTO users (email, password_hash, role, must_change_password)
            VALUES (v_email, '$2a$12$pGkKkX7pD4gO6hM0.O5eC.eF1iG3qB7bF7A5sN3yT1mI8uR5xW9ea', 'STUDENT', FALSE);
            SET v_uid = LAST_INSERT_ID();

            -- Insert student
            INSERT INTO students (user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, status)
            VALUES (v_uid, v_reg, CONCAT(v_dept_code, '-', s_idx), v_name, v_email, '+91 99000 00000', '2004-01-15', v_gender, 'Hyderabad', d_id, d_id, in_year, in_year + 4, v_sem, v_year_study, v_status);
            SET v_sid = LAST_INSERT_ID();

            -- Status & Fee
            INSERT INTO student_academic_status (student_id, current_cgpa, attendance_percentage, active_arrears_count)
            VALUES (v_sid, 7.50, 84.50, 0);

            INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status, due_date)
            VALUES (v_sid, 1, 69000.00, 69000.00, 0.00, 'PAID', '2025-09-30');

            SET s_idx = s_idx + 1;
        END WHILE;

        SET d_id = d_id + 1;
    END WHILE;
END //

DELIMITER ;

-- ------------------------------------------------------------------------------
-- 15. VERIFICATION QUERIES (RUN IN MYSQL WORKBENCH TO VERIFY)
-- ------------------------------------------------------------------------------
-- 1. Historical Summary from 2015 to 2026:
SELECT admission_year, status, current_year_of_study, gender, COUNT(*) AS total
FROM students
GROUP BY admission_year, status, current_year_of_study, gender
ORDER BY admission_year DESC, gender;

-- 2. Department-wise Gender Distribution:
SELECT * FROM v_gender_distribution ORDER BY admission_year DESC;

-- 3. Faculty-to-Student Ratios:
SELECT * FROM v_department_faculty_ratios;
