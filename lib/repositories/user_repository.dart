import 'package:mongo_dart/mongo_dart.dart';
import '../models/user_model.dart';
import '../utils/auth_utils.dart';
import '../dbHelper/mongodb.dart';
import '../dbHelper/constants.dart';

class UserRepository {
  static final UserRepository _instance = UserRepository._internal();
  
  factory UserRepository() => _instance;
  
  UserRepository._internal();
  
  // Ensure users collection exists with proper indexes
  static Future<void> ensureCollection() async {
    try {
      final db = await MongoDB.db;
      if (db == null) throw Exception('Database not initialized');
      
      // Try to create collection (will fail silently if it exists)
      try {
        await db.createCollection(DatabaseConstants.usersCollection);
        
        // Create indexes
        final collection = db.collection(DatabaseConstants.usersCollection);
        await collection.createIndex(
          keys: {'username': 1},
          unique: true,
          name: 'username_index',
        );
        
        await collection.createIndex(
          keys: {'email': 1},
          unique: true,
          name: 'email_index',
        );
        
        // Create default admin user if collection was just created
        await _instance.ensureAdminUser();
      } catch (e) {
        // Collection likely already exists, continue
      }
    } catch (e) {
      print('Error ensuring users collection: $e');
      rethrow;
    }
  }
  
  // Get users collection
  Future<DbCollection> get _usersCollection async {
    await ensureCollection();
    return MongoDB.getCollection(DatabaseConstants.usersCollection);
  }
  
  // Create admin user if not exists
  Future<void> ensureAdminUser() async {
    try {
      print('🔍 Verificando si el usuario admin existe...');
      final users = await _usersCollection;
      
      // Mostrar información de depuración
      print('🔍 Verificando la colección de usuarios...');
      
      // Buscar el usuario admin
      final admin = await users.findOne({'username': 'admin'});
      
      if (admin == null) {
        print('➕ El usuario admin no existe, creándolo...');
        
        // Create admin user with default password 'admin123'
        final salt = AuthUtils.generateSalt();
        final hashedPassword = AuthUtils.hashPassword('admin123', salt);
        
        final adminUser = UserModel(
          username: 'admin',
          password: '$salt:$hashedPassword',
          fullName: 'Administrador',
          email: 'admin@kelloggs.com',
          roles: [UserRoles.admin],
          isActive: true,
        );
        
        print('🔑 Credenciales por defecto:');
        print('   Usuario: admin');
        print('   Contraseña: admin123');
        print('   Salt: $salt');
        print('   Hash: $hashedPassword');
        
        final result = await users.insertOne(adminUser.toMap());
        
        if (result.isSuccess) {
          print('✅ Usuario admin creado exitosamente');
          print('   ID: ${result.id}');
        } else {
          print('❌ Error al crear el usuario admin');
          print('   Error: ${result.errmsg}');
        }
      } else {
        print('ℹ️ El usuario admin ya existe');
        print('📋 Datos del admin: $admin');
      }
    } catch (e, stackTrace) {
      print('❌ Error al verificar/crear el usuario admin');
      print('   Error: $e');
      print('   Stack trace: $stackTrace');
      rethrow;
    }
  }
  
  // Authenticate user
  Future<UserModel?> authenticate(String username, String password) async {
    try {
      print('🔍 Buscando usuario: $username');
      final users = await _usersCollection;
      final userData = await users.findOne({
        'username': username,
        'isActive': true,
      });
      
      if (userData != null) {
        print('✅ Usuario encontrado en la base de datos');
        print('📋 Datos del usuario: $userData');
        
        final user = UserModel.fromMap(userData);
        print('🔑 Contraseña almacenada: ${user.password}');
        
        final parts = user.password.split(':');
        if (parts.length == 2) {
          final salt = parts[0];
          final storedHash = parts[1];
          
          print('🧂 Salt: $salt');
          print('🔐 Hash almacenado: $storedHash');
          
          final isPasswordValid = AuthUtils.verifyPassword(password, storedHash, salt);
          print('🔍 Validando contraseña. ¿Válida? $isPasswordValid');
          
          if (isPasswordValid) {
            print('✅ Autenticación exitosa para el usuario: $username');
            return user;
          } else {
            print('❌ Contraseña incorrecta para el usuario: $username');
          }
        } else {
          print('❌ Formato de contraseña inválido');
        }
      } else {
        print('❌ Usuario no encontrado: $username');
      }
      
      return null;
    } catch (e) {
      print('❌ Error durante la autenticación: $e');
      return null;
    }
  }
  
  // Get all users (only for admin/supervisor)
  Future<List<UserModel>> getUsers() async {
    try {
      final users = await _usersCollection;
      final usersData = await users.find().toList();
      
      return usersData
          .map((userData) => UserModel.fromMap(userData))
          .toList();
    } catch (e) {
      print('Error getting users: $e');
      return [];
    }
  }
  
  // Create new user
  Future<bool> createUser(UserModel user) async {
    try {
      final users = await _usersCollection;
      
      // Check if username already exists
      final existingUser = await users.findOne({'username': user.username});
      if (existingUser != null) {
        throw Exception('Username already exists');
      }
      
      // Hash the password
      final salt = AuthUtils.generateSalt();
      final hashedPassword = AuthUtils.hashPassword(user.password, salt);
      
      final userToCreate = user.copyWith(
        password: '$salt:$hashedPassword',
      );
      
      await users.insertOne(userToCreate.toMap());
      return true;
    } catch (e) {
      print('Error creating user: $e');
      rethrow;
    }
  }
  
  // Update user
  Future<bool> updateUser(UserModel user) async {
    try {
      final users = await _usersCollection;
      
      final updateData = user.toMap()..remove('_id');
      updateData['updatedAt'] = DateTime.now();
      
      await users.updateOne(
        where.eq('_id', user.id),
        updateData,
      );
      
      return true;
    } catch (e) {
      print('Error updating user: $e');
      rethrow;
    }
  }
  
  // Delete user
  Future<bool> deleteUser(String userId) async {
    try {
      final users = await _usersCollection;
      await users.deleteOne(where.id(ObjectId.parse(userId)));
      return true;
    } catch (e) {
      print('Error deleting user: $e');
      rethrow;
    }
  }
  
  // Change password
  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      final users = await _usersCollection;
      final userData = await users.findOne(where.id(ObjectId.parse(userId)));
      
      if (userData == null) {
        throw Exception('User not found');
      }
      
      final user = UserModel.fromMap(userData);
      final parts = user.password.split(':');
      
      if (parts.length != 2) {
        throw Exception('Invalid password format');
      }
      
      final salt = parts[0];
      final storedHash = parts[1];
      
      if (!AuthUtils.verifyPassword(currentPassword, storedHash, salt)) {
        throw Exception('Current password is incorrect');
      }
      
      // Generate new salt and hash for the new password
      final newSalt = AuthUtils.generateSalt();
      final newHashedPassword = AuthUtils.hashPassword(newPassword, newSalt);
      
      await users.updateOne(
        where.id(ObjectId.parse(userId)),
        modify
          .set('password', '$newSalt:$newHashedPassword')
          .set('updatedAt', DateTime.now()),
      );
      
      return true;
    } catch (e) {
      print('Error changing password: $e');
      rethrow;
    }
  }
  
  // Reset password (admin function)
  Future<bool> resetPassword(String userId, String newPassword) async {
    try {
      final users = await _usersCollection;
      
      // Generate new salt and hash for the new password
      final newSalt = AuthUtils.generateSalt();
      final newHashedPassword = AuthUtils.hashPassword(newPassword, newSalt);
      
      await users.updateOne(
        where.id(ObjectId.parse(userId)),
        modify
          .set('password', '$newSalt:$newHashedPassword')
          .set('updatedAt', DateTime.now()),
      );
      
      return true;
    } catch (e) {
      print('Error resetting password: $e');
      rethrow;
    }
  }
}
