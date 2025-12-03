class TeacherStatistics {
  final int totalTeachers;
  final Map<String, int> teachersByDepartment;
  final Map<String, int> teachersBySpecialization;
  final List<TopTeacher> topTeachers;
  final double averageRating;
  final double attendanceRate;

  const TeacherStatistics({
    required this.totalTeachers,
    required this.teachersByDepartment,
    required this.teachersBySpecialization,
    required this.topTeachers,
    required this.averageRating,
    required this.attendanceRate,
  });

  String get averageRatingText => averageRating.toStringAsFixed(1);
  String get attendanceRateText => '${attendanceRate.toStringAsFixed(0)}%';
}

class TopTeacher {
  final String teacherId;
  final String teacherName;
  final String? avatarUrl;
  final double rating;
  final int totalClasses;
  final int totalStudents;
  final double attendanceRate;
  final String specialization;

  const TopTeacher({
    required this.teacherId,
    required this.teacherName,
    this.avatarUrl,
    required this.rating,
    required this.totalClasses,
    required this.totalStudents,
    required this.attendanceRate,
    required this.specialization,
  });

  String get initials {
    final parts = teacherName.trim().split(' ');
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return (parts[0][0] + parts[parts.length - 1][0]).toUpperCase();
  }

  String get ratingText => rating.toStringAsFixed(1);
  String get attendanceText => '${attendanceRate.toStringAsFixed(0)}%';
}

class TeacherPerformance {
  final String teacherId;
  final String teacherName;
  final int totalClasses;
  final double completionRate;
  final double studentSatisfaction;
  final int totalRevenue;

  const TeacherPerformance({
    required this.teacherId,
    required this.teacherName,
    required this.totalClasses,
    required this.completionRate,
    required this.studentSatisfaction,
    required this.totalRevenue,
  });
}
