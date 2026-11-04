-- ==============================================================================
-- IMPERIAL INSTITUTE - ENTERPRISE COLLEGE MANAGEMENT SYSTEM
-- Part 2: System Roles Definition
-- ==============================================================================

USE college_management_system;

INSERT INTO roles (id, name, description) VALUES
(1, 'ROLE_OWNER', 'Root Institutional Owner / Executive Chairman (Supreme Authority)'),
(2, 'ROLE_SUPER_ADMIN', 'Platform Technical Administrator with Full Operational Rights'),
(3, 'ROLE_PRINCIPAL', 'Head of Institution, Academic & Governance Leader'),
(4, 'ROLE_DEAN', 'Dean of Academics, Curricular Approvals & Student Welfare'),
(5, 'ROLE_ADMIN', 'College Administrative Officer, Admissions, Infrastructure & Fee Control'),
(6, 'ROLE_HOD', 'Head of Academic Department, Faculty Mentorship & Subject Allocation'),
(7, 'ROLE_FACULTY', 'Teaching Faculty / Professor, Attendance, Marks & Student Mentoring'),
(8, 'ROLE_STUDENT', 'Enrolled Student, Academic Tracking, Course Registrations & Fee Dues')
ON DUPLICATE KEY UPDATE description = VALUES(description);
