-- ==============================================================================
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
