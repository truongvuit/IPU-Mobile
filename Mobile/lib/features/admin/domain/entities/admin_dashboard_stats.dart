class AdminDashboardStats {
  final int ongoingClasses;
  final int todayRegistrations;
  final int activeStudents;
  final double monthlyRevenue;
  final int? totalTeachers;
  final int? totalCourses;

  const AdminDashboardStats({
    required this.ongoingClasses,
    required this.todayRegistrations,
    required this.activeStudents,
    required this.monthlyRevenue,
    this.totalTeachers,
    this.totalCourses,
  });

  static const empty = AdminDashboardStats(
    ongoingClasses: 0,
    todayRegistrations: 0,
    activeStudents: 0,
    monthlyRevenue: 0.0,
    totalTeachers: 0,
    totalCourses: 0,
  );
  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStats(
      ongoingClasses: json['ongoingClasses'] ?? 0,
      todayRegistrations: json['todayRegistrations'] ?? 0,
      activeStudents: json['activeStudents'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      totalTeachers: json['totalTeachers'],
      totalCourses: json['totalCourses'],
    );
  }
}
