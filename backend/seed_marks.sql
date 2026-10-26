USE college_portal;

-- 1. Insert Semester 1 End-Sem Exam
INSERT INTO exams (id, semester_id, exam_type, title, start_date, end_date, is_published)
VALUES (1, 1, 'END_SEM', 'Autumn 2026 End-Semester Examinations', '2026-11-15', '2026-11-30', 1)
ON DUPLICATE KEY UPDATE title=VALUES(title);

-- 2. Insert Marks for Students
-- CS101: Programming Fundamentals (Offering 1)
-- CS102: Data Structures and Algorithms (Offering 2)
-- CS103: Database Management Systems (Offering 3)
-- CS104: Programming Lab (Offering 4)

INSERT INTO marks (exam_id, offering_id, student_id, internal_marks, external_marks, total_marks, grade, grade_point, is_pass, submitted_for_review)
VALUES
-- Student 1: Aarav Sharma (25CSE0001)
(1, 1, 1, 34.0, 52.0, 86.0, 'A+', 9, 1, 1),
(1, 2, 1, 30.0, 48.0, 78.0, 'A', 8, 1, 1),
(1, 3, 1, 32.0, 45.0, 77.0, 'A', 8, 1, 1),
(1, 4, 1, 38.0, 54.0, 92.0, 'O', 10, 1, 1),

-- Student 2: Ananya Verma (25CSE0002)
(1, 1, 2, 36.0, 55.0, 91.0, 'O', 10, 1, 1),
(1, 2, 2, 35.0, 53.0, 88.0, 'A+', 9, 1, 1),
(1, 3, 2, 33.0, 50.0, 83.0, 'A+', 9, 1, 1),
(1, 4, 2, 39.0, 57.0, 96.0, 'O', 10, 1, 1),

-- Student 3: Rohan Patel (25CSE0003 - Arrear in CS102)
(1, 1, 3, 28.0, 42.0, 70.0, 'B+', 7, 1, 1),
(1, 2, 3, 18.0, 20.0, 38.0, 'F', 0, 0, 1),
(1, 3, 3, 25.0, 40.0, 65.0, 'B+', 7, 1, 1),
(1, 4, 3, 32.0, 44.0, 76.0, 'A', 8, 1, 1),

-- Student 4: Diya Reddy (25CSE0004)
(1, 1, 4, 31.0, 49.0, 80.0, 'A+', 9, 1, 1),
(1, 2, 4, 29.0, 45.0, 74.0, 'A', 8, 1, 1),
(1, 3, 4, 30.0, 46.0, 76.0, 'A', 8, 1, 1),
(1, 4, 4, 36.0, 50.0, 86.0, 'A+', 9, 1, 1),

-- Student 5: Kabir Iyer (25CSE0005)
(1, 1, 5, 33.0, 51.0, 84.0, 'A+', 9, 1, 1),
(1, 2, 5, 31.0, 47.0, 78.0, 'A', 8, 1, 1),
(1, 3, 5, 29.0, 43.0, 72.0, 'A', 8, 1, 1),
(1, 4, 5, 35.0, 52.0, 87.0, 'A+', 9, 1, 1);

-- 3. Update Results and Academic Status
INSERT INTO results (student_id, semester_id, sgpa, cgpa, result_status)
VALUES
(1, 1, 8.62, 8.62, 'PASS'),
(2, 1, 9.46, 9.46, 'PASS'),
(3, 1, 5.38, 5.38, 'ARREAR'),
(4, 1, 8.46, 8.46, 'PASS'),
(5, 1, 8.38, 8.38, 'PASS')
ON DUPLICATE KEY UPDATE sgpa=VALUES(sgpa), cgpa=VALUES(cgpa);

UPDATE student_academic_status SET current_sgpa=8.62, current_cgpa=8.62 WHERE student_id=1;
UPDATE student_academic_status SET current_sgpa=9.46, current_cgpa=9.46 WHERE student_id=2;
UPDATE student_academic_status SET current_sgpa=5.38, current_cgpa=5.38 WHERE student_id=3;
UPDATE student_academic_status SET current_sgpa=8.46, current_cgpa=8.46 WHERE student_id=4;
UPDATE student_academic_status SET current_sgpa=8.38, current_cgpa=8.38 WHERE student_id=5;
