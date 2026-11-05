# Imperial Institute - Enterprise College Management System (2015–2026)

A mission-critical Institutional Management Platform built with **React 18 + TypeScript + Vite**, **Java 21/23 + Spring Boot 3**, and **MySQL 8**.

---

## 1. System Architecture & Ownership Model

The system operates under a **Single Institution Architecture** with **Exactly One Active Root Owner**:

```
ROOT OWNER / CHANCELLOR (Dr. Rajeshwar Rao • OWN0001)
 └── SUPER ADMIN (Platform Technical & Security Control)
      └── COLLEGE ADMINISTRATION (Principal, Academic Dean, Admin Officer)
           └── HEADS OF DEPARTMENTS (CSE, ECE, IT, EEE, MECH, CIVIL)
                └── FACULTY / PROFESSORS (Teaching, Attendance, Marks, Mentoring)
                     └── CLASS REPRESENTATIVES
                          └── STUDENTS (9,000 Historical & Active Records)
```

- **Singleton Root Owner Control**: Enforced in the database through table `root_owner_control` with `CHECK (singleton_id = 1)`. Any attempt to create a secondary owner fails at the database level.
- **Immutable Ownership Transfer**: All historical authority transfers are permanently recorded in `ownership_history`.

---

## 2. Integrated Student Dataset (9,000 Records: 2015–2026)

The system integrates and enriches **9,000 student records** from `student_dataset_v1.xlsx`:

| Parameter | Metric / Value |
| :--- | :--- |
| **Total Student Records** | 9,000 |
| **Gender Distribution** | 4,510 Male (50.11%) • 4,490 Female (49.89%) |
| **Source Phone Numbers** | 100% Unique, valid 10-digit mobile numbers |
| **Source Identity Preservation** | Raw records preserved in `student_source_records` |
| **Data Cleaning** | 165 encoding/character anomalies detected and resolved in Romanized `display_name` |
| **Historical Scope** | 12 Annual Cohorts from **2015–16 to 2026–27** (750 students/year) |
| **Current Active Enrolled** | 3,000 students (1st, 2nd, 3rd, and 4th Years) |
| **Graduated Alumni** | 5,856 students |
| **Faculty Roster** | 60 Faculty Members (6 HODs, 18 Professors, 36 Associate/Assistant Professors) |

---

## 3. Dedicated Portal Login URLs & Credentials

| Portal | URL | Username / Identifier | Password | Key Capabilities |
| :--- | :--- | :--- | :--- | :--- |
| **Root Owner** | [`http://localhost:3000/owner/login`](http://localhost:3000/owner/login) | `owner@college.local` or `OWN0001` | `Owner@12345` | Supreme governance, 2015–2026 cohort analytics, department ratios, financial audit. |
| **Administration** | [`http://localhost:3000/admin/login`](http://localhost:3000/admin/login) | `admin@college.local` | `Admin@12345` | Admissions, batch promotions, faculty rosters, fee structures, security logs. |
| **Faculty** | [`http://localhost:3000/faculty/login`](http://localhost:3000/faculty/login) | `teacher1@college.local` or `FAC25001` | `Demo@12345` | Attendance entry, assessment marks, mentee tracking, course syllabus. |
| **Student** | [`http://localhost:3000/student/login`](http://localhost:3000/student/login) | `25CSE0001` or `manish.banerjee2025@college.local` | `Demo@12345` | CGPA calculation, semester attendance percentage, timetable, fee receipts. |

---

## 4. Generated Artifacts & Datasets

All required datasets and database scripts are generated and located in `data/` and `database/`:

1. [`data/cleaned_student_dataset.xlsx`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/data/cleaned_student_dataset.xlsx): Standardized student records with original data preserved.
2. [`data/enriched_student_dataset.xlsx`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/data/enriched_student_dataset.xlsx): Full 9,000 student records enriched with admission batches, departments, semesters, sections, CGPA, and faculty allocations.
3. [`data/faculty_demo_dataset.xlsx`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/data/faculty_demo_dataset.xlsx): 60 faculty demonstration profiles with designations and salary structures.
4. [`data/data_quality_report.xlsx`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/data/data_quality_report.xlsx): Complete data validation report with metrics, repeated names, and encoding checks.
5. [`data/student_import_errors.xlsx`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/data/student_import_errors.xlsx): Preserved review template for rejected rows.
6. [`database/college_database_schema.sql`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/database/college_database_schema.sql): Complete DDL schema ready for MySQL Workbench.
7. [`database/historical_analytics.sql`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/database/historical_analytics.sql): Year-wise cohort analytics views (2015–2026).
8. [`database/faculty_student_allocation.sql`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/database/faculty_student_allocation.sql): Allocation mapping procedures and views.
9. [`database/sample_data.sql`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/database/sample_data.sql): Master population script (5.7 MB) with all 9,000 students and 60 faculty members.
10. [`database_relationships.md`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/database_relationships.md): Detailed ERD and relationship documentation.
11. [`API_DOCUMENTATION.md`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/API_DOCUMENTATION.md): REST API specification.

---

## 5. Running the Application

### Option A: Direct Local Execution (Running Now)
- **Launch via batch file**: Double click [`start-all.bat`](file:///c:/Users/VENKATASIVA/Downloads/college-portal%20(1)/college-portal/start-all.bat)
- **Frontend URL**: `http://localhost:3000`
- **Backend API**: `http://localhost:8080`
- **Database**: Local MySQL Server 8.0 on port 3306 (`college_portal`)

### Option B: Docker Compose
Once Docker Desktop is opened:
```bash
docker compose up -d
```
All 3 containers (`portal-db`, `portal-api`, `portal-web`) will run automatically on `http://localhost:3000`.

### Option C: MySQL Workbench
Open MySQL Workbench, connect to `localhost:3306`, and execute:
1. `database/college_database_schema.sql`
2. `database/historical_analytics.sql`
3. `database/faculty_student_allocation.sql`
4. `database/sample_data.sql`
