class AdminProfile {
  final String id;
  final String fullName;
  final String email;
  final String? phoneNumber;
  final String? avatarUrl;
  final String role;
  final DateTime? createdAt;

  const AdminProfile({
    required this.id,
    required this.fullName,
    required this.email,
    this.phoneNumber,
    this.avatarUrl,
    required this.role,
    this.createdAt,
  });

  static const empty = AdminProfile(
    id: '',
    fullName: '',
    email: '',
    role: 'admin',
  );

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => !isEmpty;

  String get displayName {
    if (fullName.isEmpty) return email;
    return fullName;
  }

  String get firstName {
    if (fullName.isEmpty) return '';
    return fullName.split(' ').last;
  }

  factory AdminProfile.fromJson(Map<String, dynamic> json) {
    return AdminProfile(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      role: json['role'] ?? 'admin',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : null,
    );
  }
}
