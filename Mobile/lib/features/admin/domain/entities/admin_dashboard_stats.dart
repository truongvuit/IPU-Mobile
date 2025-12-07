import 'todays_focus_item.dart';


enum TrendDirection { up, down, stable }

class AdminDashboardStats {
  final int ongoingClasses;
  final int todayRegistrations;
  final int activeStudents;
  final double monthlyRevenue;
  final int? totalTeachers;
  final int? totalCourses;

  
  final bool isFallback;

  
  final double? classesGrowth;
  final TrendDirection? classesGrowthDirection;
  final double? registrationsGrowth;
  final TrendDirection? registrationsGrowthDirection;
  final double? studentsGrowth;
  final TrendDirection? studentsGrowthDirection;
  final double? revenueGrowth;
  final TrendDirection? revenueGrowthDirection;

  
  final int pendingAttendance;
  final int pendingPayments;
  final int classConflicts;
  final int pendingApprovals;
  final List<TodaysFocusItem> todaysFocusItems;

  const AdminDashboardStats({
    required this.ongoingClasses,
    required this.todayRegistrations,
    required this.activeStudents,
    required this.monthlyRevenue,
    this.totalTeachers,
    this.totalCourses,
    this.isFallback = false,
    
    this.classesGrowth,
    this.classesGrowthDirection,
    this.registrationsGrowth,
    this.registrationsGrowthDirection,
    this.studentsGrowth,
    this.studentsGrowthDirection,
    this.revenueGrowth,
    this.revenueGrowthDirection,
    
    this.pendingAttendance = 0,
    this.pendingPayments = 0,
    this.classConflicts = 0,
    this.pendingApprovals = 0,
    this.todaysFocusItems = const [],
  });

  static const empty = AdminDashboardStats(
    ongoingClasses: 0,
    todayRegistrations: 0,
    activeStudents: 0,
    monthlyRevenue: 0.0,
    totalTeachers: 0,
    totalCourses: 0,
    isFallback: true,
  );

  
  AdminDashboardStats copyWithFallback(bool isFallback) {
    return AdminDashboardStats(
      ongoingClasses: ongoingClasses,
      todayRegistrations: todayRegistrations,
      activeStudents: activeStudents,
      monthlyRevenue: monthlyRevenue,
      totalTeachers: totalTeachers,
      totalCourses: totalCourses,
      isFallback: isFallback,
      classesGrowth: classesGrowth,
      classesGrowthDirection: classesGrowthDirection,
      registrationsGrowth: registrationsGrowth,
      registrationsGrowthDirection: registrationsGrowthDirection,
      studentsGrowth: studentsGrowth,
      studentsGrowthDirection: studentsGrowthDirection,
      revenueGrowth: revenueGrowth,
      revenueGrowthDirection: revenueGrowthDirection,
      pendingAttendance: pendingAttendance,
      pendingPayments: pendingPayments,
      classConflicts: classConflicts,
      pendingApprovals: pendingApprovals,
      todaysFocusItems: todaysFocusItems,
    );
  }

  factory AdminDashboardStats.fromJson(Map<String, dynamic> json) {
    
    List<TodaysFocusItem> focusItems = [];
    if (json['todaysFocusItems'] != null) {
      focusItems = (json['todaysFocusItems'] as List)
          .map((item) => TodaysFocusItem.fromJson(item))
          .toList();
    }

    return AdminDashboardStats(
      ongoingClasses: json['ongoingClasses'] ?? 0,
      todayRegistrations: json['todayRegistrations'] ?? 0,
      activeStudents: json['activeStudents'] ?? 0,
      monthlyRevenue: (json['monthlyRevenue'] ?? 0.0).toDouble(),
      totalTeachers: json['totalTeachers'],
      totalCourses: json['totalCourses'],
      isFallback: json['isFallback'] ?? false,
      
      classesGrowth: (json['classesGrowth'] as num?)?.toDouble(),
      classesGrowthDirection: _parseDirection(json['classesGrowthDirection']),
      registrationsGrowth: (json['registrationsGrowth'] as num?)?.toDouble(),
      registrationsGrowthDirection: _parseDirection(
        json['registrationsGrowthDirection'],
      ),
      studentsGrowth: (json['studentsGrowth'] as num?)?.toDouble(),
      studentsGrowthDirection: _parseDirection(json['studentsGrowthDirection']),
      revenueGrowth: (json['revenueGrowth'] as num?)?.toDouble(),
      revenueGrowthDirection: _parseDirection(json['revenueGrowthDirection']),
      
      pendingAttendance: json['pendingAttendance'] ?? 0,
      pendingPayments: json['pendingPayments'] ?? 0,
      classConflicts: json['classConflicts'] ?? 0,
      pendingApprovals: json['pendingApprovals'] ?? 0,
      todaysFocusItems: focusItems,
    );
  }

  static TrendDirection? _parseDirection(String? direction) {
    switch (direction?.toLowerCase()) {
      case 'up':
        return TrendDirection.up;
      case 'down':
        return TrendDirection.down;
      case 'stable':
        return TrendDirection.stable;
      default:
        return null;
    }
  }

  
  
  List<TodaysFocusItem> generateFocusItems() {
    if (todaysFocusItems.isNotEmpty) return todaysFocusItems;

    final items = <TodaysFocusItem>[];

    if (pendingAttendance > 0) {
      items.add(
        TodaysFocusItem(
          id: 'attendance',
          title: 'Điểm danh chờ duyệt',
          description: '$pendingAttendance lớp cần xác nhận điểm danh',
          count: pendingAttendance,
          type: FocusItemType.attendance,
          priority: FocusItemPriority.high,
          route: null, 
        ),
      );
    }

    if (pendingPayments > 0) {
      items.add(
        TodaysFocusItem(
          id: 'payments',
          title: 'Thanh toán cần xác minh',
          description: '$pendingPayments giao dịch chờ xác nhận',
          count: pendingPayments,
          type: FocusItemType.payment,
          priority: FocusItemPriority.urgent,
          route: null, 
        ),
      );
    }

    if (classConflicts > 0) {
      items.add(
        TodaysFocusItem(
          id: 'conflicts',
          title: 'Xung đột lịch học',
          description: '$classConflicts lớp có xung đột thời gian',
          count: classConflicts,
          type: FocusItemType.conflict,
          priority: FocusItemPriority.urgent,
          route: '/admin/classes', 
        ),
      );
    }

    if (pendingApprovals > 0) {
      items.add(
        TodaysFocusItem(
          id: 'approvals',
          title: 'Chờ phê duyệt',
          description: '$pendingApprovals yêu cầu cần xử lý',
          count: pendingApprovals,
          type: FocusItemType.approval,
          priority: FocusItemPriority.normal,
          route: null, 
        ),
      );
    }

    return items;
  }
}
