-- ==============================================================================
-- IMPERIAL INSTITUTE - ENTERPRISE COLLEGE MANAGEMENT SYSTEM
-- Part 3: Permissions Matrix & Role-Permission Mappings
-- ==============================================================================

USE college_management_system;

INSERT INTO permissions (id, code, description) VALUES
(1, 'ROOT_OWNER_GOVERNANCE', 'Full institutional control, ownership transfer authorization'),
(2, 'ADMIN_MANAGEMENT', 'Create, update and deactivate administrative accounts'),
(3, 'DEPARTMENT_MANAGEMENT', 'Manage institutional departments, programmes and seats'),
(4, 'FACULTY_MANAGEMENT', 'Hire, assign, evaluate and manage faculty records'),
(5, 'STUDENT_MANAGEMENT', 'Admissions, status updates, promotions and student records'),
(6, 'ACADEMIC_GOVERNANCE', 'Course curriculums, timetable approvals, semester calibrations'),
(7, 'ATTENDANCE_TAKE', 'Record daily lecture and lab attendance'),
(8, 'MARKS_ENTRY', 'Submit internal assessments, semester exams and grading'),
(9, 'FINANCIAL_OVERSIGHT', 'Fee structures, billing, payment verification and payroll'),
(10, 'AUDIT_LOG_VIEW', 'Access immutable system security and activity audit trails')
ON DUPLICATE KEY UPDATE description = VALUES(description);

-- Map Root Owner (Role 1) to ALL Permissions
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions;

-- Map Super Admin (Role 2)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 2, id FROM permissions WHERE id IN (2, 3, 4, 5, 6, 7, 8, 9, 10);

-- Map Admin (Role 5)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 5, id FROM permissions WHERE id IN (3, 4, 5, 6, 9, 10);

-- Map Faculty (Role 7)
INSERT IGNORE INTO role_permissions (role_id, permission_id)
SELECT 7, id FROM permissions WHERE id IN (7, 8);
