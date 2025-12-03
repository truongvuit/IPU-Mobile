class RevenueStatistics {
  final double totalRevenue;
  final double monthlyRevenue;
  final double growthRate;
  final Map<String, double> revenueByMonth;
  final Map<String, double> revenueByCourse;
  final Map<String, double> revenueByTeacher;
  final List<MonthlyRevenue> monthlyData;

  const RevenueStatistics({
    required this.totalRevenue,
    required this.monthlyRevenue,
    required this.growthRate,
    required this.revenueByMonth,
    required this.revenueByCourse,
    required this.revenueByTeacher,
    required this.monthlyData,
  });

  String get growthRateText {
    final sign = growthRate >= 0 ? '+' : '';
    return '$sign${growthRate.toStringAsFixed(1)}%';
  }

  bool get isGrowing => growthRate > 0;
}

class MonthlyRevenue {
  final int month;
  final int year;
  final double revenue;
  final double target;

  const MonthlyRevenue({
    required this.month,
    required this.year,
    required this.revenue,
    required this.target,
  });

  double get achievementRate => (revenue / target) * 100;

  String get monthName {
    const months = [
      'T1',
      'T2',
      'T3',
      'T4',
      'T5',
      'T6',
      'T7',
      'T8',
      'T9',
      'T10',
      'T11',
      'T12',
    ];
    return months[month - 1];
  }
}

class TeacherRevenue {
  final String teacherId;
  final String teacherName;
  final double revenue;
  final int totalClasses;
  final double percentage;

  const TeacherRevenue({
    required this.teacherId,
    required this.teacherName,
    required this.revenue,
    required this.totalClasses,
    required this.percentage,
  });
}
