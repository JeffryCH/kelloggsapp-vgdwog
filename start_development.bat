@echo off
setlocal enabledelayedexpansion

echo Starting Kelloggs App Development Environment...
echo =========================================

:: Set the project directory
set "PROJECT_DIR=%~dp0"

:: Function to check and kill process using a port
:CheckAndKillPort
set "port=%~1"
set "pid="

for /f "tokens=5" %%a in ('netstat -ano ^| findstr ":%port%" ^| findstr "LISTENING"') do (
    set "pid=%%a"
)

if defined pid (
    echo Port %port% is in use by process ID !pid!
    echo Attempting to terminate process...
    taskkill /F /PID !pid! >nul 2>&1
    if !ERRORLEVEL! EQU 0 (
        echo Successfully terminated process !pid!
    ) else (
        echo Failed to terminate process !pid!
    )
    timeout /t 2 /nobreak >nul
)

:: Check if port is still in use
netstat -ano | find ":%port%" | find "LISTENING" >nul
if !ERRORLEVEL! EQU 0 (
    echo Error: Port %port% is still in use. Please close the application using this port and try again.
    pause
    exit /b 1
)

goto :eof

:: Main execution starts here

:: Check and clear port 3001 (MongoDB proxy)
call :CheckAndKillPort 3001
if %ERRORLEVEL% EQU 1 exit /b 1

:: Start MongoDB CORS proxy
echo.
echo Starting MongoDB CORS proxy...
start "MongoDB CORS Proxy" cmd /k "cd /d "%PROJECT_DIR%web" && npm start"

echo Waiting for proxy to initialize...
for /l %%i in (1,1,10) do (
    timeout /t 1 /nobreak >nul
    netstat -ano | find ":3001" | find "LISTENING" >nul
    if !ERRORLEVEL! EQU 0 (
        echo MongoDB CORS proxy is running on port 3001
        goto ProxyStarted
    )
    echo .
)

echo Warning: Timed out waiting for proxy to start. Continuing anyway...

:ProxyStarted
echo.
echo Starting Flutter web app...
echo ==========================

:: Run the Flutter app
cd /d "%PROJECT_DIR%"
flutter run -d chrome --web-port=3000 --web-hostname=localhost --web-browser-flag "--disable-web-security"

:: If Flutter app exits, also kill the proxy
taskkill /FI "WINDOWTITLE eq MongoDB CORS Proxy" /F >nul 2>&1

pause
