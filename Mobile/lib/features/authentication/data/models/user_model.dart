import '../../domain/entities/user.dart';

class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.username,
    super.fullName,
    super.phoneNumber,
    super.avatarUrl,
    required super.role,
    super.isActive,
    super.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      email: json['email'] ?? '',
      username: json['username'],
      fullName: json['fullName'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'student',
      isActive: json['isActive'] ?? true,
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'username': username,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
      'isActive': isActive,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      email: user.email,
      username: user.username,
      fullName: user.fullName,
      phoneNumber: user.phoneNumber,
      avatarUrl: user.avatarUrl,
      role: user.role,
      isActive: user.isActive,
      createdAt: user.createdAt,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? username,
    String? fullName,
    String? phoneNumber,
    String? avatarUrl,
    String? role,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      username: username ?? this.username,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
