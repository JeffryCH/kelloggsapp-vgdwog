import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:logging/logging.dart';
import 'package:mongo_dart/mongo_dart.dart';

import '../repositories/module_permission_repository.dart';
import '../repositories/user_repository.dart';
import 'constants.dart';

class MongoDB {
  // Singleton instance
  static final MongoDB _instance = MongoDB._internal();
  static Db? _db;
  static bool _isConnected = false;
  static final _logger = Logger('MongoDB');
  static Timer? _connectionCheckTimer;

  // Factory constructor to return the same instance
  factory MongoDB() => _instance;

  // Private constructor
  MongoDB._internal() {
    // Initialize logging
    Logger.root.level = Level.ALL;
    Logger.root.onRecord.listen((record) {
      print('${record.level.name}: ${record.time}: ${record.message}');
    });
  }

  // Getters
  static Db? get db => _db;
  static bool get isConnected => _isConnected;

  /// Initialize MongoDB connection
  static Future<void> init() async {
    if (_isConnected) {
      _logger.fine('MongoDB is already connected');
      return;
    }
    
    _logger.info('🔌 Initializing MongoDB connection...');
    
    try {
      final connectionString = DatabaseConstants.connectionString;
      _logger.fine('Using connection string: $connectionString');
      
      // Parse the connection string
      final uri = Uri.parse(connectionString);
      
      // Create database instance if it doesn't exist
      _db ??= Db(uri.toString());
      
      // Try to connect with retry logic
      await _connectWithRetry();
      
      // Verify connection by pinging the server
      await _pingServer();
      
      // Ensure all required collections exist
      await _ensureCollectionsExist();
      
      // Start connection health check
      _startConnectionHealthCheck();
      
      _isConnected = true;
      _logger.info('✅ MongoDB connected successfully to ${uri.host}');
      
    } catch (e, stackTrace) {
      _isConnected = false;
      _logger.severe('❌ Failed to initialize MongoDB', e, stackTrace);
      
      // For web, we'll continue in offline mode
      if (kIsWeb) {
        _logger.warning('⚠️ Running in limited offline mode for web');
      } else {
        await close();
        rethrow;
      }
    }
    
    // Ensure we have a valid connection or throw an exception
    if (!_isConnected && !kIsWeb) {
      throw Exception('Failed to connect to MongoDB and not running in web mode');
    }
  }
  
  /// Connect to MongoDB with retry logic
  static Future<void> _connectWithRetry() async {
    const maxRetries = 3;
    const initialDelay = Duration(seconds: 2);
    
    for (var i = 0; i < maxRetries; i++) {
      try {
        _logger.fine('Connection attempt ${i + 1}/$maxRetries');
        await _db!.open(secure: true);
        return; // Success
      } catch (e) {
        _logger.warning('Connection attempt ${i + 1} failed: $e');
        if (i == maxRetries - 1) rethrow; // Last attempt
        await Future.delayed(initialDelay * (i + 1));
      }
    }
  }

  /// Ping the MongoDB server to verify connection
  static Future<void> _pingServer() async {
    if (_db == null) throw Exception('Database not initialized');
    
    try {
      _logger.fine('Pinging MongoDB server...');
      final result = await _db!.runCommand({'ping': 1}).timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException('Ping timed out after 5 seconds'),
      );
      
      if (result['ok'] != 1.0) {
        throw Exception('Ping command failed: ${result.toString()}');
      }
      
      _logger.fine('✅ MongoDB server is responding');
    } on TimeoutException catch (e) {
      _logger.warning('MongoDB ping timed out: $e');
      rethrow;
    } on MongoDartError catch (e) {
      _logger.severe('MongoDB error during ping: $e');
      rethrow;
    } catch (e) {
      _logger.severe('Unexpected error during ping: $e');
      rethrow;
    }
  }
  
  /// Start a periodic health check for the MongoDB connection
  static void _startConnectionHealthCheck() {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = Timer.periodic(
      const Duration(seconds: 30),
      (timer) async {
        if (_db == null || !_isConnected) return;
        
        try {
          _logger.fine('Checking MongoDB connection health...');
          await _pingServer();
          
          if (!_isConnected) {
            _isConnected = true;
            _logger.info('✅ MongoDB reconnected successfully');
          }
        } catch (e) {
          _isConnected = false;
          _logger.warning('MongoDB connection health check failed: $e');
          await _reconnect();
        }
      },
    );
  }
  
  /// Attempt to reconnect to MongoDB
  static Future<void> _reconnect() async {
    try {
      _logger.info('Attempting to reconnect to MongoDB...');
      await close();
      await init();
    } catch (e) {
      _logger.severe('Failed to reconnect to MongoDB: $e');
    }
  }

  /// Close the database connection
  static Future<void> close() async {
    _connectionCheckTimer?.cancel();
    _connectionCheckTimer = null;
    
    if (_db != null) {
      try {
        await _db!.close();
        _logger.info('MongoDB connection closed');
      } catch (e) {
        _logger.severe('Error closing MongoDB connection: $e');
        rethrow;
      } finally {
        _db = null;
        _isConnected = false;
      }
    }
  }
  
  /// Ensure all required collections exist with proper indexes
  static Future<void> _ensureCollectionsExist() async {
    if (_db == null) return;
    
    try {
      _logger.info('🔍 Ensuring all collections exist...');
      
      // Get list of existing collections
      final existingCollections = await _db!.getCollectionNames();
      _logger.fine('Existing collections: $existingCollections');
      
      // List of required collections
      final requiredCollections = [
        DatabaseConstants.usersCollection,
        DatabaseConstants.modulePermissionsCollection,
        DatabaseConstants.storesCollection,
        DatabaseConstants.productsCollection,
        DatabaseConstants.routesCollection,
        DatabaseConstants.visitsCollection,
        DatabaseConstants.reportsCollection,
      ];
      
      // Create missing collections
      for (final collection in requiredCollections) {
        if (!existingCollections.contains(collection)) {
          _logger.info('Creating $collection collection...');
          await _db!.createCollection(collection);
        }
      }
      
      // Create indexes for users collection
      final users = _db!.collection(DatabaseConstants.usersCollection);
      await users.createIndex(keys: {'email': 1}, unique: true);
      
      // Create indexes for other collections as needed
      final permissions = _db!.collection(DatabaseConstants.modulePermissionsCollection);
      await permissions.createIndex(keys: {'moduleId': 1}, unique: true);
      
      _logger.info('✅ All collections and indexes verified');
      
      // Initialize repositories
      await UserRepository.ensureCollection();
      await ModulePermissionRepository.ensureCollection();
      
    } catch (e, stackTrace) {
      _logger.severe('❌ Error ensuring collections exist', e, stackTrace);
      rethrow;
    }
  }
  
  /// Check if the database is connected
  static Future<bool> checkConnection() async {
    if (_db == null || !_isConnected) {
      return false;
    }

    try {
      await _db!.runCommand({'ping': 1});
      _isConnected = true;
      return true;
    } catch (e) {
      _isConnected = false;
      _logger.warning('❌ Connection check failed: $e');
      return false;
    }
  }
}
