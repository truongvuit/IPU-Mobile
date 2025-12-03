import '../../domain/entities/admin_profile.dart';

class AdminProfileModel extends AdminProfile {
  const AdminProfileModel({
    required super.id,
    required super.fullName,
    required super.email,
    super.phoneNumber,
    super.avatarUrl,
    required super.role,
    super.createdAt,
  });

  factory AdminProfileModel.fromJson(Map<String, dynamic> json) {
    return AdminProfileModel(
      id: json['id']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? json['hoten'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? json['sdt'] as String?,
      avatarUrl: json['avatarUrl'] as String? ?? json['anhdaidien'] as String?,
      role: json['role'] as String? ?? json['vaitro'] as String? ?? 'admin',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String)
          : (json['ngaytao'] != null
                ? DateTime.tryParse(json['ngaytao'] as String)
                : null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'role': role,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  factory AdminProfileModel.fromEntity(AdminProfile entity) {
    return AdminProfileModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      role: entity.role,
      createdAt: entity.createdAt,
    );
  }

  AdminProfile toEntity() {
    return AdminProfile(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      role: role,
      createdAt: createdAt,
    );
  }
}
