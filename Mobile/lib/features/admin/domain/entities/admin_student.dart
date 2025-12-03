class AdminStudent {
  final String id;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? address;
  final String? occupation;
  final String? educationLevel;
  final DateTime enrollmentDate;
  final int totalClassesEnrolled;
  final List<String> enrolledClassIds;

  const AdminStudent({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.avatarUrl,
    this.dateOfBirth,
    this.address,
    this.occupation,
    this.educationLevel,
    required this.enrollmentDate,
    required this.totalClassesEnrolled,
    required this.enrolledClassIds,
  });

  String get firstName {
    if (fullName.isEmpty) return '';
    return fullName.split(' ').last;
  }

  String get initials {
    if (fullName.isEmpty) return '?';
    final parts = fullName.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  factory AdminStudent.fromJson(Map<String, dynamic> json) {
    return AdminStudent(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : null,
      address: json['address'],
      occupation: json['occupation'],
      educationLevel: json['educationLevel'],
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'])
          : DateTime.now(),
      totalClassesEnrolled: json['totalClassesEnrolled'] ?? 0,
      enrolledClassIds:
          (json['enrolledClassIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }
}
