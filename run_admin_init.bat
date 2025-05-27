@echo off
echo Inicializando usuario administrador...
echo =======================================

dart run init_admin_simple.dart

if %ERRORLEVEL% EQU 0 (
    echo.
    echo ✅ Proceso completado exitosamente
) else (
    echo.
    echo ❌ Ocurrió un error durante la inicialización
)

echo.
pause
