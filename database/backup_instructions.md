# College Management System - Database Administration & Backup Guide

This document outlines the standard operational procedures for managing, backing up, restoring, and verifying the **Imperial Institute Enterprise College Management System** using **MySQL Workbench**, `mysqldump`, and Docker.

---

## 1. Database Architecture Overview

| Parameter | Configuration |
| :--- | :--- |
| **Database Name** | `college_management_system` (and `college_portal` in local Docker stack) |
| **Engine** | InnoDB (ACID compliant, Foreign Key constraints enforced) |
| **Default Charset** | `utf8mb4` |
| **Default Collation** | `utf8mb4_unicode_ci` |
| **Singleton Root Owner** | Table `root_owner_control` with `CHECK (singleton_id = 1)` |
| **Historical Range** | 2015 to 2026 Academic Cohorts |
| **Departments** | CSE, ECE, EEE, MECH, CIVIL, IT |

---

## 2. Using MySQL Workbench

### A. Execution Order for Modular SQL Scripts
When executing into a new database or staging environment from MySQL Workbench:
1. Open `schema.sql` and execute (Creates database, all tables, constraints).
2. Open `seed_roles.sql` and execute (Seeds 8 system roles).
3. Open `seed_permissions.sql` and execute (Seeds permissions and maps to roles).
4. Open `indexes.sql` and execute (Applies high-throughput indexing).
5. Open `historical_views.sql` and execute (Installs analytics and KPI views).
6. Open `sample_data.sql` and execute (Populates Root Owner, Administrators, Faculty, and 2015–2026 cohorts).

*Alternatively: Execute `db/college_management_system_master.sql` to execute all steps in a single script.*

### B. Performing a Backup via MySQL Workbench
1. Open **MySQL Workbench** and connect to your database instance.
2. In the left navigation panel (*Navigator*), click **Data Export** under the *Management* section.
3. In the **Tables to Export** panel, check `college_management_system` (or `college_portal`).
4. Under **Export Options**, select **Export to Self-Contained File**.
5. Choose your target backup path: e.g. `C:\backups\college_backup_YYYY-MM-DD.sql`.
6. Check **Include Create Schema**, **Include Stored Procedures & Functions**, and **Include Triggers**.
7. Click **Start Export**.

### C. Restoring from a Backup via MySQL Workbench
1. In MySQL Workbench, click **Data Import/Restore** under *Management*.
2. Select **Import from Self-Contained File** and choose your `.sql` backup file.
3. Click **Start Import**.
4. Once completed, execute:
   ```sql
   SELECT * FROM root_owner_control;
   SELECT * FROM v_historical_enrollment_summary;
   ```

---

## 3. Command-Line Backups (`mysqldump`)

### A. Creating a Production Dump
```bash
mysqldump -u root -p   --single-transaction   --routines   --triggers   --events   --databases college_management_system > college_backup_$(date +%F).sql
```

### B. Restoring into MySQL
```bash
mysql -u root -p college_management_system < college_backup_2026-11-04.sql
```

---

## 4. Docker Environment Backup & Restore

### A. Taking Backup from Docker Container
```powershell
docker exec portal-db mysqldump -uroot -pSivachari@8919 --routines --triggers college_portal > backup_docker_college.sql
```

### B. Restoring into Docker Container
```powershell
Get-Content backup_docker_college.sql | docker exec -i portal-db mysql -uroot -pSivachari@8919 college_portal
```

---

## 5. Singleton Root Owner Security Verification

To verify that the database integrity guarantees exactly one Root Owner:
```sql
-- 1. Check singleton control row
SELECT * FROM root_owner_control;

-- 2. Verify audit history
SELECT * FROM ownership_history;

-- 3. Verify that attempting to insert a 2nd Root Owner fails:
-- (This statement will fail with error: Duplicate entry '1' for key 'PRIMARY')
INSERT INTO root_owner_control (singleton_id, user_id, owner_id)
VALUES (1, 999, 'OWN9999');
```

---

## 6. Historical Cohort Analytics Queries (2015–2026)

```sql
-- 1. Overall cohort count by admission year:
SELECT 
    admission_year, 
    COUNT(*) AS total_students,
    SUM(CASE WHEN gender = 'MALE' THEN 1 ELSE 0 END) AS male_students,
    SUM(CASE WHEN gender = 'FEMALE' THEN 1 ELSE 0 END) AS female_students,
    SUM(CASE WHEN status = 'GRADUATED' THEN 1 ELSE 0 END) AS alumni_graduated,
    SUM(CASE WHEN status = 'ACTIVE' THEN 1 ELSE 0 END) AS currently_enrolled
FROM students
GROUP BY admission_year
ORDER BY admission_year DESC;

-- 2. Current 1st to 4th year student strength:
SELECT 
    current_year_of_study, 
    department_id, 
    gender, 
    COUNT(*) AS student_count
FROM students
WHERE status = 'ACTIVE'
GROUP BY current_year_of_study, department_id, gender
ORDER BY current_year_of_study, department_id;
```
