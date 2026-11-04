-- ==============================================================================
-- Flyway Migration V4: Root Owner, Executive Hierarchy & Historical Analytics
-- ==============================================================================

-- 1. Create Owners Table
CREATE TABLE IF NOT EXISTS owners (
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
    CONSTRAINT fk_owners_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- 2. Add Executive Roles to roles table
INSERT IGNORE INTO roles (name, description) VALUES
('ROLE_OWNER', 'Root Owner / Highest Institutional Authority with full system control'),
('ROLE_PRINCIPAL', 'Principal / Director with academic and institutional governance'),
('ROLE_DEAN', 'Academic Dean overseeing faculty, curriculum, and admissions'),
('ROLE_HOD', 'Head of Department overseeing department faculty and students');

-- 3. Historical Academic Years (2015-2016 through 2026-2027)
INSERT IGNORE INTO academic_years (name, start_date, end_date, is_current) VALUES
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

-- 4. Historical Batches (2015-2019 through 2026-2030)
INSERT IGNORE INTO batches (programme_id, admission_year, expected_graduation_year, is_active)
SELECT p.id, ay.start_year, ay.start_year + 4,
       CASE WHEN ay.start_year >= 2022 THEN TRUE ELSE FALSE END
FROM (
    SELECT 2015 AS start_year UNION SELECT 2016 UNION SELECT 2017 UNION SELECT 2018
    UNION SELECT 2019 UNION SELECT 2020 UNION SELECT 2021 UNION SELECT 2022
    UNION SELECT 2023 UNION SELECT 2024 UNION SELECT 2025 UNION SELECT 2026
) ay
CROSS JOIN programmes p;

-- 5. Analytics View: Historical Student Enrollment & Progression
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

-- 6. Analytics View: Department Faculty-to-Student Ratio
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

-- 7. Analytics View: Gender Ratio Analysis
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
