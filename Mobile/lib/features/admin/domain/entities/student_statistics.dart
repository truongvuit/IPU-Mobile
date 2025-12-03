class StudentStatistics {
  final int totalStudents;
  final int newStudents;
  final double completionRate;
  final double conversionRate;
  final Map<String, int> studentsByRegion;
  final Map<String, int> studentsBySource;
  final List<TopStudent> topStudents;
  final List<PotentialStudent> potentialStudents;

  const StudentStatistics({
    required this.totalStudents,
    required this.newStudents,
    required this.completionRate,
    required this.conversionRate,
    required this.studentsByRegion,
    required this.studentsBySource,
    required this.topStudents,
    required this.potentialStudents,
  });

  String get completionRateText => '${completionRate.toStringAsFixed(0)}%';
  String get conversionRateText => '${conversionRate.toStringAsFixed(0)}%';
}

class TopStudent {
  final String studentId;
  final String studentName;
  final String? avatarUrl;
  final double averageScore;
  final int coursesCompleted;
  final double attendanceRate;

  const TopStudent({
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    required this.averageScore,
    required this.coursesCompleted,
    required this.attendanceRate,
  });

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}

class PotentialStudent {
  final String studentId;
  final String studentName;
  final String? avatarUrl;
  final String phoneNumber;
  final String status;
  final DateTime? lastContact;

  const PotentialStudent({
    required this.studentId,
    required this.studentName,
    this.avatarUrl,
    required this.phoneNumber,
    required this.status,
    this.lastContact,
  });

  String get initials {
    final parts = studentName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }
}
