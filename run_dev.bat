@echo off
echo Starting Kelloggs App Development Environment...
echo =========================================

:: Set the project directory
set PROJECT_DIR=%~dp0

:: Function to check if a process is running
:check_process
wmic process where "commandline like '%%%1%%'" get processid 2>nul | find "PID" >nul
if %ERRORLEVEL% EQU 0 (
    echo Process %1 is already running
    exit /b 1
) else (
    exit /b 0
)

:: Check if the CORS proxy is already running
call :check_process "node mongo_cors_proxy.js"
if %ERRORLEVEL% EQU 1 (
    echo MongoDB CORS proxy is already running
) else (
    echo Starting MongoDB CORS proxy...
    start "MongoDB CORS Proxy" cmd /k "cd /d %PROJECT_DIR%web && npm start"
    timeout /t 3 /nobreak >nul
)

echo.
echo Starting Flutter web app...
echo ==========================

:: Run the Flutter app
cd /d %PROJECT_DIR%
flutter run -d chrome --web-port=3000 --web-hostname=localhost --web-browser-flag "--disable-web-security"

pause
