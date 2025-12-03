import '../../domain/entities/admin_dashboard_stats.dart';

class AdminDashboardStatsModel extends AdminDashboardStats {
  const AdminDashboardStatsModel({
    required super.ongoingClasses,
    required super.todayRegistrations,
    required super.activeStudents,
    required super.monthlyRevenue,
    super.totalTeachers,
    super.totalCourses,
  });

  factory AdminDashboardStatsModel.fromJson(Map<String, dynamic> json) {
    return AdminDashboardStatsModel(
      ongoingClasses:
          json['so_lop_dangday'] as int? ??
          json['lopDangDay'] as int? ??
          json['ongoingClasses'] as int? ??
          0,

      todayRegistrations:
          json['dang_ky_hom_nay'] as int? ??
          json['dangKyHomNay'] as int? ??
          json['todayRegistrations'] as int? ??
          0,

      activeStudents:
          json['tong_hocvien'] as int? ??
          json['tongHocVien'] as int? ??
          json['activeStudents'] as int? ??
          0,

      monthlyRevenue:
          (json['doanhthu_thang'] ??
                  json['doanhThuThang'] ??
                  json['monthlyRevenue'] ??
                  0.0)
              .toDouble(),

      totalTeachers:
          json['tong_giangvien'] as int? ??
          json['tongGiangVien'] as int? ??
          json['totalTeachers'] as int?,

      totalCourses:
          json['tong_khoahoc'] as int? ??
          json['tongKhoaHoc'] as int? ??
          json['totalCourses'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'ongoingClasses': ongoingClasses,
      'todayRegistrations': todayRegistrations,
      'activeStudents': activeStudents,
      'monthlyRevenue': monthlyRevenue,
      'totalTeachers': totalTeachers,
      'totalCourses': totalCourses,
    };
  }

  factory AdminDashboardStatsModel.fromEntity(AdminDashboardStats entity) {
    return AdminDashboardStatsModel(
      ongoingClasses: entity.ongoingClasses,
      todayRegistrations: entity.todayRegistrations,
      activeStudents: entity.activeStudents,
      monthlyRevenue: entity.monthlyRevenue,
      totalTeachers: entity.totalTeachers,
      totalCourses: entity.totalCourses,
    );
  }

  AdminDashboardStats toEntity() {
    return AdminDashboardStats(
      ongoingClasses: ongoingClasses,
      todayRegistrations: todayRegistrations,
      activeStudents: activeStudents,
      monthlyRevenue: monthlyRevenue,
      totalTeachers: totalTeachers,
      totalCourses: totalCourses,
    );
  }
}
