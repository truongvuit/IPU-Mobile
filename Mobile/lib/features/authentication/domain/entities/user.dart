import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? username;
  final String? fullName;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final bool isActive;
  final DateTime? createdAt;

  const User({
    required this.id,
    required this.email,
    this.username,
    this.fullName,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.isActive = true,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    email,
    username,
    fullName,
    phoneNumber,
    avatarUrl,
    role,
    isActive,
    createdAt,
  ];

  User copyWith({
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
    return User(
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
