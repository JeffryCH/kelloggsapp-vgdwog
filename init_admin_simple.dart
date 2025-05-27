import 'dart:convert';
import 'dart:io';
import 'package:mongo_dart/mongo_dart.dart';
import 'lib/dbHelper/constants.dart';

void main() async {
  print('🚀 Iniciando configuración del usuario administrador...');
  print('========================================');
  
  try {
    print('🔗 Conectando a la base de datos...');
    final db = await Db.create(DatabaseConstants.connectionString);
    await db.open();
    
    // Obtener la colección de usuarios
    final users = db.collection('users');
    
    // Verificar si ya existe un administrador
    print('🔍 Verificando si ya existe un usuario administrador...');
    final adminExists = await users.findOne(where.eq('email', 'admin@kelloggs.com'));
    
    if (adminExists == null) {
      print('👤 Creando usuario administrador...');
      
      // Hashear la contraseña (SHA-256)
      final password = 'admin123';
      final bytes = utf8.encode(password);
      final digest = sha256.convert(bytes);
      final hashedPassword = digest.toString();
      
      // Crear el usuario administrador
      final adminUser = {
        'name': 'Administrador',
        'email': 'admin@kelloggs.com',
        'password': hashedPassword,
        'role': 'admin',
        'createdAt': DateTime.now(),
        'updatedAt': DateTime.now(),
        'isActive': true,
      };
      
      await users.insertOne(adminUser);
      
      print('✅ Usuario administrador creado exitosamente');
      print('🔑 Credenciales por defecto:');
      print('   Email: admin@kelloggs.com');
      print('   Contraseña: admin123');
      print('\n⚠️ ¡IMPORTANTE! Cambia la contraseña después del primer inicio de sesión');
    } else {
      print('ℹ️ El usuario administrador ya existe en la base de datos');
      print('🔑 Credenciales actuales:');
      print('   Email: admin@kelloggs.com');
      print('   Contraseña: [La contraseña que configuraste]');
    }
    
    await db.close();
    
  } catch (e, stackTrace) {
    print('❌ Error durante la configuración:');
    print('   $e');
    print('\nDetalles del error:');
    print('   $stackTrace');
    print('\n🔧 Posibles soluciones:');
    print('1. Verifica que MongoDB esté en ejecución');
    print('2. Revisa la cadena de conexión en lib/dbHelper/constants.dart');
    print('3. Asegúrate de que tu IP esté en la lista blanca de MongoDB Atlas (si usas la nube)');
    exitCode = 1;
  }
  
  print('\nPresiona Enter para salir...');
  await stdin.first;
}
