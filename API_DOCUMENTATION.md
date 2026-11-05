# Enterprise College Management System - REST API Documentation

This document describes the RESTful API endpoints provided by the Spring Boot backend (`http://localhost:8080` / proxied via `http://localhost:3000/api`).

---

## 1. Authentication & Security Endpoints (`/api/auth`)

| Endpoint | Method | Role Required | Description |
| :--- | :--- | :--- | :--- |
| `/api/auth/login/owner` | `POST` | Public | Dedicated Root Owner login (`owner@college.local` or `OWN0001` / `Owner@12345`). |
| `/api/auth/login/admin` | `POST` | Public | Dedicated College Administration login (`admin@college.local` / `Admin@12345`). |
| `/api/auth/login/faculty` | `POST` | Public | Dedicated Faculty login (`teacher1@college.local` or `FAC25001` / `Demo@12345`). |
| `/api/auth/login/student` | `POST` | Public | Dedicated Student login (`25CSE0001` / `Demo@12345`). |
| `/api/auth/login` | `POST` | Public | Universal identifier login for all roles. |
| `/api/auth/refresh` | `POST` | Public | Issues a new JWT access token using a valid refresh token. |
| `/api/auth/change-password` | `POST` | Authenticated | Updates account password adhering to complexity policy. |
| `/api/auth/logout` | `POST` | Authenticated | Revokes current session and clears refresh tokens. |

---

## 2. Root Owner Governance Endpoints (`/api/owner`)

*Requires role `ROLE_OWNER` or `ROLE_SUPER_ADMIN`.*

| Endpoint | Method | Parameters | Description |
| :--- | :--- | :--- | :--- |
| `/api/owner/overview` | `GET` | None | Returns institutional KPIs (total students, active students, alumni, faculty count, fees collected/pending, average CGPA & attendance, gender breakdown). |
| `/api/owner/historical-analytics` | `GET` | `year` (optional) | Cohort analytics from 2015 to 2026 across all departments, tracking admissions, alumni, active students, and gender balance. |
| `/api/owner/departments` | `GET` | None | Department-wise faculty-to-student ratios, faculty counts, and assigned HODs. |
| `/api/owner/admins` | `GET` | None | Lists administrative user accounts and operational roles. |
| `/api/owner/admins` | `POST` | JSON body | Creates a new executive administrator account (Principal, Dean, AO). |
| `/api/owner/financial-summary` | `GET` | None | Macro institutional financial overview (receivables, collections, payroll commitments). |
| `/api/owner/audit-logs` | `GET` | `limit` (default: 100) | Immutable security audit trail with actor, action, timestamp, and IP. |

---

## 3. Administration & Academic Endpoints (`/api/admin`)

*Requires role `ROLE_ADMIN`, `ROLE_PRINCIPAL`, `ROLE_DEAN`, or `ROLE_OWNER`.*

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/api/admin/students` | `GET` | Paginated search of students with department, admission year, batch, and status filters. |
| `/api/admin/faculty` | `GET` | Faculty roster with qualification, department, designation, and experience. |
| `/api/admin/departments` | `GET` | Academic departments directory and seat allocations. |
| `/api/admin/batches` | `GET` | Admission batches from 2015 through 2026. |
| `/api/admin/logs/login` | `GET` | Login attempt logs (successes and failed attempts). |
| `/api/admin/logs/blocked` | `GET` | Accounts temporarily blocked or locked out due to failed attempts. |

---

## 4. Faculty Endpoints (`/api/faculty`)

*Requires role `ROLE_FACULTY`, `ROLE_HOD`, or `ROLE_ADMIN`.*

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/api/faculty/dashboard` | `GET` | Teaching workload, assigned subjects, and mentee count. |
| `/api/faculty/attendance` | `POST` | Submits lecture attendance for assigned section and subject. |
| `/api/faculty/marks` | `POST` | Records internal assessment and examination marks. |
| `/api/faculty/mentees` | `GET` | Lists students assigned under personal academic mentorship. |

---

## 5. Student Endpoints (`/api/student`)

*Requires role `ROLE_STUDENT`.*

| Endpoint | Method | Description |
| :--- | :--- | :--- |
| `/api/student/dashboard` | `GET` | Personal academic metrics: CGPA, attendance percentage, active arrears, fees status. |
| `/api/student/timetable` | `GET` | Weekly timetable schedule for student's section. |
| `/api/student/fees` | `GET` | Fee account summary and downloadable payment receipts. |

