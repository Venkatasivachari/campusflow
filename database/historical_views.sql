-- ==============================================================================
-- IMPERIAL INSTITUTE - ENTERPRISE COLLEGE MANAGEMENT SYSTEM
-- Part 5: Historical Analytics & Executive Reporting Views (2015-2026)
-- ==============================================================================

USE college_management_system;

-- 1. Historical Enrollment & Academic Progression Summary (2015-2026)
CREATE OR REPLACE VIEW v_historical_enrollment_summary AS
SELECT 
    s.admission_year,
    d.code AS department_code,
    d.name AS department_name,
    COUNT(s.id) AS total_enrolled,
    SUM(CASE WHEN s.gender = 'MALE' THEN 1 ELSE 0 END) AS male_count,
    SUM(CASE WHEN s.gender = 'FEMALE' THEN 1 ELSE 0 END) AS female_count,
    SUM(CASE WHEN s.status = 'GRADUATED' THEN 1 ELSE 0 END) AS graduated_count,
    SUM(CASE WHEN s.status = 'ACTIVE' THEN 1 ELSE 0 END) AS currently_active_count,
    SUM(CASE WHEN s.status = 'DISCONTINUED' THEN 1 ELSE 0 END) AS discontinued_count,
    ROUND(AVG(COALESCE(stat.current_cgpa, 0)), 2) AS average_cgpa,
    ROUND(AVG(COALESCE(stat.attendance_percentage, 0)), 1) AS average_attendance
FROM students s
JOIN departments d ON s.department_id = d.id
LEFT JOIN student_academic_status stat ON stat.student_id = s.id
GROUP BY s.admission_year, d.code, d.name;

-- 2. Department-Wise Faculty-to-Student Ratio & Staffing View
CREATE OR REPLACE VIEW v_department_faculty_ratios AS
SELECT 
    d.id AS department_id,
    d.code AS department_code,
    d.name AS department_name,
    COUNT(DISTINCT f.id) AS total_faculty,
    COUNT(DISTINCT CASE WHEN s.status = 'ACTIVE' THEN s.id END) AS active_students,
    CASE 
        WHEN COUNT(DISTINCT f.id) > 0 
        THEN ROUND(COUNT(DISTINCT CASE WHEN s.status = 'ACTIVE' THEN s.id END) / COUNT(DISTINCT f.id), 1)
        ELSE 0 
    END AS student_to_faculty_ratio,
    SUM(CASE WHEN f.designation LIKE '%Professor%' AND f.designation NOT LIKE '%Assistant%' THEN 1 ELSE 0 END) AS professors_count,
    SUM(CASE WHEN f.designation LIKE '%Assistant%' THEN 1 ELSE 0 END) AS assistant_professors_count
FROM departments d
LEFT JOIN faculty f ON f.department_id = d.id AND f.status = 'ACTIVE'
LEFT JOIN students s ON s.department_id = d.id
GROUP BY d.id, d.code, d.name;

-- 3. Historical Gender Distribution View (2015-2026)
CREATE OR REPLACE VIEW v_gender_distribution AS
SELECT 
    admission_year,
    COUNT(*) AS total_students,
    SUM(CASE WHEN gender = 'MALE' THEN 1 ELSE 0 END) AS male_students,
    SUM(CASE WHEN gender = 'FEMALE' THEN 1 ELSE 0 END) AS female_students,
    ROUND(SUM(CASE WHEN gender = 'FEMALE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS female_percentage,
    ROUND(SUM(CASE WHEN gender = 'MALE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS male_percentage
FROM students
GROUP BY admission_year;

-- 4. Faculty Workload & Teaching Capacity Summary
CREATE OR REPLACE VIEW v_faculty_workload_summary AS
SELECT 
    f.id AS faculty_id,
    f.employee_code,
    CONCAT(f.first_name, ' ', f.last_name) AS faculty_name,
    d.code AS department_code,
    f.designation,
    COALESCE(w.lecture_hours_per_week, 12) AS lecture_hours,
    COALESCE(w.lab_hours_per_week, 4) AS lab_hours,
    COALESCE(w.total_hours_per_week, 16) AS total_hours,
    COALESCE(w.max_capacity_hours, 20) AS max_capacity,
    ROUND(COALESCE(w.total_hours_per_week, 16) * 100.0 / COALESCE(w.max_capacity_hours, 20), 1) AS utilization_rate
FROM faculty f
JOIN departments d ON f.department_id = d.id
LEFT JOIN faculty_workloads w ON w.faculty_id = f.id;

-- 5. Financial Collection & Outstanding Dues Summary
CREATE OR REPLACE VIEW v_financial_collection_summary AS
SELECT 
    d.code AS department_code,
    s.admission_year,
    COUNT(sf.id) AS total_fee_records,
    SUM(sf.total_payable) AS gross_receivable,
    SUM(sf.total_paid) AS total_collected,
    SUM(sf.balance_due) AS total_outstanding,
    ROUND(SUM(sf.total_paid) * 100.0 / SUM(sf.total_payable), 1) AS collection_efficiency_percentage
FROM student_fees sf
JOIN students s ON sf.student_id = s.id
JOIN departments d ON s.department_id = d.id
GROUP BY d.code, s.admission_year;
