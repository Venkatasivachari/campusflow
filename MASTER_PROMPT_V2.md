# Smart College Portal — Master Build Prompt (v2)

Paste everything below the line into Google Antigravity (or Claude Code). Work in a new folder `college-portal/`.

---

## 1. ROLE AND GOAL

You are a senior full-stack engineer and UI/UX designer. Build a **production-grade college management portal** with three separate experiences: **Admin**, **Faculty** and **Student**. All data comes from a **local MySQL 8** database (already installed on my machine). The product must feel like a premium, hand-designed SaaS product, not a template.

Rules for the whole project:
- No placeholder text, lorem ipsum, "TODO" screens, or fake data in the UI. Every number, list and chart is fetched from the database.
- Keep the interface text short and professional. No emojis in the UI. No marketing filler.
- Before you finish, run the project and verify it works. Report what you could not verify. Never claim a feature works unless you ran it.

## 2. TECH STACK (fixed)

| Layer | Technology |
|---|---|
| Frontend | React 18, Vite, TypeScript, Tailwind CSS, Radix UI primitives, Framer Motion, TanStack Query, TanStack Table, React Hook Form + Zod, Recharts, lucide-react icons |
| Fonts | Inter (body), Plus Jakarta Sans (headings), JetBrains Mono (IDs and numbers), self-hosted |
| Backend | Java 21, Spring Boot 3 (Web, Security, Data JPA, Validation, Mail, Actuator), Flyway migrations, Caffeine cache, springdoc OpenAPI |
| Database | MySQL 8 (local install), InnoDB, utf8mb4, HikariCP pool |
| Auth | JWT access token (15 min) + refresh token in HttpOnly SameSite cookie, BCrypt (strength 12) |
| Email | Spring Mail over SMTP (Thymeleaf HTML templates) |
| Files | PDF via OpenPDF (payslips, fee receipts, hall tickets, reports), Excel via Apache POI, CSV import via OpenCSV |
| Jobs | Spring `@Scheduled` (fee reminders, assignment reminders, low-attendance alerts, token cleanup) |
| Tests | JUnit 5 + Testcontainers (MySQL), Vitest + Testing Library, Playwright smoke tests |
| Deploy | Docker Compose, Nginx, AWS EC2 Ubuntu (keep existing `docker-compose.yml`, Dockerfiles, `scripts/`) |

## 3. LOCAL MYSQL CONNECTION

I have MySQL installed locally. Do not use H2 or any in-memory database.
- Read all settings from environment variables / `.env` (never hardcode, never commit): `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD`, `JWT_SECRET`, `AES_KEY` (32-byte base64, for encrypting sensitive fields), `SMTP_HOST`, `SMTP_PORT`, `SMTP_USER`, `SMTP_PASSWORD`, `MAIL_FROM`, `APP_BASE_URL`, `DEFAULT_PASSWORD`, `ADMIN_EMAIL`, `ADMIN_PASSWORD`.
- Provide `.env.example` and a `README` section "Run locally with my MySQL": create database, create a dedicated MySQL user (not root), run the app, Flyway creates every table.
- Create the database automatically if it does not exist, then run Flyway migrations `V1__...sql`, `V2__...sql`. Never edit an applied migration.
- I will give you the real values for the keys above. Leave clearly named empty variables; do not invent credentials.
- Docker Compose is for EC2 only. Local development must run with `mvn spring-boot:run` and `npm run dev` against my local MySQL.

## 4. THREE SEPARATE LOGIN PAGES

Routes: `/admin/login`, `/faculty/login`, `/student/login`. Each has its own layout, accent colour and headline. A faculty account cannot sign in on the admin page, and so on (server enforces role).

Each login page has: ID or email field, password field with show/hide, "Forgot password?" link, loading state on the button, clear error messages, and a branded split-screen layout (left: brand panel with a subtle animated gradient and institution name; right: the form).

**Credentials model**
1. When Admin creates a student, the system **auto-generates the registration number** and a login. Format is configurable, default `{AdmissionYY}{DeptCode}{4-digit sequence}`, for example `25CSE0001`. Faculty IDs follow `FAC{YY}{3-digit}`. Generation must be atomic and unique (use a counter table with row locking).
2. The initial password is the configured `DEFAULT_PASSWORD` (a common default, as I requested). The account is flagged `must_change_password = true`. On first login the user is forced to a "Set new password" screen and cannot open any other page until done.
3. Password policy: minimum 8 characters, upper, lower, digit, symbol; cannot equal the default password or registration number.
4. **Forgot password** (on both student and faculty pages, and admin): user enters registration number or email, receives a 6-digit OTP and a signed reset link by email (expires in 10 minutes, single use, rate limited), then sets a new password. Responses never reveal whether an account exists.
5. **Change password** inside the profile menu (current password required).
6. Admin can reset a user's password to the default, block, or unblock an account. Five failed logins locks the account for 15 minutes and writes to the blocked-account register (section 12).
7. Credentials email: when an account is created, send a welcome email through SMTP with the registration number and instructions. Do not include the password in the email if `SEND_PASSWORD_IN_EMAIL=false` (default false; the default password is communicated by the college).
8. Security note to include in the README: a shared default password is only safe because first login forces a change. Provide an option `TEMP_PASSWORD_MODE=random` that emails a one-time random password instead.

## 5. ADMIN PORTAL (full control)

Layout: collapsible sidebar, top bar with global search (Ctrl+K), notification bell, theme toggle, profile menu. Modules:

**5.1 Dashboard**
Live cards: total students, total faculty, active courses, today's attendance %, fee collected this month, pending fees, open arrears, blocked accounts. Charts: admissions by year, department-wise strength, fee collection trend, attendance trend, grade distribution, payroll by department. "Needs attention" list: low-attendance students, overdue fees, unassigned courses, timetable conflicts.

**5.2 Student management**
List with server-side search, filters (department, batch, year, semester, section, status), sort, pagination, bulk CSV import, export to Excel/PDF. Student profile has tabs: Personal, Academic, Fees, Attendance, Results and Arrears, Course registration, Documents, Activity.
Fields stored per student:
- Full name, registration number (auto), roll number, college email, personal email, phone
- Father/mother/guardian names and **parent phone number**
- Date of birth, gender, address
- **Aadhaar number** (optional; if provided, store AES-GCM encrypted, show masked `XXXX XXXX 1234`, reveal only to Admin with a logged "reveal" action)
- **ABC ID (Academic Bank of Credits), 12 digits, optional** — I wrote "ACD number"; treat as ABC ID and make the label configurable
- Programme, department, admission year, **expected graduation year** (auto-calculated from programme duration, editable), current semester, current year of study, section, admission type, photo
- Status: Active, Blocked, On leave, Graduated, Discontinued
"If present, store; if not present, leave empty" — all of Aadhaar, ABC ID, photo and personal email are optional; everything else required.

**5.3 Faculty management**
Fields: full name, employee ID (auto), email, phone, designation (Assistant Professor, Associate Professor, Professor, HOD, Lab Instructor, Visiting Faculty), department, qualification, experience, joining date, employment type, status, photo, optional Aadhaar and bank details (encrypted).
Tabs: Profile, Courses taught, Timetable, Workload (hours per week), Assignments given, Attendance marked, Salary, Activity.

**5.4 Salary and payroll**
- Pay structure by designation (grade): basic, HRA, DA, allowances, deductions (PF, tax), with per-faculty overrides and per-course teaching allowance.
- Monthly payroll run: generate for all faculty, review, lock, mark paid; payslip PDF per person; payroll history.
- Analytics: salary by department, by designation, by employment type, month-on-month cost, average pay per teaching hour. Faculty see only their own salary.

**5.5 Academic structure**
Academic years, programmes, departments, batches, semesters (with start/end dates and "current" flag), sections, courses (code, name, credits, type theory/lab/elective, semester, department), course-to-faculty-to-section allocation.

**5.6 Course registration**
Admin opens a registration window per semester and batch with deadlines and credit limits. Students register for courses (core auto-added, electives chosen, arrear subjects offered). Admin approves/rejects, sees seat counts, closes the window. Registered courses drive the student's timetable, attendance, assignments and fee.

**5.7 Arrear management**
Arrear = a course with grade F or absent. Track per student: course, semester, attempts, status (Pending, Registered for re-exam, Cleared). Admin views arrear lists by department/batch/semester, schedules **upcoming arrear exams**, and publishes arrear results. Students and parents' alert list is generated from this.

**5.8 Results and marks**
Mark entry by faculty, publishing by admin (draft → published). Grade scale and credit-weighted SGPA/CGPA configurable in a `grade_scale` table; repeated courses use the best attempt. Result sheet PDF.

**5.9 Fee structure and payments**
Fee structure per programme and year: components (tuition, exam, lab, hostel, transport, library), amounts, due dates, late-fine rules, installments, scholarships/concessions. Assign to a batch in one click. Record payments (mode, reference), print receipts (PDF), see dues by student/batch, send reminders. Student sees the structure, paid, due and history.

**5.10 Timetable**
Visual weekly grid builder per section: period × day, assign course + faculty + room. **Conflict detection** (faculty double-booked, room double-booked, section double-booked) blocks saving with a clear message. Support substitutions and one-day changes ("updated timetable"): every change notifies affected students and faculty. Timetables are versioned with an effective-from date.

**5.11 Attendance (overview)**
Class-wise, student-wise, faculty-wise (who has/has not marked attendance today), shortage list below the threshold (default 75%), condonation notes.

**5.12 Assignments (overview)**
All assignments across faculty with due dates, submission counts and late submissions. Admin can create an assignment for any course/section.

**5.13 Announcements and notifications**
Composer with: title, rich text body, priority (Info, Important, Urgent), attachment, schedule (send now or later), expiry date, delivery channel (in-app, email), and **audience targeting**: everyone, all students, all faculty, department, programme, batch/year, semester, section, or **individual** users (multi-select). Templates for common messages. Delivery tracking: sent, delivered, read, per recipient.
Notification types the system also generates automatically: arrear result published, upcoming arrear exam, marks published, new assignment, assignment due in 24 hours, fee due / overdue, low attendance, timetable change, registration window opening/closing, password changed, account blocked.

**5.14 Logs and registers**
- **Audit log:** every create/update/delete/reveal/export by admin and faculty: who, what, old and new value, IP, time. Filter, search, export.
- **Login log:** every sign-in, success or failure, with IP and device.
- **Blocked-account register:** who was blocked/unblocked, by whom (or automatic lockout), reason, time.
- **Communication log:** announcements and emails sent, with status.
Logs are append-only; nobody can edit or delete them.

**5.15 Reports and analytics**
Students by year/department/gender, admissions trend, attendance analysis, pass percentage, arrear counts, topper list, fee collection vs pending, faculty workload, payroll, course-wise performance. All exportable to PDF/Excel.

**5.16 Admin extras**
Roles and permissions (Super Admin, Academic Admin, Accounts, Exam Cell) so accounts staff only see fees, exam cell only results. Settings page for grade scale, attendance threshold, ID formats, default password, academic calendar, institution logo and name.

## 6. FACULTY PORTAL

- **Dashboard:** today's classes, pending attendance to mark, assignments to grade, upcoming deadlines, announcements, quick stats per class.
- **Profile:** name, employee ID, phone, department, designation; can edit phone/photo; change password.
- **Timetable:** personal weekly view, with updates highlighted. Shows course, section, year, room and time.
- **My courses:** each course with sections, year/semester, student list, syllabus and credits.
- **Attendance:** pick class and date, mark with one tap (default all present), edit within a configurable window, see shortage list per class, daily attendance summary.
- **Assignments:** create (title, instructions, course, section, due date, max marks, attachment), see submissions, grade with feedback, extend deadline, send reminders to non-submitters.
- **Marks:** enter internal/exam marks for own courses only; submit for publishing.
- **Student view (own classes only):** name, registration number, parent phone number, attendance %, performance trend. Never Aadhaar or fee data.
- **Notifications and announcements** received from admin; can post a class-level announcement to their own sections.
- **Salary:** own payslips only.

## 7. STUDENT PORTAL (the richest experience)

- **Dashboard:** greeting, attendance %, CGPA, upcoming assignments, today's timetable, fee due, arrear alerts, latest announcements, upcoming exams. Loads in under one second.
- **Profile:** all personal details (read-only except phone/photo/address request), registration number, ABC ID, graduation year, current semester and year; change password.
- **Timetable:** today and weekly; changes marked "Updated".
- **Course registration:** open windows, register, see status and approval.
- **Courses:** registered courses with faculty names and credits.
- **Attendance:** overall and per course, calendar heatmap, shortage warning, "classes you can still miss".
- **Assignments:** upcoming/submitted/overdue, upload submission (PDF/DOCX/ZIP, 10 MB), see marks and feedback.
- **Results:** semester-wise marks, grades, SGPA, CGPA, downloadable result sheet.
- **Arrears:** pending arrears, upcoming arrear exams, clearance history.
- **Fees:** structure, paid, due, installments, receipts (PDF), late-fine notices.
- **Announcements and notifications:** common and individual messages, unread count, mark all read, filters.
- **Semester and year summary:** total semesters, current semester, years completed, expected graduation year, credits earned vs required.
- **Forgot/Change password** available from login and profile.

## 8. DATABASE DESIGN (MySQL 8, via Flyway)

Design a normalised schema (3NF), all tables InnoDB with primary keys, foreign keys, `created_at`/`updated_at`, and soft delete (`deleted_at`) where history matters. Core tables:

`users`, `roles`, `permissions`, `user_roles`, `login_attempts`, `password_reset_tokens`, `refresh_tokens`, `id_counters`, `departments`, `programmes`, `batches`, `academic_years`, `semesters`, `sections`, `students`, `student_guardians`, `student_academic_status`, `faculty`, `designations`, `pay_grades`, `salary_components`, `faculty_salary`, `payroll_runs`, `payslips`, `courses`, `course_offerings` (course × semester × section × faculty), `registration_windows`, `course_registrations`, `timetable_versions`, `timetable_slots`, `rooms`, `attendance_sessions`, `attendance_records`, `assignments`, `assignment_submissions`, `exams`, `marks`, `grade_scale`, `results`, `arrears`, `arrear_exams`, `fee_structures`, `fee_components`, `student_fees`, `fee_payments`, `announcements`, `announcement_audience`, `notifications` (per recipient, with read state), `email_outbox`, `audit_log`, `login_log`, `blocked_account_register`, `settings`.

Requirements:
- Unique indexes on registration number, employee ID, email, Aadhaar hash (store a salted hash for duplicate checks plus the encrypted value), ABC ID.
- Composite indexes for hot queries: `(student_id, semester_id)`, `(offering_id, session_date)`, `(recipient_id, is_read, created_at)`, `(batch_id, section_id)`.
- Sensitive columns (Aadhaar, bank account) are AES-GCM encrypted by the application, never stored in plain text or logged.
- Provide `V1` schema, `V2` indexes, `V3` seed (departments, designations, grade scale, settings, roles) and an optional demo seed profile `SEED_DEMO_DATA=true` that creates realistic data for every module.
- Include an ER diagram in the README (Mermaid).

## 9. PERFORMANCE (fast retrieval)

- Every list endpoint is server-side paginated, sortable and filterable; never return unbounded results.
- Use DTO projections and fetch joins; no N+1 queries (verify with Hibernate statistics in tests).
- Student dashboard is served by one aggregated endpoint that runs a small number of indexed queries in parallel and is cached for 30–60 seconds per user (Caffeine), invalidated when relevant data changes.
- Timetable, grade scale, settings and department lists are cached.
- HikariCP tuned (pool size 10–20), slow query log reviewed, `EXPLAIN` checked for the ten hottest queries and documented.
- Frontend: TanStack Query caching with stale-while-revalidate, route-level code splitting, prefetch on hover, virtualised long tables, image lazy loading, gzip/brotli from Nginx.
- Targets: API p95 under 150 ms for dashboard and list endpoints on seeded data of 5,000 students; Lighthouse performance and accessibility above 90.

## 10. SECURITY AND PRIVACY

- Server-side authorisation on every endpoint, with ownership checks (a student can only ever read their own rows; faculty only their own offerings).
- Bean Validation on all inputs, parameterised queries only, output encoding, file upload allow-list and size limits, random stored filenames outside the web root.
- Rate limiting on login, OTP and reset endpoints; generic error messages; lockout with backoff.
- Security headers, strict CORS, HTTPS in production, secrets only from environment.
- Personal data (Aadhaar, phone numbers, parent details) is sensitive under India's DPDP Act 2023: collect only what is needed, encrypt Aadhaar and bank data, mask by default, log every reveal, restrict by role, and provide a data export and delete workflow for admins. Add a short privacy notice page.
- Never commit `.env`. Never log passwords, tokens or full Aadhaar numbers.

## 11. PREMIUM UI/UX DESIGN SYSTEM

The result must look designed by a product team, not generated. Follow these rules exactly.

**Visual language**
- Calm, editorial, high-contrast. Generous whitespace, a strict 4/8 px spacing scale, 12–16 px radii, hairline 1 px borders, soft layered shadows (never heavy black shadows).
- Colour tokens (CSS variables, light and dark themes):
  - Ink `#0B1020`, Surface `#FFFFFF` / dark `#11162A`, Canvas `#F6F7FB` / dark `#0B1020`
  - Admin accent indigo `#4F46E5`, Faculty accent teal `#0F766E`, Student accent violet `#7C3AED`
  - Success `#16A34A`, Warning `#D97706`, Danger `#DC2626`, Info `#2563EB`
  - Muted text `#64708A`, border `#E5E8F0`
- One accent per role; do not use rainbow gradients. Use a single subtle gradient only on hero/brand panels.
- Typography scale: 12/14/16/20/24/32/44; headings in Plus Jakarta Sans semibold with tight tracking; tabular numerals for all figures and IDs.

**Loading and transitions (important)**
- **Branded splash loader:** on first load show the college logo with a thin animated ring or progress line, fading out when the first data arrives. Support a configurable logo and institution name from settings.
- **Route transitions:** top progress bar plus a 180 ms fade/slide between pages.
- **Skeleton screens** that match the final layout for every card, table and chart. Never show a blank page or a bare spinner for data.
- Optimistic updates for small actions (mark read, tick attendance) with rollback on error.
- Number count-up on dashboard stats, chart draw-in animation, staggered list entry (max 40 ms steps).
- Respect `prefers-reduced-motion`.

**Interaction details**
- Buttons: clear primary / secondary / ghost / destructive hierarchy, 150 ms hover lift (translateY −1 px plus shadow), pressed state, visible keyboard focus ring, loading state inside the button.
- Cards: subtle hover elevation only when clickable. Tables: sticky header, row hover, zebra off, inline row actions, column visibility menu, density toggle.
- Command palette (Ctrl+K) for navigation and search. Toasts bottom-right with undo where relevant. Confirm dialogs for destructive actions, typed confirmation for irreversible ones.
- Empty states with a small illustration and one clear action. Friendly, short error states with retry.
- Forms: inline validation, field-level help, autosave drafts for long forms, stepper for student/faculty creation.
- Data viz: restrained palette, direct labels, tooltips, consistent axes; no 3D or pie charts with more than five slices.

**Layout and responsiveness**
- Desktop: collapsible sidebar with grouped sections and active indicator, breadcrumb, sticky top bar. Tablet and mobile: bottom navigation for students and faculty, drawer for admin. Works from 360 px to 4K.
- Dark mode, remembered per user. WCAG AA contrast, semantic HTML, aria labels, full keyboard navigation.

**Differentiation per login page**
- Admin: dark ink brand panel, dense analytical tone.
- Faculty: teal accent, task-first dashboard ("today").
- Student: lighter, warmer, greeting and progress-focused, largest emphasis on timetable, attendance and upcoming items.

## 12. REGISTERS AND LOGS (clarification of "block log register")

I asked for a "block log register" visible in the admin logs. Implement it as the **Blocked-account register** inside **Admin → Logs**, alongside the audit log and login log, as described in 5.14. Tell me if you interpret it differently.

## 13. REAL EMAIL

- Use real SMTP (I will provide host, port, user, app password). Send: welcome email, OTP, reset link, password-changed notice, announcements (when email channel selected), fee and assignment reminders.
- Use an outbox table with retry and status so failures are visible in the Communication log. Provide a "Send test email" button in Settings.
- Do not hardcode or invent any email address or password.

## 14. BUILD ORDER

1. Project skeleton, MySQL connection, Flyway V1–V3, health check.
2. Auth: three login pages, JWT, forced password change, forgot password with OTP, lockout, roles and permissions.
3. Academic structure and admin CRUD for students and faculty (with ID generation, encryption, CSV import).
4. Course offerings, registration windows, timetable builder with conflict detection.
5. Attendance, assignments, marks, results, arrears.
6. Fees and payroll with PDF output.
7. Announcements, notifications, scheduled jobs, email outbox.
8. Logs and registers, analytics and exports.
9. Design system, loading splash, transitions, dark mode, polish pass on all three portals.
10. Performance pass (indexes, caching, EXPLAIN review), tests, README, Docker for EC2.

Commit after each step.

## 15. DEFINITION OF DONE

Run and verify, then report:
1. App starts against my local MySQL; Flyway creates the schema; admin can sign in.
2. Admin creates a student and a faculty member; registration number and default password work; first login forces a password change; forgot-password email arrives and works.
3. Each role sees only what it should (prove a student cannot read another student's data, and a faculty member cannot open admin pages).
4. Timetable conflict detection, attendance, assignment alerts, arrear alerts, announcements to individual and to groups all work end to end.
5. Every page loads real data from MySQL with skeleton/splash loading and no console errors.
6. Tests pass; performance targets in section 9 are measured and reported.
7. List what is not done, assumptions you made, and anything I must configure (keys, SMTP, logo).

## 16. ASSUMPTIONS TO CONFIRM WITH ME

- "ACD number" = ABC ID (Academic Bank of Credits).
- "Block log register" = blocked-account register inside the admin logs.
- Programme types and grading scale (default: 10-point scale used in India).
- Whether parents get a login (not included; parent phone numbers are stored for contact and alerts only).
