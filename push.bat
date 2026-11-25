@echo off
echo ========================================================
echo   Dang day (push) code len GitHub: tuna1310/santalistIos
echo ========================================================
cd /d "%~dp0"

echo.
echo [1/2] Dang push branch 'main'...
git push -u github main

echo.
echo [2/2] Dang push branch 'feature/initial-app'...
git push -u github feature/initial-app

echo.
echo ========================================================
echo   Hoan tat! Nhan phim bat ky de thoat.
echo ========================================================
pause

