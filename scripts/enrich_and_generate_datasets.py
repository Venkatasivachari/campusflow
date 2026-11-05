import os
import re
import datetime
import pandas as pd
import openpyxl

def main():
    base_dir = os.path.join(os.path.dirname(__file__), "..", "data")
    excel_path = os.path.join(base_dir, "student_dataset_v1.xlsx")
    
    print("Loading source dataset...")
    df = pd.read_excel(excel_path)
    total_records = len(df)
    print(f"Loaded {total_records} records.")

    # --------------------------------------------------------------------------
    # 1. Clean Names & Preserve Source Data
    # --------------------------------------------------------------------------
    mojibake_pattern = re.compile(r'[ÃÂâ€šï¿½\?\x80-\x9f]')
    
    cleaned_rows = []
    for idx, row in df.iterrows():
        raw_name = str(row['Student_Names']).strip()
        phone = str(row['Phone_No.']).strip().replace('.0', '')
        gender = str(row['Gender']).strip()
        
        has_anomaly = bool(mojibake_pattern.search(raw_name)) or any(ord(c) > 127 for c in raw_name)
        
        # Clean Romanized display name
        clean_name = raw_name
        if has_anomaly:
            # Strip non-ASCII or mojibake artifacts
            clean_name = re.sub(r'[^\w\s\.\-]', '', raw_name).strip()
            # If name became empty or only whitespace, fallback
            if not clean_name:
                clean_name = f"Student {idx + 1}"
            else:
                clean_name = re.sub(r'\s+', ' ', clean_name)
        
        cleaned_rows.append({
            "Source_Row_ID": idx + 1,
            "Original_Name": raw_name,
            "Cleaned_Name": clean_name,
            "Phone_No": phone,
            "Gender": gender,
            "Has_Encoding_Anomaly": has_anomaly,
            "Verification_Status": "VERIFIED_SOURCE"
        })

    cleaned_df = pd.DataFrame(cleaned_rows)
    cleaned_path = os.path.join(base_dir, "cleaned_student_dataset.xlsx")
    cleaned_df.to_excel(cleaned_path, index=False)
    print(f"1. Saved {cleaned_path}")

    # --------------------------------------------------------------------------
    # 2. Generate Synthetic Faculty Dataset
    # --------------------------------------------------------------------------
    depts = [
        ("CSE", "Computer Science and Engineering", "BTECH-CSE"),
        ("ECE", "Electronics and Communication Engineering", "BTECH-ECE"),
        ("EEE", "Electrical and Electronics Engineering", "BTECH-EEE"),
        ("MECH", "Mechanical Engineering", "BTECH-MECH"),
        ("CIVIL", "Civil Engineering", "BTECH-CIVIL"),
        ("IT", "Information Technology", "BTECH-IT")
    ]

    faculty_first_names = [
        ("Anita", "Female"), ("Rahul", "Male"), ("Vikram", "Male"), ("Priya", "Female"),
        ("Suresh", "Male"), ("Meenakshi", "Female"), ("Arvind", "Male"), ("Kavita", "Female"),
        ("Ramesh", "Male"), ("Sunita", "Female"), ("Manoj", "Male"), ("Deepa", "Female"),
        ("Girish", "Male"), ("Swati", "Female"), ("Naveen", "Male"), ("Lakshmi", "Female"),
        ("Pradeep", "Male"), ("Shweta", "Female"), ("Harish", "Male"), ("Vandana", "Female"),
        ("Sanjay", "Male"), ("Radhika", "Female"), ("Mahesh", "Male"), ("Aparna", "Female")
    ]
    faculty_last_names = ["Rao", "Mehta", "Sethi", "Nambiar", "Varma", "Reddy", "Patel", "Sharma", "Iyer", "Gupta"]

    faculty_list = []
    fac_counter = 101

    for d_idx, (d_code, d_name, _) in enumerate(depts):
        # 1 HOD per department
        hod_fname, hod_gender = faculty_first_names[d_idx * 4 % len(faculty_first_names)]
        hod_lname = faculty_last_names[d_idx % len(faculty_last_names)]
        hod_name = f"Dr. {hod_fname} {hod_lname}"
        faculty_list.append({
            "Faculty_ID": f"FAC{fac_counter:04d}",
            "Employee_ID": f"HOD{d_code}001",
            "Full_Name": hod_name,
            "Gender": hod_gender,
            "Department_Code": d_code,
            "Designation": "Professor & HOD",
            "Highest_Qualification": "Ph.D.",
            "Specialization": f"Advanced {d_name}",
            "Joining_Date": "2014-06-15",
            "Experience_Years": 18,
            "Employment_Type": "PERMANENT",
            "Status": "ACTIVE",
            "Official_Email": f"hod.{d_code.lower()}@college.local",
            "Phone_No": f"+91 98490 {fac_counter}01",
            "Basic_Salary": 140000,
            "Gross_Salary": 195000,
            "Net_Salary": 172000,
            "Data_Status": "SYNTHETIC / DEMO"
        })
        fac_counter += 1

        # 9 Professors / Associate / Assistant per department
        designations = ["Professor", "Associate Professor", "Associate Professor", "Assistant Professor", 
                        "Assistant Professor", "Assistant Professor", "Assistant Professor", "Assistant Professor", "Assistant Professor"]
        for i, desig in enumerate(designations):
            fn_idx = (d_idx * 4 + i + 1) % len(faculty_first_names)
            fname, fgender = faculty_first_names[fn_idx]
            lname = faculty_last_names[(d_idx + i + 1) % len(faculty_last_names)]
            prefix = "Dr." if "Professor" in desig and "Assistant" not in desig else "Prof."
            fullname = f"{prefix} {fname} {lname}"
            exp = 14 if desig == "Professor" else (10 if desig == "Associate Professor" else 5 + (i % 4))
            basic = 120000 if desig == "Professor" else (85000 if desig == "Associate Professor" else 55000)
            gross = basic * 1.35
            net = gross * 0.88

            faculty_list.append({
                "Faculty_ID": f"FAC{fac_counter:04d}",
                "Employee_ID": f"FAC{d_code}{i+1:03d}",
                "Full_Name": fullname,
                "Gender": fgender,
                "Department_Code": d_code,
                "Designation": desig,
                "Highest_Qualification": "Ph.D." if "Professor" in desig and "Assistant" not in desig else "M.Tech",
                "Specialization": f"{d_code} Core & Applied Systems",
                "Joining_Date": f"{2015 + (i % 6):04d}-07-01",
                "Experience_Years": exp,
                "Employment_Type": "PERMANENT",
                "Status": "ACTIVE",
                "Official_Email": f"teacher.{d_code.lower()}{i+1}@college.local",
                "Phone_No": f"+91 98490 {fac_counter}01",
                "Basic_Salary": basic,
                "Gross_Salary": round(gross, 2),
                "Net_Salary": round(net, 2),
                "Data_Status": "SYNTHETIC / DEMO"
            })
            fac_counter += 1

    faculty_df = pd.DataFrame(faculty_list)
    faculty_path = os.path.join(base_dir, "faculty_demo_dataset.xlsx")
    faculty_df.to_excel(faculty_path, index=False)
    print(f"2. Saved {faculty_path} ({len(faculty_df)} faculty members)")

    # --------------------------------------------------------------------------
    # 3. Enrich 9,000 Students Across 2015-2026 Cohorts
    # --------------------------------------------------------------------------
    # 12 Academic Admission Years (2015 to 2026)
    # 750 students per year = 9,000 students
    # Department seat distribution per year:
    # CSE: 150, ECE: 125, IT: 125, EEE: 120, MECH: 115, CIVIL: 115 = 750
    dept_quotas = [
        ("CSE", 150),
        ("ECE", 125),
        ("IT", 125),
        ("EEE", 120),
        ("MECH", 115),
        ("CIVIL", 115)
    ]

    current_academic_year = 2026
    enriched_rows = []

    rec_idx = 0
    for adm_year in range(2015, 2027): # 2015 to 2026
        grad_year = adm_year + 4
        
        # Progression logic as of Academic Year 2026-27:
        if adm_year <= 2022:
            current_status = "GRADUATED"
            year_of_study = "Graduated"
            semester = 8
        elif adm_year == 2023:
            current_status = "ACTIVE"
            year_of_study = "Fourth Year"
            semester = 7
        elif adm_year == 2024:
            current_status = "ACTIVE"
            year_of_study = "Third Year"
            semester = 5
        elif adm_year == 2025:
            current_status = "ACTIVE"
            year_of_study = "Second Year"
            semester = 3
        else: # 2026
            current_status = "ACTIVE"
            year_of_study = "First Year"
            semester = 1

        for dept_code, quota in dept_quotas:
            # Faculty assigned to this department
            dept_fac = [f for f in faculty_list if f["Department_Code"] == dept_code]
            hod_fac = [f for f in dept_fac if "HOD" in f["Designation"]][0]
            teaching_fac = [f for f in dept_fac if "HOD" not in f["Designation"]]

            for q_idx in range(quota):
                if rec_idx >= total_records:
                    break
                
                src = cleaned_rows[rec_idx]
                student_num = rec_idx + 1
                
                # Section assignment: A, B, C (50 per section approx)
                sec_letter = "A" if q_idx < 60 else ("B" if q_idx < 120 else "C")
                section_name = f"Section {sec_letter}"
                
                # Coordinator & Mentor from department faculty
                coord_fac = teaching_fac[0 if sec_letter == "A" else (1 if sec_letter == "B" else 2)]
                mentor_fac = teaching_fac[(q_idx // 15) % len(teaching_fac)]

                # Registration & Roll numbers
                reg_no = f"{str(adm_year)[2:]}{dept_code}{q_idx+1:04d}"
                stu_id = f"STU{student_num:06d}"
                adm_no = f"ADM{adm_year}{q_idx+1:04d}"
                roll_no = f"{dept_code}{str(adm_year)[2:]}{sec_letter}{q_idx+1:03d}"

                # Status check: simulate 1.5% discontinued in older batches
                status = current_status
                if adm_year <= 2024 and (q_idx == 43 or q_idx == 87):
                    status = "DISCONTINUED"

                # Synthetic academic performance
                # CGPA between 6.50 and 9.75
                cgpa = round(7.0 + ((q_idx * 37 + adm_year * 13) % 270) / 100.0, 2)
                if cgpa > 9.85: cgpa = 9.85
                
                # Attendance between 75.0% and 95.0%
                att = round(76.0 + ((q_idx * 19 + adm_year * 7) % 200) / 10.0, 1)
                
                # Arrears
                arrears = 0 if cgpa >= 7.5 else (1 if cgpa >= 6.8 else 2)
                if status == "GRADUATED": arrears = 0 # Graduated students cleared all arrears

                # Email
                clean_name_parts = src["Cleaned_Name"].lower().split()
                first = re.sub(r'[^a-z]', '', clean_name_parts[0]) if clean_name_parts else "student"
                last = re.sub(r'[^a-z]', '', clean_name_parts[-1]) if len(clean_name_parts) > 1 else str(q_idx+1)
                email = f"{first}.{last}.{reg_no.lower()}@college.local"

                # Fees
                fee_payable = 85000.00
                fee_paid = fee_payable if status == "GRADUATED" or (q_idx % 7 != 0) else 45000.00
                fee_due = fee_payable - fee_paid
                fee_status = "PAID" if fee_due == 0 else "PARTIAL"

                enriched_rows.append({
                    "Student_Database_ID": student_num,
                    "Student_ID": stu_id,
                    "Registration_Number": reg_no,
                    "Admission_Number": adm_no,
                    "Roll_Number": roll_no,
                    "Original_Name": src["Original_Name"],
                    "Cleaned_Name": src["Cleaned_Name"],
                    "Phone_No": src["Phone_No"],
                    "Gender": src["Gender"],
                    "Institutional_Email": email,
                    "Admission_Year": adm_year,
                    "Expected_Graduation_Year": grad_year,
                    "Admission_Batch": f"{adm_year}–{str(adm_year+1)[2:]}",
                    "Department_Code": dept_code,
                    "Degree": "B.Tech",
                    "Current_Year_of_Study": year_of_study,
                    "Current_Semester": semester,
                    "Section": section_name,
                    "Academic_Status": status,
                    "CGPA": cgpa,
                    "Attendance_Percentage": att,
                    "Active_Arrears": arrears,
                    "Assigned_HOD": hod_fac["Full_Name"],
                    "Assigned_Class_Coordinator": coord_fac["Full_Name"],
                    "Assigned_Mentor": mentor_fac["Full_Name"],
                    "Total_Fee_Payable": fee_payable,
                    "Total_Fee_Paid": fee_paid,
                    "Fee_Balance_Due": fee_due,
                    "Fee_Status": fee_status,
                    "Source_Verification": "VERIFIED_EXCEL_ROW",
                    "Academic_Record_Type": "SYNTHETIC_ACADEMIC_DEMO"
                })

                rec_idx += 1

    enriched_df = pd.DataFrame(enriched_rows)
    enriched_path = os.path.join(base_dir, "enriched_student_dataset.xlsx")
    enriched_df.to_excel(enriched_path, index=False)
    print(f"3. Saved {enriched_path} ({len(enriched_df)} enriched students)")

if __name__ == "__main__":
    main()

