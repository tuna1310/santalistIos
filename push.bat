@echo off
echo ========================================================
echo   Dang day (push) branch feature/initial-app len GitLab...
echo ========================================================
cd /d "%~dp0"
git push -u origin feature/initial-app
echo.
echo ========================================================
pause
