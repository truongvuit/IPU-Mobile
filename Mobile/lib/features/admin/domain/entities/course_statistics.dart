import 'package:equatable/equatable.dart';

class CourseStatistics extends Equatable {
  final int totalCourses;
  final int activeCourses;
  final List<PopularCourse> popularCourses;
  final List<CourseEnrollmentTrend> enrollmentTrend;

  const CourseStatistics({
    required this.totalCourses,
    required this.activeCourses,
    required this.popularCourses,
    required this.enrollmentTrend,
  });

  @override
  List<Object?> get props => [
    totalCourses,
    activeCourses,
    popularCourses,
    enrollmentTrend,
  ];
}

class PopularCourse extends Equatable {
  final String courseId;
  final String courseName;
  final int totalStudents;
  final double averageRating;
  final int totalClasses;

  const PopularCourse({
    required this.courseId,
    required this.courseName,
    required this.totalStudents,
    required this.averageRating,
    required this.totalClasses,
  });

  @override
  List<Object?> get props => [
    courseId,
    courseName,
    totalStudents,
    averageRating,
    totalClasses,
  ];
}

class CourseEnrollmentTrend extends Equatable {
  final String month;
  final int enrollments;

  const CourseEnrollmentTrend({required this.month, required this.enrollments});

  @override
  List<Object?> get props => [month, enrollments];
}
