import 'package:mongo_dart/mongo_dart.dart';

class UserModel {
  final ObjectId? id;
  final String username;  // This will be the cédula for regular users, 'admin' for admin
  final String password;  // Hashed password
  final String fullName;
  final String email;
  final List<String> roles;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final bool isActive;

  UserModel({
    this.id,
    required this.username,
    required this.password,
    required this.fullName,
    required this.email,
    required this.roles,
    DateTime? createdAt,
    this.updatedAt,
    this.isActive = true,
  }) : createdAt = createdAt ?? DateTime.now();

  // Convert UserModel to Map
  Map<String, dynamic> toMap() {
    return {
      if (id != null) '_id': id,
      'username': username,
      'password': password,
      'fullName': fullName,
      'email': email,
      'roles': roles,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'isActive': isActive,
    };
  }

  // Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['_id'],
      username: map['username'] ?? '',
      password: map['password'] ?? '',
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      roles: List<String>.from(map['roles'] ?? []),
      createdAt: map['createdAt']?.toDate(),
      updatedAt: map['updatedAt']?.toDate(),
      isActive: map['isActive'] ?? true,
    );
  }

  // Create a copy of the user with updated fields
  UserModel copyWith({
    String? username,
    String? password,
    String? fullName,
    String? email,
    List<String>? roles,
    bool? isActive,
  }) {
    return UserModel(
      id: id,
      username: username ?? this.username,
      password: password ?? this.password,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      roles: roles ?? this.roles,
      createdAt: createdAt,
      isActive: isActive ?? this.isActive,
    );
  }
}

// User roles
class UserRoles {
  static const String admin = 'Admin';
  static const String supervisor = 'Supervisor';
  static const String mercaderista = 'Mercaderista';
  static const String certificador = 'Certificador';

  static const List<String> allRoles = [
    admin,
    supervisor,
    mercaderista,
    certificador,
  ];
}
