import 'package:mongo_dart/mongo_dart.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';
import 'constants.dart';
import 'package:logging/logging.dart';

class AdminInitializer {
  static final Logger _logger = Logger('AdminInitializer');
  static final Db _db = Db(DatabaseConstants.connectionString);

  // Hashea la contraseña usando SHA-256
  static String _hashPassword(String password) {
    var bytes = utf8.encode(password);
    var digest = sha256.convert(bytes);
    return digest.toString();
  }

  // Crea el usuario administrador si no existe
  static Future<void> ensureAdminUser() async {
    try {
      _logger.info('Verificando usuario administrador...');
      
      // Conectar a la base de datos
      await _db.open();
      
      // Obtener o crear la colección de usuarios
      final users = _db.collection('users');
      
      // Verificar si ya existe un administrador
      final adminExists = await users.findOne(where.eq('email', 'admin@kelloggs.com'));
      
      if (adminExists == null) {
        _logger.info('Creando usuario administrador...');
        
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
        _logger.info('✅ Usuario administrador ya existe');
      }
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Error al inicializar el usuario administrador', e, stackTrace);
      rethrow;
    } finally {
      await _db.close();
    }
  }
}
