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
      moduleId: map['moduleId'],
      name: map['name'],
      description: map['description'] ?? '',
      allowedRoles: List<String>.from(map['allowedRoles'] ?? []),
      isActive: map['isActive'] ?? true,
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : DateTime.now(),
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
