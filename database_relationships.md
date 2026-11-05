# Enterprise College Management System - Database Relationships & Data Architecture

This document specifies the relational data model, foreign key hierarchy, entity classifications, and integration mapping for the **9,000 students** ingested from `student_dataset_v1.xlsx` and the **60 faculty members** across 12 academic cohorts (2015–2026).

---

## 1. Relational Entity Hierarchy

```
INSTITUTION (Singleton)
  │
  ├── ROOT OWNER (Single permanent authority • root_owner_control)
  │     └── OWNERSHIP HISTORY (Immutable audit log)
  │
  ├── DEPARTMENTS (CSE, ECE, IT, EEE, MECH, CIVIL)
  │     ├── PROGRAMMES & COURSES (B.Tech 4-Year / 8-Semester)
  │     ├── SUBJECTS (Core, Elective, Labs)
  │     ├── STUDENT BATCHES (2015–2026)
  │     │     └── SECTIONS (Section A, B, C)
  │     └── FACULTY (HODs, Professors, Associate & Assistant Professors)
  │           ├── FACULTY SALARY & EMPLOYMENT HISTORY
  │           └── FACULTY ALLOCATIONS
  │                 ├── Role: HOD
  │                 ├── Role: CLASS_COORDINATOR
  │                 ├── Role: CLASS_MENTOR
  │                 └── Role: SUBJECT_FACULTY
  │
  └── STUDENT DATASET INTEGRATION (9,000 Records)
        ├── STUDENT_SOURCE_RECORDS (Preserved immutable source Excel data)
        ├── STUDENTS (Enriched institutional student profile)
        ├── STUDENT_ACADEMIC_HISTORY (Progression across semesters 1–8)
        ├── STUDENT_STATUS_HISTORY (Active, Graduated, Discontinued)
        └── STUDENT_FEE_ACCOUNTS (Billing, payments, arrears)
```

---

## 2. Table Specifications & Relationships

### A. Core Governance & Identity
- **`institutions`**: Represents the college entity (`IITM-2026`, established 2014).
- **`users`**: System authentication credentials (BCrypt hashed), roles (`OWNER`, `ADMIN`, `FACULTY`, `STUDENT`), account lockout tracking.
- **`root_owner_control`**: Singleton pattern table enforcing exactly one active root owner with `singleton_id TINYINT PRIMARY KEY DEFAULT 1 CHECK (singleton_id = 1)`.
- **`ownership_history`**: Immutable ledger of ownership transfers.
- **`owners`**: Root owner profile (`OWN0001` - Dr. Rajeshwar Rao).

### B. Organizational & Faculty Management
- **`departments`**: 6 Engineering departments (CSE, ECE, IT, EEE, MECH, CIVIL).
- **`designations`**: Academic hierarchy levels (Chancellor &rarr; Principal &rarr; Dean &rarr; HOD &rarr; Professor &rarr; Associate Professor &rarr; Assistant Professor).
- **`faculty`**: 60 faculty members with employee code, qualification, specialization, joining date, experience, and contact information.
- **`faculty_salary_history`**: Basic pay, allowances, gross salary, and net salary.

### C. Student Dataset & Academic Progression (2015–2026)
- **`student_source_records`**: Protects raw data directly imported from `student_dataset_v1.xlsx` (`source_name`, `source_phone`, `source_gender`, `has_encoding_anomaly`).
- **`students`**: Enriched profile with `student_id` (`STU000001`), `admission_number` (`ADM20260001`), `registration_number` (`26CSE0001`), `roll_number` (`CSE26A001`), department, admission year, and status.
- **`student_academic_history`**: Tracks CGPA, attendance percentage, and promotion status per semester.
- **`faculty_allocations`**: Bridges students to their assigned HOD, Class Coordinator, and Faculty Mentor.
- **`student_fee_accounts`**: Tracks annual tuition fees (₹85,000.00), payments received, and outstanding dues.

---

## 3. Data Integrity & Verification Standards

1. **Identity Preservation**: Source names and 10-digit phone numbers from the uploaded file are strictly maintained in `student_source_records`.
2. **Display Names**: When encoding anomalies (e.g. Devanagari or mojibake artifacts) occur, a standardized Romanized display name is generated in `display_name` without overwriting `full_name` or `source_name`.
3. **Data Provenance**:
   - `data_origin`: Marked as `EXCEL_SOURCE_VERIFIED`.
   - `academic_data_type`: Marked as `SYNTHETIC_ACADEMIC_DEMO` to clearly distinguish generated academic metrics from verified institutional identity.

