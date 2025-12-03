import 'package:equatable/equatable.dart';

abstract class StatisticsEvent extends Equatable {
  const StatisticsEvent();

  @override
  List<Object?> get props => [];
}

class LoadRevenueStatistics extends StatisticsEvent {
  final int? month;
  final int? year;

  const LoadRevenueStatistics({this.month, this.year});

  @override
  List<Object?> get props => [month, year];
}

class LoadStudentStatistics extends StatisticsEvent {
  const LoadStudentStatistics();
}

class LoadTeacherStatistics extends StatisticsEvent {
  const LoadTeacherStatistics();
}

class LoadClassroomStatistics extends StatisticsEvent {
  const LoadClassroomStatistics();
}

class LoadCourseStatistics extends StatisticsEvent {
  const LoadCourseStatistics();
}

class ExportRevenueReport extends StatisticsEvent {
  final String format;

  const ExportRevenueReport(this.format);

  @override
  List<Object?> get props => [format];
}

class ExportStudentReport extends StatisticsEvent {
  final String format;

  const ExportStudentReport(this.format);

  @override
  List<Object?> get props => [format];
}

class ExportTeacherReport extends StatisticsEvent {
  final String format;

  const ExportTeacherReport(this.format);

  @override
  List<Object?> get props => [format];
}

class ExportClassroomReport extends StatisticsEvent {
  final String format;

  const ExportClassroomReport(this.format);

  @override
  List<Object?> get props => [format];
}
