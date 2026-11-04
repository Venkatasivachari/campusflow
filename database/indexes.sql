-- ==============================================================================
-- IMPERIAL INSTITUTE - ENTERPRISE COLLEGE MANAGEMENT SYSTEM
-- Part 4: Performance Indexes for High-Throughput & Analytical Queries
-- ==============================================================================

USE college_management_system;

-- Foreign key indexes & search lookup optimizations
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_students_reg ON students(registration_number);
CREATE INDEX idx_students_year_dept ON students(admission_year, department_id);
CREATE INDEX idx_students_status ON students(status, current_year_of_study);
CREATE INDEX idx_faculty_code ON faculty(employee_code);
CREATE INDEX idx_faculty_dept ON faculty(department_id);
CREATE INDEX idx_attendance_session ON attendance_records(session_id, student_id);
CREATE INDEX idx_marks_assessment ON student_marks(assessment_id, student_id);
CREATE INDEX idx_fees_student ON student_fees(student_id, status);
CREATE INDEX idx_audit_timestamp ON audit_logs(timestamp);
