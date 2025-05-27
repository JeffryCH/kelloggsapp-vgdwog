import '../models/user_model.dart';
import '../repositories/user_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  final UserRepository _userRepository = UserRepository();
  final _storage = const FlutterSecureStorage();
  
  static const String _userKey = 'current_user';
  static const String _tokenKey = 'auth_token';
  
  UserModel? _currentUser;
  String? _authToken;
  
  bool get isAuthenticated => _currentUser != null;
  UserModel? get currentUser => _currentUser;
  String? get authToken => _authToken;
  
  factory AuthService() => _instance;
  
  AuthService._internal();
  
  // Initialize authentication service
  Future<void> initialize() async {
    await _loadCurrentUser();
  }
  
  // Load current user from secure storage
  Future<void> _loadCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userData = prefs.getString(_userKey);
      
      if (userData != null) {
        _authToken = await _storage.read(key: _tokenKey);
        _currentUser = UserModel.fromMap(Map<String, dynamic>.from(userData as Map));
      }
    } catch (e) {
      print('Error loading user from storage: $e');
      await logout();
    }
  }
  
  // Login user
  Future<UserModel> login(String username, String password) async {
    try {
      final user = await _userRepository.authenticate(username, password);
      
      if (user == null) {
        throw Exception('Invalid username or password');
      }
      
      // Generate a simple token (in a real app, this would come from your auth server)
      final token = '${DateTime.now().millisecondsSinceEpoch}_${user.id}';
      
      // Save user session
      await _saveUserSession(user, token);
      
      return user;
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }
  
  // Save user session
  Future<void> _saveUserSession(UserModel user, String token) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save user data to shared preferences
      await prefs.setString(_userKey, user.toMap().toString());
      
      // Save token to secure storage
      await _storage.write(key: _tokenKey, value: token);
      
      // Update current user
      _currentUser = user;
      _authToken = token;
      
    } catch (e) {
      print('Error saving user session: $e');
      rethrow;
    }
  }
  
  // Logout user
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear user data
      await prefs.remove(_userKey);
      await _storage.delete(key: _tokenKey);
      
      // Clear current user
      _currentUser = null;
      _authToken = null;
      
    } catch (e) {
      print('Error during logout: $e');
      rethrow;
    }
  }
  
  // Check if user has required role
  bool hasRole(String role) {
    return _currentUser?.roles.contains(role) ?? false;
  }
  
  // Check if user has any of the required roles
  bool hasAnyRole(List<String> roles) {
    if (_currentUser == null) return false;
    return _currentUser!.roles.any((role) => roles.contains(role));
  }
  
  // Check if user is admin
  bool get isAdmin => hasRole(UserRoles.admin);
  
  // Check if user is supervisor or admin
  bool get isSupervisorOrAdmin => hasAnyRole([UserRoles.admin, UserRoles.supervisor]);
}
