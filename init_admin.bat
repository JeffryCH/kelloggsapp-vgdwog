@echo off
echo Inicializando usuario administrador...
echo =======================================

dart run bin/init_admin.dart

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Usuario administrador configurado exitosamente
    echo 🔑 Credenciales por defecto:
    echo    Email: admin@kelloggs.com
    echo    Contraseña: admin123
    echo.
    echo ⚠️ Recuerda cambiar la contraseña después del primer inicio de sesión
) else (
    echo.
    echo ❌ Error al configurar el usuario administrador
)

pause
