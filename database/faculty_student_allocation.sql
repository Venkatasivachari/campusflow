-- ==============================================================================
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
