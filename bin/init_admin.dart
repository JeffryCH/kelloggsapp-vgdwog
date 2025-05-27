import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:mongo_dart/mongo_dart.dart';
import 'package:logging/logging.dart';
import '../lib/dbHelper/constants.dart';

class AdminInitializer {
  static final Logger _logger = Logger('AdminInitializer');
  static late Db _db;

  // Hashea la contraseña usando SHA-256
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Crea el usuario administrador si no existe
  static Future<void> ensureAdminUser() async {
    try {
      _logger.info('🔍 Verificando usuario administrador...');
      
      // Conectar a la base de datos
      _db = Db(DatabaseConstants.connectionString);
      await _db.open();
      
      // Obtener la colección de usuarios
      final users = _db.collection('users');
      
      // Verificar si ya existe un administrador
      final adminExists = await users.findOne(where.eq('email', 'admin@kelloggs.com'));
      
      if (adminExists == null) {
        _logger.info('👤 Creando usuario administrador...');
        
        // Crear el usuario administrador
        final adminUser = {
          'name': 'Administrador',
          'email': 'admin@kelloggs.com',
          'password': _hashPassword('admin123'), // Contraseña por defecto
          'role': 'admin',
          'createdAt': DateTime.now(),
          'updatedAt': DateTime.now(),
          'isActive': true,
        };
        
        await users.insertOne(adminUser);
        _logger.info('✅ Usuario administrador creado exitosamente');
        _logger.info('🔑 Credenciales por defecto:');
        _logger.info('   Email: admin@kelloggs.com');
        _logger.info('   Contraseña: admin123');
        _logger.warning('⚠️ Por favor cambia la contraseña después del primer inicio de sesión');
      } else {
        _logger.info('ℹ️ Usuario administrador ya existe');
      }
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Error al inicializar el usuario administrador', e, stackTrace);
      rethrow;
    } finally {
      await _db.close();
    }
  }
}

void main() async {
  // Configurar logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('${record.level.name}: ${record.time}: ${record.message}');
    if (record.error != null) {
      print('Error: ${record.error}');
    }
    if (record.stackTrace != null) {
      print('Stack trace: ${record.stackTrace}');
    }
  });

  try {
    print('🚀 Iniciando configuración del usuario administrador...');
    await AdminInitializer.ensureAdminUser();
    print('✅ Configuración completada exitosamente');
  } catch (e, stackTrace) {
    print('❌ Error durante la configuración: $e');
    print('Stack trace: $stackTrace');
    exitCode = 1; // Indica un error al sistema operativo
  }
}
