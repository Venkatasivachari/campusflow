-- ==============================================================================
-- Flyway Migration V2: Performance & Composite Indexes
-- ==============================================================================

-- Unique constraints & indexes
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_role ON users(role);
CREATE INDEX idx_users_status ON users(is_blocked, must_change_password);

CREATE UNIQUE INDEX uq_students_reg_no ON students(registration_number);
CREATE UNIQUE INDEX uq_students_aadhaar_hash ON students(aadhaar_hash);
CREATE INDEX idx_students_abc_id ON students(abc_id);
CREATE INDEX idx_students_dept_prog ON students(department_id, programme_id);
CREATE INDEX idx_students_status ON students(status);

CREATE UNIQUE INDEX uq_faculty_emp_id ON faculty(employee_id);
CREATE UNIQUE INDEX uq_faculty_aadhaar_hash ON faculty(aadhaar_hash);
CREATE INDEX idx_faculty_dept ON faculty(department_id, designation_id);

-- Hot query composite indexes
CREATE INDEX idx_hot_student_semester ON marks(student_id, exam_id);
CREATE INDEX idx_hot_results_student_sem ON results(student_id, semester_id);
CREATE INDEX idx_hot_arrears_student ON arrears(student_id, status);
CREATE INDEX idx_hot_att_offering_date ON attendance_sessions(offering_id, session_date);
CREATE INDEX idx_hot_att_record_student ON attendance_records(student_id, status);
CREATE INDEX idx_hot_notif_recipient_read ON notifications(recipient_id, is_read, created_at);
CREATE INDEX idx_hot_course_reg_student ON course_registrations(student_id, status);
CREATE INDEX idx_hot_tt_slots_lookup ON timetable_slots(version_id, day_of_week, period_number);
CREATE INDEX idx_hot_audit_action_entity ON audit_log(entity_name, action, created_at);
CREATE INDEX idx_hot_login_log_lookup ON login_log(identifier, status, logged_at);
CREATE INDEX idx_hot_email_outbox_status ON email_outbox(status, retry_count);
CREATE INDEX idx_hot_fee_payments_ref ON fee_payments(transaction_reference, receipt_number);
