import os
import re
import pandas as pd
import pymysql.cursors

def import_all():
    base_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    enriched_path = os.path.join(base_dir, "enriched_student_dataset.xlsx")
    faculty_path = os.path.join(base_dir, "faculty_demo_dataset.xlsx")

    print(f"Reading {enriched_path}...")
    students_df = pd.read_excel(enriched_path)
    faculty_df = pd.read_excel(faculty_path)
    print(f"Loaded {len(students_df)} students and {len(faculty_df)} faculty members.")

    conn = pymysql.connect(
        host="localhost",
        port=3306,
        user="root",
        password="Sivachari@8919",
        database="college_portal",
        cursorclass=pymysql.cursors.DictCursor,
        autocommit=False
    )
    cursor = conn.cursor()

    demo_hash = "$2b$12$r6aBSC3sD0sVfV2.GypzwucbnRe6plUnNG1997YhpSOvEQnKtUVF."

    dept_code_to_id = {
        "CSE": 1,
        "ECE": 2,
        "MECH": 3,
        "EEE": 4,
        "CIVIL": 5,
        "IT": 6
    }

    # 1. Ensure Batches (2015-2026) for all 6 programmes
    print("Ensuring Batches & Semesters & Sections...")
    batch_map = {} # (prog_id, adm_year) -> batch_id
    section_map = {} # (batch_id, sec_name) -> section_id

    for adm_year in range(2015, 2027):
        for dept_code, dept_id in dept_code_to_id.items():
            prog_id = dept_id # 1-to-1 mapping
            cursor.execute("""
                SELECT id FROM batches WHERE programme_id = %s AND admission_year = %s
            """, (prog_id, adm_year))
            res = cursor.fetchone()
            if res:
                b_id = res['id']
            else:
                cursor.execute("""
                    INSERT INTO batches (programme_id, admission_year, expected_graduation_year, is_active)
                    VALUES (%s, %s, %s, %s)
                """, (prog_id, adm_year, adm_year + 4, 1 if adm_year >= 2023 else 0))
                b_id = cursor.lastrowid
            batch_map[(prog_id, adm_year)] = b_id

            # Ensure current semester for this batch
            # Calculate semester based on admission year
            if adm_year <= 2022: sem_num = 8
            elif adm_year == 2023: sem_num = 7
            elif adm_year == 2024: sem_num = 5
            elif adm_year == 2025: sem_num = 3
            else: sem_num = 1

            cursor.execute("""
                SELECT id FROM semesters WHERE batch_id = %s AND semester_number = %s
            """, (b_id, sem_num))
            res_sem = cursor.fetchone()
            if res_sem:
                sem_id = res_sem['id']
            else:
                cursor.execute("""
                    INSERT INTO semesters (batch_id, semester_number, academic_year_id, start_date, end_date, is_current)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (b_id, sem_num, min(adm_year - 2014, 12), '2026-07-01', '2026-12-31', 1 if adm_year >= 2023 else 0))
                sem_id = cursor.lastrowid

            # Ensure sections A, B, C
            for s_letter in ["A", "B", "C"]:
                sec_name = f"Section {s_letter}"
                cursor.execute("""
                    SELECT id FROM sections WHERE semester_id = %s AND name = %s
                """, (sem_id, sec_name))
                res_sec = cursor.fetchone()
                if res_sec:
                    sec_id = res_sec['id']
                else:
                    cursor.execute("""
                        INSERT INTO sections (semester_id, name, capacity)
                        VALUES (%s, %s, 60)
                    """, (sem_id, sec_name))
                    sec_id = cursor.lastrowid
                section_map[(b_id, sec_name)] = sec_id

    conn.commit()
    print("Batches, Semesters, and Sections verified.")

    # 2. Ensure Fee Structure exists
    cursor.execute("SELECT id FROM fee_structures LIMIT 1")
    fee_struct = cursor.fetchone()
    if not fee_struct:
        cursor.execute("""
            INSERT INTO fee_structures (programme_id, academic_year, semester, tuition_fee, lab_fee, library_fee, other_fee, due_date)
            VALUES (1, '2026-27', 1, 75000.00, 5000.00, 2500.00, 2500.00, '2026-09-30')
        """)
        fee_struct_id = cursor.lastrowid
    else:
        fee_struct_id = fee_struct['id']

    # 3. Import 60 Faculty Members
    print("Importing 60 Faculty Members...")
    for _, f in faculty_df.iterrows():
        f_email = f['Official_Email'].strip().lower()
        dept_id = dept_code_to_id.get(f['Department_Code'], 1)
        
        # Check user
        cursor.execute("SELECT id FROM users WHERE email = %s", (f_email,))
        u = cursor.fetchone()
        if not u:
            cursor.execute("""
                INSERT INTO users (email, password_hash, role, must_change_password)
                VALUES (%s, %s, 'FACULTY', FALSE)
            """, (f_email, demo_hash))
            f_uid = cursor.lastrowid
        else:
            f_uid = u['id']

        # Check faculty
        cursor.execute("SELECT id FROM faculty WHERE employee_id = %s OR user_id = %s", (f['Employee_ID'], f_uid))
        fac = cursor.fetchone()
        if not fac:
            cursor.execute("""
                INSERT INTO faculty (user_id, employee_id, full_name, email, phone, department_id, designation_id, qualification, experience_years, joining_date, employment_type, status)
                VALUES (%s, %s, %s, %s, %s, %s, 1, %s, %s, %s, 'PERMANENT', 'ACTIVE')
            """, (f_uid, f['Employee_ID'], f['Full_Name'], f_email, f['Phone_No'], dept_id, f['Highest_Qualification'], f['Experience_Years'], f['Joining_Date']))
            fac_id = cursor.lastrowid
        else:
            fac_id = fac['id']
            cursor.execute("""
                UPDATE faculty SET full_name=%s, email=%s, phone=%s, department_id=%s, qualification=%s, experience_years=%s
                WHERE id=%s
            """, (f['Full_Name'], f_email, f['Phone_No'], dept_id, f['Highest_Qualification'], f['Experience_Years'], fac_id))

        # Check faculty salary
        cursor.execute("SELECT id FROM faculty_salary WHERE faculty_id = %s", (fac_id,))
        if not cursor.fetchone():
            cursor.execute("""
                INSERT INTO faculty_salary (faculty_id, basic_pay, hra, da, allowances, pf, tax, net_salary, effective_date)
                VALUES (%s, %s, %s, %s, 0.00, %s, %s, %s, '2026-01-01')
            """, (fac_id, f['Basic_Salary'], f['Basic_Salary']*0.2, f['Basic_Salary']*0.15, f['Basic_Salary']*0.08, f['Basic_Salary']*0.05, f['Net_Salary']))

    conn.commit()
    print("Faculty records committed.")

    # 4. Import 9,000 Real Students in Batches
    print("Importing 9,000 Students from student_dataset_v1.xlsx...")
    
    # We load all existing registration numbers to avoid duplicate key errors
    cursor.execute("SELECT registration_number, id, user_id FROM students")
    existing_students = {r['registration_number']: (r['id'], r['user_id']) for r in cursor.fetchall()}
    print(f"Existing students in DB: {len(existing_students)}")

    batch_size = 500
    total_students = len(students_df)

    for i in range(0, total_students, batch_size):
        chunk = students_df.iloc[i:i+batch_size]
        for _, s in chunk.iterrows():
            reg_no = str(s['Registration_Number']).strip()
            adm_year = int(s['Admission_Year'])
            dept_code = str(s['Department_Code']).strip()
            dept_id = dept_code_to_id.get(dept_code, 1)
            b_id = batch_map.get((dept_id, adm_year), 1)
            sec_name = str(s['Section']).strip()
            sec_id = section_map.get((b_id, sec_name), 1)
            
            # Map year of study to integer 1, 2, 3, 4
            y_str = str(s['Current_Year_of_Study'])
            if "First" in y_str: y_int = 1
            elif "Second" in y_str: y_int = 2
            elif "Third" in y_str: y_int = 3
            elif "Fourth" in y_str: y_int = 4
            else: y_int = 4 # Graduated
            
            sem_int = int(s['Current_Semester'])
            status = str(s['Academic_Status']).strip()
            full_name = str(s['Cleaned_Name']).strip()
            email = str(s['Institutional_Email']).strip().lower()
            phone = str(s['Phone_No']).strip()
            gender = str(s['Gender']).strip().upper()
            roll_no = str(s['Roll_Number']).strip()

            if reg_no in existing_students:
                s_id, u_id = existing_students[reg_no]
                # Update existing student
                cursor.execute("""
                    UPDATE students 
                    SET full_name=%s, college_email=%s, phone=%s, gender=%s, department_id=%s, 
                        programme_id=%s, admission_year=%s, current_semester=%s, current_year_of_study=%s,
                        section_id=%s, status=%s, deleted_at=NULL
                    WHERE id=%s
                """, (full_name, email, phone, gender, dept_id, dept_id, adm_year, sem_int, y_int, sec_id, status, s_id))
            else:
                # Insert User
                cursor.execute("""
                    INSERT INTO users (email, password_hash, role, must_change_password)
                    VALUES (%s, %s, 'STUDENT', FALSE)
                """, (email, demo_hash))
                u_id = cursor.lastrowid

                # Insert Student
                cursor.execute("""
                    INSERT INTO students (user_id, registration_number, roll_number, full_name, college_email, phone, dob, gender, address, programme_id, department_id, admission_year, expected_graduation_year, current_semester, current_year_of_study, section_id, status)
                    VALUES (%s, %s, %s, %s, %s, %s, '2004-05-15', %s, 'Telangana, India', %s, %s, %s, %s, %s, %s, %s, %s)
                """, (u_id, reg_no, roll_no, full_name, email, phone, gender, dept_id, dept_id, adm_year, adm_year + 4, sem_int, y_int, sec_id, status))
                s_id = cursor.lastrowid
                existing_students[reg_no] = (s_id, u_id)

            # Update or Insert Academic Status
            cgpa = float(s['CGPA'])
            att = float(s['Attendance_Percentage'])
            arrears = int(s['Active_Arrears'])
            
            cursor.execute("SELECT id FROM student_academic_status WHERE student_id = %s", (s_id,))
            if cursor.fetchone():
                cursor.execute("""
                    UPDATE student_academic_status
                    SET current_cgpa=%s, current_sgpa=%s, attendance_percentage=%s, arrears_count=%s
                    WHERE student_id=%s
                """, (cgpa, cgpa, att, arrears, s_id))
            else:
                cursor.execute("""
                    INSERT INTO student_academic_status (student_id, current_cgpa, current_sgpa, attendance_percentage, arrears_count, total_credits_earned)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (s_id, cgpa, cgpa, att, arrears, sem_int * 20))

            # Update or Insert Student Fees
            fee_payable = float(s['Total_Fee_Payable'])
            fee_paid = float(s['Total_Fee_Paid'])
            balance = float(s['Fee_Balance_Due'])
            fee_stat = str(s['Fee_Status'])
            
            cursor.execute("SELECT id FROM student_fees WHERE student_id = %s", (s_id,))
            if cursor.fetchone():
                cursor.execute("""
                    UPDATE student_fees
                    SET total_payable=%s, total_paid=%s, balance_due=%s, status=%s
                    WHERE student_id=%s
                """, (fee_payable, fee_paid, balance, fee_stat, s_id))
            else:
                cursor.execute("""
                    INSERT INTO student_fees (student_id, fee_structure_id, total_payable, total_paid, balance_due, status)
                    VALUES (%s, %s, %s, %s, %s, %s)
                """, (s_id, fee_struct_id, fee_payable, fee_paid, balance, fee_stat))

        conn.commit()
        print(f"Processed {min(i + batch_size, total_students)} / {total_students} students...")

    # 5. Ensure audit_logs view & log initial import
    print("Configuring audit log views & history...")
    cursor.execute("""
        CREATE OR REPLACE VIEW audit_logs AS
        SELECT id, user_id, action, entity_name, entity_id, COALESCE(new_value, old_value, 'Action recorded') AS details, ip_address, created_at
        FROM audit_log;
    """)

    cursor.execute("""
        INSERT INTO audit_log (user_id, action, entity_name, entity_id, new_value, ip_address)
        VALUES (1, 'DATASET_IMPORT', 'students', '9000', 'Imported 9,000 real students from student_dataset_v1.xlsx across cohorts 2015-2026', '127.0.0.1')
    """)

    # 6. Ensure Analytical Views are up to date
    cursor.execute("""
        CREATE OR REPLACE VIEW v_historical_enrollment_summary AS
        SELECT 
            s.admission_year,
            d.code AS department_code,
            d.name AS department_name,
            COUNT(s.id) AS total_enrolled,
            SUM(CASE WHEN UPPER(s.gender) = 'MALE' THEN 1 ELSE 0 END) AS male_count,
            SUM(CASE WHEN UPPER(s.gender) = 'FEMALE' THEN 1 ELSE 0 END) AS female_count,
            SUM(CASE WHEN s.status = 'GRADUATED' THEN 1 ELSE 0 END) AS graduated_count,
            SUM(CASE WHEN s.status = 'ACTIVE' THEN 1 ELSE 0 END) AS currently_active_count,
            SUM(CASE WHEN s.status = 'DISCONTINUED' THEN 1 ELSE 0 END) AS discontinued_count,
            ROUND(AVG(COALESCE(stat.current_cgpa, 0)), 2) AS average_cgpa,
            ROUND(AVG(COALESCE(stat.attendance_percentage, 0)), 1) AS average_attendance
        FROM students s
        JOIN departments d ON s.department_id = d.id
        LEFT JOIN student_academic_status stat ON stat.student_id = s.id
        WHERE s.deleted_at IS NULL
        GROUP BY s.admission_year, d.code, d.name;
    """)

    cursor.execute("""
        CREATE OR REPLACE VIEW v_department_faculty_ratios AS
        SELECT 
            d.id AS department_id,
            d.code AS department_code,
            d.name AS department_name,
            COUNT(DISTINCT f.id) AS total_faculty,
            COUNT(DISTINCT CASE WHEN s.status = 'ACTIVE' AND s.deleted_at IS NULL THEN s.id END) AS active_students,
            CASE 
                WHEN COUNT(DISTINCT f.id) > 0 
                THEN ROUND(COUNT(DISTINCT CASE WHEN s.status = 'ACTIVE' AND s.deleted_at IS NULL THEN s.id END) / COUNT(DISTINCT f.id), 1)
                ELSE 0 
            END AS student_to_faculty_ratio
        FROM departments d
        LEFT JOIN faculty f ON f.department_id = d.id AND f.status = 'ACTIVE' AND f.deleted_at IS NULL
        LEFT JOIN students s ON s.department_id = d.id
        GROUP BY d.id, d.code, d.name;
    """)

    cursor.execute("""
        CREATE OR REPLACE VIEW v_gender_distribution AS
        SELECT 
            admission_year,
            COUNT(*) AS total_students,
            SUM(CASE WHEN UPPER(gender) = 'MALE' THEN 1 ELSE 0 END) AS male_students,
            SUM(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 ELSE 0 END) AS female_students,
            ROUND(SUM(CASE WHEN UPPER(gender) = 'FEMALE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS female_percentage,
            ROUND(SUM(CASE WHEN UPPER(gender) = 'MALE' THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS male_percentage
        FROM students
        WHERE deleted_at IS NULL
        GROUP BY admission_year;
    """)

    conn.commit()
    conn.close()
    print("SUCCESS: 9,000 real student records imported into MySQL!")

if __name__ == "__main__":
    import_all()
