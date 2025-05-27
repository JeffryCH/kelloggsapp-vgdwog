# Kelloggs App - Development Setup

¡Bienvenido al entorno de desarrollo de Kelloggs App! Sigue estos sencillos pasos para comenzar.

## Requisitos previos

- [Node.js](https://nodejs.org/) (v14 o superior)
- [Flutter](https://flutter.dev/docs/get-started/install) (última versión estable)
- Navegador Chrome instalado

## Configuración inicial

1. **Instalar dependencias del proxy CORS**
   ```bash
   cd web
   npm install
   cd ..
   ```

## Cómo ejecutar la aplicación

Simplemente ejecuta el archivo `run_dev.bat` haciendo doble clic sobre él o desde la línea de comandos:

```bash
./run_dev.bat
```

Este script hará lo siguiente:

1. Iniciará el servidor proxy CORS para MongoDB
2. Iniciará la aplicación Flutter en modo desarrollo
3. Abrirá automáticamente la aplicación en Chrome

## Solución de problemas

Si encuentras problemas de CORS:

1. Asegúrate de que el proxy se está ejecutando en http://localhost:3001
2. Verifica que tu IP esté en la lista blanca de MongoDB Atlas
3. Si ves errores de conexión, intenta:
   ```bash
   flutter clean
   flutter pub get
   ```

## Notas de desarrollo

- El modo de desarrollo desactiva temporalmente la seguridad CORS para facilitar el desarrollo
- Los cambios en el código se recargan automáticamente
- Los logs de la aplicación aparecen en la consola del navegador (F12 > Console)
