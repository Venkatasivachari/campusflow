# MASTER PROMPT — Smart College Portal v2 (React + Java + MySQL, Docker, AWS EC2)

Copy everything below the line into Claude Code (or any coding agent) inside the `college-portal/` folder. The folder already contains `docker-compose.yml`, Dockerfiles, `nginx.conf`, `db/init.sql`, `.env.example` and the EC2 scripts. The agent must build `backend/` and `frontend/` to match them.

---

## ROLE
You are a senior full-stack engineer and DevOps engineer. Build a production-quality, fully working **Smart College Portal v2** and make it run with a single `docker compose up -d` on Ubuntu (AWS EC2). Do not stop at a skeleton: deliver working code, seed data, tests, and verify it by actually running it.

## 1. CONTEXT
The original project is a PHP/MySQL/XAMPP portal with a student portal and an admin portal (profile, courses, attendance, results, fees, announcements, assignments, reports and analytics, teacher GPA, SGPA and CGPA calculators). Rebuild it with a modern stack and add the new features below. Preserve every original feature.

## 2. STACK (fixed)
- Frontend: React 18 + Vite + TypeScript, Tailwind CSS, React Router, TanStack Query, Recharts, Framer Motion, lucide-react icons.
- Backend: Java 21, Spring Boot 3 (Web, Security, Data JPA, Validation, Actuator), JWT auth, BCrypt, Flyway optional, springdoc OpenAPI.
- Database: MySQL 8.4. The schema is in `db/init.sql`; keep entities consistent with it (extend it with migrations if you add tables).
- Runtime: Docker Compose with services `db`, `backend` (port 8080, internal only), `frontend` (nginx, port 80, proxies `/api/` to backend). Do not change service names or healthcheck paths in `docker-compose.yml` without updating everything that depends on them. `/actuator/health` must be public.

## 3. ROLES AND FEATURES

### Student
Login, dashboard (GPA, attendance %, upcoming deadlines, fee due, latest announcements), profile (edit phone/photo), courses, attendance (overall and subject-wise with 75% warning), results (semester-wise, SGPA/CGPA), fees (total/paid/remaining, payment history, downloadable receipt PDF), announcements, assignments (view, upload submission, see marks and feedback), personal reports and analytics, notifications, AI assistant.

### Teacher (new role)
Teacher login and dashboard, own courses and student lists, mark attendance for a class date (bulk), create assignments, grade submissions with feedback, enter results for own courses, teacher GPA calculator (course name, credit hours, grade point).

### Admin
Manage students, teachers, courses, enrollments, departments, academic records, fees and payments, announcements (audience targeting), assignments, attendance; bulk CSV import of students; SGPA and CGPA calculators; reports and analytics: total students, courses, results, average marks, top students, course-wise performance, student performance, grade distribution, semester performance; audit log viewer; CSV/PDF/Excel export of any report.

## 4. NEW FEATURES TO ADD
1. **AI assistant** (chat panel on every page). Backend endpoint `/api/ai/chat` calls the Anthropic API using `ANTHROPIC_API_KEY` (server side only, never exposed to the browser). It must answer using only the logged-in user's own data (students: their own records; admins: aggregates). If the key is empty, hide the panel and return 503 gracefully.
2. **At-risk detection**: flag students with attendance < 75% or falling grade trend; show on admin and teacher dashboards; notify the student.
3. **Performance prediction**: simple projected CGPA from current trend (transparent formula, explained in UI).
4. **Notifications**: in-app bell with unread count (new announcement, grade posted, fee due, assignment due in 24h). Polling every 30s is fine.
5. **Global search** (Ctrl+K command palette) across students, courses, announcements by role.
6. **Dark/light theme**, remembered per user.
7. **Timetable / calendar view** of classes and assignment deadlines.
8. **PDF/Excel/CSV export** for reports, results sheet, fee receipts.
9. **Audit log** for every admin write action.
10. **Password reset** (token-based; log the link to console if SMTP is not configured) and forced password change on first login for created accounts.

## 5. UI/UX REQUIREMENTS
- Mobile-first, fully responsive (360px to 4K). Collapsible sidebar on desktop, bottom nav or drawer on mobile.
- Keep the original identity: light purple backgrounds, dark navy sidebar, purple accents, white cards. Add a polished modern feel: soft shadows, rounded-2xl cards, subtle gradients, smooth page transitions and skeleton loaders (no blank flashes), micro-interactions, animated charts.
- Accessible: semantic HTML, keyboard navigation, focus rings, WCAG AA contrast, aria labels, respects `prefers-reduced-motion`.
- Empty states, error states and toasts for every data view and form. Client-side validation with clear messages.
- Tables: server-side pagination, sorting, filters, column search.

## 6. SECURITY (non-negotiable)
- BCrypt password hashing, JWT access tokens (short expiry) plus refresh token in HttpOnly SameSite cookie, role-based authorization enforced **on the server** for every endpoint; students can only ever read their own rows (check ownership, not just role).
- Parameterized queries only (JPA), Bean Validation on all DTOs, output encoding handled by React, no `dangerouslySetInnerHTML`.
- Rate limit login (e.g. 5 attempts/min per IP+email), account lockout with backoff, generic login error messages.
- File uploads: allow-list extensions and MIME, size cap 10 MB, random stored names, stored in a Docker volume outside the web root.
- CORS restricted to `CORS_ALLOWED_ORIGINS`. Security headers (already in nginx). No secrets in code or images; all from `.env`.
- MySQL must never be published to the host. Backend runs as non-root (already in Dockerfile).
- Create the initial admin from `ADMIN_EMAIL`/`ADMIN_PASSWORD` only if no admin exists.

## 7. API
REST under `/api`, versionless, JSON, consistent error envelope `{timestamp, status, error, message, path}`, OpenAPI docs at `/api/swagger-ui` (restricted to admin or disabled in prod via env flag). Pagination via `page`, `size`, `sort`.

## 8. DATA
Provide a seed profile (`SEED_DEMO_DATA=true`) that creates demo departments, 2 teachers, 30 students, courses, enrollments, 3 months of attendance, results, fees, announcements and assignments so that every chart and dashboard shows meaningful data on first run. Default it to `false` for production.

## 9. DOCKER / DEVOPS
- Multi-stage builds (already provided). Keep images small, pin versions.
- Add an `uploads_data` named volume for the backend and mount it at `/app/uploads`.
- `docker compose up -d` must work from a clean clone after `cp .env.example .env`. Health-gated start order: db, then backend, then frontend.
- Provide `docker-compose.prod.yml` override adding HTTPS via Caddy or nginx + Let's Encrypt for a real domain, and log rotation (`json-file`, max-size 10m, max-file 3).
- Provide `.github/workflows/ci.yml`: build backend (tests), build frontend (lint + build), build Docker images.
- Keep `scripts/ec2-setup.sh`, `scripts/deploy.sh`, `scripts/backup.sh` working.

## 10. QUALITY
- Backend unit tests for GPA/SGPA/CGPA math, attendance %, authorization rules; integration tests with Testcontainers for MySQL.
- Frontend: component tests for critical forms; one Playwright smoke test (login, view dashboard).
- GPA rules must be configurable (grade scale table) and documented; handle credit-weighted SGPA and CGPA correctly, including repeated courses.
- Lint/format configured (Spotless/Checkstyle, ESLint/Prettier).

## 11. DOCUMENTATION
Write `README.md`: architecture diagram, features, local run, EC2 deployment, env vars table, backup/restore, troubleshooting. Update the original project documentation to reflect the new stack.

## 12. DEFINITION OF DONE
Before saying you are finished, actually run and verify:
1. `docker compose build && docker compose up -d` succeeds and all three services are `healthy`.
2. Login works as admin, teacher, and student; each role sees only what it should (prove a student cannot fetch another student's data by ID).
3. Every feature in sections 3 and 4 is reachable in the UI and works end to end.
4. All tests pass; Lighthouse mobile performance and accessibility each above 90 on the dashboard.
5. Report what you built, what you could not verify, and any assumptions. Do not claim anything works that you did not run.

Work in this order: schema and entities, auth and security, core CRUD, student flows, teacher flows, analytics, AI and notifications, UI polish, tests, docs. Commit after each stage.
