import 'package:flutter/foundation.dart' show kDebugMode;

class DatabaseConstants {
  // MongoDB connection string
  static String get connectionString => kDebugMode 
      ? 'http://localhost:3001/api/Kelloggs' // Local CORS proxy in development
      : 'mongodb+srv://DEMO:waGmbodhen6ir19a@kelloggs.8myax.mongodb.net/Kelloggs?retryWrites=true&w=majority&appName=Kelloggs';
  
  // Database name
  static const String dbName = 'Kelloggs';
  
  // Collections
  static const String usersCollection = 'users';
  static const String storesCollection = 'stores';
  static const String productsCollection = 'products';
  static const String routesCollection = 'routes';
  static const String visitsCollection = 'visits';
  static const String reportsCollection = 'reports';
  static const String modulePermissionsCollection = 'module_permissions';
  
  // Timeout durations
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration socketTimeout = Duration(seconds: 30);
}
