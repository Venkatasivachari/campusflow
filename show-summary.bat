@echo off
setlocal
set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 26.10\bin\mysql.exe"

if not exist "%MYSQL_EXE%" (
    for /f "delims=" %%i in ('where mysql 2^>nul') do set "MYSQL_EXE=%%i"
)

echo ========================================================
echo  Smart College Portal - Database Summary Report
echo ========================================================
echo.

"%MYSQL_EXE%" -u root -pSivachari@8919 -t college_portal -e "SELECT 'users' AS table_name, COUNT(*) AS total_rows FROM users UNION ALL SELECT 'students', COUNT(*) FROM students UNION ALL SELECT 'faculty', COUNT(*) FROM faculty UNION ALL SELECT 'courses', COUNT(*) FROM courses UNION ALL SELECT 'course_offerings', COUNT(*) FROM course_offerings UNION ALL SELECT 'marks', COUNT(*) FROM marks UNION ALL SELECT 'arrears', COUNT(*) FROM arrears UNION ALL SELECT 'payroll_runs', COUNT(*) FROM payroll_runs UNION ALL SELECT 'payslips', COUNT(*) FROM payslips UNION ALL SELECT 'audit_log', COUNT(*) FROM audit_log UNION ALL SELECT 'login_log', COUNT(*) FROM login_log;"

echo.
echo ========================================================
endlocal
