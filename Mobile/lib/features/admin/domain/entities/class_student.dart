class ClassStudent {
  final String studentId;
  final String classId;
  final String fullName;
  final String phoneNumber;
  final String? avatarUrl;
  final double attendanceRate;
  final DateTime enrollmentDate;
  final int totalSessions;
  final int attendedSessions;
  final double? averageScore;
  final String? studentCode;

  const ClassStudent({
    required this.studentId,
    required this.classId,
    required this.fullName,
    required this.phoneNumber,
    this.avatarUrl,
    required this.attendanceRate,
    required this.enrollmentDate,
    required this.totalSessions,
    required this.attendedSessions,
    this.averageScore,
    this.studentCode,
  });

  String get attendanceText => '${attendanceRate.toStringAsFixed(0)}%';

  String get attendanceStatus {
    if (attendanceRate >= 90) return 'Tốt';
    if (attendanceRate >= 75) return 'Khá';
    if (attendanceRate >= 50) return 'Trung bình';
    return 'Yếu';
  }

  String get initials {
    if (fullName.isEmpty) return '?';
    final parts = fullName.split(' ');
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  factory ClassStudent.fromJson(Map<String, dynamic> json) {
    return ClassStudent(
      studentId: json['studentId'] ?? '',
      classId: json['classId'] ?? '',
      fullName: json['fullName'] ?? '',
      phoneNumber: json['phoneNumber'] ?? '',
      avatarUrl: json['avatarUrl'],
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
      enrollmentDate: json['enrollmentDate'] != null
          ? DateTime.parse(json['enrollmentDate'])
          : DateTime.now(),
      totalSessions: json['totalSessions'] ?? 0,
      attendedSessions: json['attendedSessions'] ?? 0,
      averageScore: (json['averageScore'] as num?)?.toDouble(),
      studentCode: json['studentCode'] ?? json['maHocVien'],
    );
  }

  String get displayCode => studentCode ?? 'HV${studentId.padLeft(3, '0')}';
}
