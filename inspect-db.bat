@echo off
setlocal
set "MYSQL_EXE=C:\Program Files\MySQL\MySQL Server 26.10\bin\mysql.exe"

if not exist "%MYSQL_EXE%" (
    for /f "delims=" %%i in ('where mysql 2^>nul') do set "MYSQL_EXE=%%i"
)

echo ========================================================
echo  Smart College Portal - MySQL Interactive Console
echo ========================================================
echo Connecting to database: college_portal as user: root ...
echo (Type 'exit' or 'quit' to leave the console)
echo ========================================================
echo.

"%MYSQL_EXE%" -u root -pSivachari@8919 college_portal

endlocal
