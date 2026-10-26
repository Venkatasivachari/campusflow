-- ==============================================================================
-- Flyway Migration V3: Seed Reference Data
-- Roles, Designations, Grade Scale, Departments, Academic Settings
-- ==============================================================================

-- Roles
INSERT INTO roles (name, description) VALUES
('ROLE_SUPER_ADMIN', 'Full unrestricted platform access'),
('ROLE_ADMIN', 'General institutional administrative access'),
('ROLE_ACADEMIC_ADMIN', 'Academic structure, courses, and timetable control'),
('ROLE_ACCOUNTS', 'Fee structure, payments, and faculty payroll access'),
('ROLE_EXAM_CELL', 'Marks publishing, grade scale, and arrear exams'),
('ROLE_FACULTY', 'Faculty member teaching portal access'),
('ROLE_STUDENT', 'Enrolled student portal access');

-- Grade Scale (Standard 10-Point UGC / AICTE Scale)
INSERT INTO grade_scale (letter_grade, min_percentage, max_percentage, grade_point, description) VALUES
('O', 90.00, 100.00, 10, 'Outstanding'),
('A+', 80.00, 89.99, 9, 'Excellent'),
('A', 70.00, 79.99, 8, 'Very Good'),
('B+', 60.00, 69.99, 7, 'Good'),
('B', 55.00, 59.99, 6, 'Above Average'),
('C', 50.00, 54.99, 5, 'Average'),
('F', 0.00, 49.99, 0, 'Fail (Arrear)');

-- Faculty Designations
INSERT INTO designations (title, min_experience_years, base_pay) VALUES
('Professor', 10, 110000.00),
('Associate Professor', 6, 85000.00),
('Assistant Professor', 2, 55000.00),
('HOD', 12, 130000.00),
('Lab Instructor', 1, 35000.00),
('Visiting Faculty', 0, 45000.00);

-- Departments
INSERT INTO departments (code, name, description) VALUES
('CSE', 'Computer Science and Engineering', 'Department of Computer Science and Engineering'),
('ECE', 'Electronics and Communication Engineering', 'Department of Electronics and Communication'),
('MECH', 'Mechanical Engineering', 'Department of Mechanical Engineering'),
('EEE', 'Electrical and Electronics Engineering', 'Department of Electrical and Electronics'),
('CIVIL', 'Civil Engineering', 'Department of Civil Engineering'),
('IT', 'Information Technology', 'Department of Information Technology');

-- Programmes
INSERT INTO programmes (code, name, department_id, duration_years, total_semesters, degree_type) VALUES
('BTECH-CSE', 'Bachelor of Technology in Computer Science', 1, 4, 8, 'B.Tech'),
('BTECH-ECE', 'Bachelor of Technology in Electronics', 2, 4, 8, 'B.Tech'),
('BTECH-ME', 'Bachelor of Technology in Mechanical Engineering', 3, 4, 8, 'B.Tech'),
('BTECH-EEE', 'Bachelor of Technology in Electrical Engineering', 4, 4, 8, 'B.Tech'),
('BTECH-CIVIL', 'Bachelor of Technology in Civil Engineering', 5, 4, 8, 'B.Tech'),
('BTECH-IT', 'Bachelor of Technology in Information Technology', 6, 4, 8, 'B.Tech');

-- Academic Year
INSERT INTO academic_years (name, start_date, end_date, is_current) VALUES
('2025-2026', '2025-08-01', '2026-05-31', TRUE),
('2024-2025', '2024-08-01', '2025-05-31', FALSE);

-- System Settings
INSERT INTO settings (setting_key, setting_value, category, description) VALUES
('INSTITUTION_NAME', 'Imperial Institute of Technology and Management', 'GENERAL', 'Official college name'),
('INSTITUTION_CODE', 'IITM-2026', 'GENERAL', 'Official accreditation code'),
('ATTENDANCE_THRESHOLD', '75', 'ACADEMIC', 'Minimum required attendance percentage'),
('STUDENT_ID_FORMAT', '{YY}{DEPT}{SEQ4}', 'FORMAT', 'Format pattern for student registration numbers'),
('FACULTY_ID_FORMAT', 'FAC{YY}{SEQ3}', 'FORMAT', 'Format pattern for faculty employee numbers'),
('ABC_ID_LABEL', 'ABC ID (Academic Bank of Credits)', 'LABEL', 'Label for Academic Bank of Credits identifier'),
('LATE_FEE_FINE_PER_DAY', '50', 'FINANCE', 'Fine amount in INR per day after due date');

-- Initialize ID Counters for current year (2025/2026)
INSERT INTO id_counters (counter_key, current_val, year_prefix) VALUES
('STUDENT_25_CSE', 0, '25'),
('STUDENT_25_ECE', 0, '25'),
('STUDENT_25_MECH', 0, '25'),
('STUDENT_25_EEE', 0, '25'),
('STUDENT_25_CIVIL', 0, '25'),
('STUDENT_25_IT', 0, '25'),
('FACULTY_25', 0, '25');
