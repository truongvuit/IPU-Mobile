import 'package:equatable/equatable.dart';

import '../../domain/entities/revenue_statistics.dart';
import '../../domain/entities/student_statistics.dart';
import '../../domain/entities/teacher_statistics.dart';
import '../../domain/entities/classroom_statistics.dart';
import '../../domain/entities/course_statistics.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object?> get props => [];
}

class StatisticsInitial extends StatisticsState {
  const StatisticsInitial();
}

class StatisticsLoading extends StatisticsState {
  const StatisticsLoading();
}

class StatisticsError extends StatisticsState {
  final String message;

  const StatisticsError(this.message);

  @override
  List<Object?> get props => [message];
}

class RevenueStatisticsLoaded extends StatisticsState {
  final RevenueStatistics statistics;
  final int? selectedMonth;
  final int? selectedYear;

  const RevenueStatisticsLoaded({
    required this.statistics,
    this.selectedMonth,
    this.selectedYear,
  });

  @override
  List<Object?> get props => [statistics, selectedMonth, selectedYear];
}

class RevenueReportExporting extends StatisticsState {
  const RevenueReportExporting();
}

class RevenueReportExported extends StatisticsState {
  final String filePath;
  final String format;

  const RevenueReportExported({required this.filePath, required this.format});

  @override
  List<Object?> get props => [filePath, format];
}

class StudentStatisticsLoaded extends StatisticsState {
  final StudentStatistics statistics;

  const StudentStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class StudentReportExporting extends StatisticsState {
  const StudentReportExporting();
}

class StudentReportExported extends StatisticsState {
  final String filePath;
  final String format;

  const StudentReportExported({required this.filePath, required this.format});

  @override
  List<Object?> get props => [filePath, format];
}

class TeacherStatisticsLoaded extends StatisticsState {
  final TeacherStatistics statistics;

  const TeacherStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class TeacherReportExporting extends StatisticsState {
  const TeacherReportExporting();
}

class TeacherReportExported extends StatisticsState {
  final String filePath;
  final String format;

  const TeacherReportExported({required this.filePath, required this.format});

  @override
  List<Object?> get props => [filePath, format];
}

class ClassroomStatisticsLoaded extends StatisticsState {
  final ClassroomStatistics statistics;

  const ClassroomStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}

class ClassroomReportExporting extends StatisticsState {
  const ClassroomReportExporting();
}

class ClassroomReportExported extends StatisticsState {
  final String filePath;
  final String format;

  const ClassroomReportExported({required this.filePath, required this.format});

  @override
  List<Object?> get props => [filePath, format];
}

class CourseStatisticsLoaded extends StatisticsState {
  final CourseStatistics statistics;

  const CourseStatisticsLoaded(this.statistics);

  @override
  List<Object?> get props => [statistics];
}
