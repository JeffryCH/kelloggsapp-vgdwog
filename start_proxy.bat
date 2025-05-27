@echo off
echo Setting up MongoDB CORS proxy...

cd /d %~dp0web

if not exist "node_modules" (
    echo Installing dependencies...
    call npm install --silent
    if %errorlevel% neq 0 (
        echo Failed to install dependencies. Make sure Node.js is installed.
        pause
        exit /b 1
    )
)

echo Starting MongoDB CORS proxy on http://localhost:3001
start "" cmd /k "npm start"

cd ..

echo Proxy is running in a new window.
echo You can now start the Flutter app in a separate terminal.

timeout /t 3
exit 0
