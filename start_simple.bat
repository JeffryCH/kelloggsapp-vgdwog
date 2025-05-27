@echo off
echo Starting Kelloggs App Development Environment...
echo =========================================

:: Kill any existing Node.js processes that might be using port 3001
taskkill /F /IM node.exe >nul 2>&1

:: Start MongoDB CORS proxy in a new window
start "MongoDB CORS Proxy" cmd /k "cd /d %~dp0web && npm start"

:: Wait a bit for the proxy to start
timeout /t 10 /nobreak >nul

:: Start Flutter app
echo.
echo Starting Flutter web app...
echo ==========================

cd /d %~dp0
flutter run -d chrome --web-port=3000 --web-hostname=localhost --web-browser-flag "--disable-web-security"

:: Cleanup: Kill the proxy when Flutter app is closed
taskkill /F /IM node.exe >nul 2>&1

echo.
echo Development environment has been cleaned up.
pause
