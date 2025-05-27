import 'package:mongo_dart/mongo_dart.dart' show Db, where;
import '../dbHelper/mongodb.dart';
import '../dbHelper/constants.dart';

class ModulePermission {
  final String moduleId;
  final String name;
  final String description;
  final List<String> allowedRoles;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  ModulePermission({
    required this.moduleId,
    required this.name,
    required this.description,
    required this.allowedRoles,
    this.isActive = true,
    DateTime? createdAt,
    DateTime? updatedAt,
  })  : createdAt = createdAt ?? DateTime.now(),
        updatedAt = updatedAt ?? DateTime.now();

  factory ModulePermission.fromMap(Map<String, dynamic> map) {
    return ModulePermission(
      moduleId: map['moduleId'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      allowedRoles: List<String>.from(map['allowedRoles'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] is DateTime ? map['createdAt'] : DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: map['updatedAt'] is DateTime ? map['updatedAt'] : DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'moduleId': moduleId,
      'name': name,
      'description': description,
      'allowedRoles': allowedRoles,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  ModulePermission copyWith({
    String? moduleId,
    String? name,
    String? description,
    List<String>? allowedRoles,
    bool? isActive,
  }) {
    return ModulePermission(
      moduleId: moduleId ?? this.moduleId,
      name: name ?? this.name,
      description: description ?? this.description,
      allowedRoles: allowedRoles ?? this.allowedRoles,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class ModulePermissionRepository {
  static final String _collectionName = DatabaseConstants.modulePermissionsCollection;

  // Ensure the collection exists and has necessary indexes
  static Future<void> ensureCollection() async {
    final db = await MongoDB.db;
    if (db == null) throw Exception('Database not initialized');
    
    await _ensureCollectionExists(db);
    await _createIndex(db);
    // Initialize with default modules if collection is empty
    await _initializeDefaultModules();
  }

  static Future<void> _ensureCollectionExists(Db db) async {
    try {
      await db.createCollection(_collectionName);
    } catch (e) {
      // Collection already exists, continue
    }
  }
  
  static Future<void> _createIndex(Db db) async {
    final collection = db.collection(_collectionName);
    await collection.createIndex(keys: {'moduleId': 1}, unique: true);
  }

  static Future<void> _initializeDefaultModules() async {
    final defaultModules = [
      ModulePermission(
        moduleId: 'dashboard',
        name: 'Dashboard',
        description: 'Panel principal',
        allowedRoles: ['admin', 'supervisor', 'usuario'],
      ),
      ModulePermission(
        moduleId: 'inventario',
        name: 'Inventario',
        description: 'Gestión de inventario',
        allowedRoles: ['admin', 'supervisor'],
      ),
      ModulePermission(
        moduleId: 'configuraciones',
        name: 'Configuraciones',
        description: 'Configuración del sistema',
        allowedRoles: ['admin', 'supervisor'],
      ),
      // Add more default modules as needed
    ];

    for (var module in defaultModules) {
      await createOrUpdate(module);
    }
  }

  static Future<ModulePermission> createOrUpdate(ModulePermission module) async {
    final db = await MongoDB.db;
    if (db == null) throw Exception('Database not initialized');
    
    final collection = db.collection(_collectionName);
    
    await collection.updateOne(
      where.eq('moduleId', module.moduleId),
      {
        r'$set': module.toMap()..remove('_id'),
        r'$setOnInsert': {'createdAt': DateTime.now().toIso8601String()},
      },
      upsert: true,
    );
    
    return module;
  }

  static Future<List<ModulePermission>> getAll() async {
    await ensureCollection();
    final db = await MongoDB.db;
    if (db == null) throw Exception('Database not initialized');
    
    final collection = db.collection(_collectionName);
    final modules = await collection.find().toList();
    
    return modules
        .map((e) => ModulePermission.fromMap(e))
        .toList();
  }

  static Future<ModulePermission?> getById(String moduleId) async {
    final db = await MongoDB.db;
    if (db == null) throw Exception('Database not initialized');
    
    final collection = db.collection(_collectionName);
    final module = await collection.findOne(where.eq('moduleId', moduleId));
    return module != null ? ModulePermission.fromMap(module) : null;
  }

  static Future<bool> hasAccess(String moduleId, String role) async {
    if (role == 'admin') return true; // Admin has access to everything
    
    final module = await getById(moduleId);
    if (module == null || !module.isActive) return false;
    
    return module.allowedRoles.contains(role);
  }

  static Future<List<ModulePermission>> getModulesForRole(String role) async {
    if (role == 'admin') return await getAll();
    
    final allModules = await getAll();
    return allModules
        .where((module) => module.allowedRoles.contains(role) && module.isActive)
        .toList();
  }

  static Future<void> updateModulePermissions(
    String moduleId, 
    List<String> allowedRoles,
  ) async {
    final db = await MongoDB.db;
    if (db == null) throw Exception('Database not initialized');
    
    final collection = db.collection(_collectionName);
    
    await collection.updateOne(
      where.eq('moduleId', moduleId),
      {
        r'$set': {
          'allowedRoles': allowedRoles,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      },
    );
  }
}
