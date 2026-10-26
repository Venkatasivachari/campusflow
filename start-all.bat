@echo off
echo ========================================================
echo Starting Smart College Portal...
echo ========================================================
start "College Portal - Backend API" cmd /k "cd /d %~dp0backend && start-backend.bat"
start "College Portal - Frontend Web" cmd /k "cd /d %~dp0frontend && npm run dev"
echo.
echo Both services are launching in separate windows!
echo - Frontend UI:  http://localhost:5173
echo - Backend API:  http://localhost:8080
echo.
