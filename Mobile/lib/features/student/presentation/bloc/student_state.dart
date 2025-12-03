import 'package:equatable/equatable.dart';
import '../../domain/entities/course.dart';
import '../../domain/entities/student_class.dart';
import '../../domain/entities/schedule.dart';
import '../../domain/entities/grade.dart';
import '../../domain/entities/review.dart';
import '../../domain/entities/student_profile.dart';


abstract class StudentState extends Equatable {
  const StudentState();

  @override
  List<Object?> get props => [];
}


class StudentInitial extends StudentState {
  const StudentInitial();
}


class StudentLoading extends StudentState {
  final String? action;

  const StudentLoading({this.action});

  @override
  List<Object?> get props => [action];
}


class StudentLoaded extends StudentState {
  final StudentProfile? profile;
  final List<StudentClass>? classes;
  final List<Course>? courses;
  final List<Schedule>? schedules;
  final List<Grade>? grades;

  const StudentLoaded({
    this.profile,
    this.classes,
    this.courses,
    this.schedules,
    this.grades,
  });

  @override
  List<Object?> get props => [profile, classes, courses, schedules, grades];

  StudentLoaded copyWith({
    StudentProfile? profile,
    List<StudentClass>? classes,
    List<Course>? courses,
    List<Schedule>? schedules,
    List<Grade>? grades,
  }) {
    return StudentLoaded(
      profile: profile ?? this.profile,
      classes: classes ?? this.classes,
      courses: courses ?? this.courses,
      schedules: schedules ?? this.schedules,
      grades: grades ?? this.grades,
    );
  }
}


class DashboardLoaded extends StudentState {
  final List<StudentClass> upcomingClasses;
  final StudentProfile? profile;

  const DashboardLoaded({
    required this.upcomingClasses,
    this.profile,
  });

  @override
  List<Object?> get props => [upcomingClasses, profile];
}


class CoursesLoaded extends StudentState {
  final List<Course> courses;

  const CoursesLoaded(this.courses);

  @override
  List<Object?> get props => [courses];
}

class CourseDetailLoaded extends StudentState {
  final Course course;

  const CourseDetailLoaded(this.course);

  @override
  List<Object?> get props => [course];
}


class ClassesLoaded extends StudentState {
  final List<StudentClass> classes;

  const ClassesLoaded(this.classes);

  @override
  List<Object?> get props => [classes];
}

class ClassDetailLoaded extends StudentState {
  final StudentClass studentClass;

  const ClassDetailLoaded(this.studentClass);

  @override
  List<Object?> get props => [studentClass];
}


class ScheduleLoaded extends StudentState {
  final List<Schedule> schedules;
  final DateTime selectedDate;

  const ScheduleLoaded({
    required this.schedules,
    required this.selectedDate,
  });

  @override
  List<Object?> get props => [schedules, selectedDate];
}

class WeekScheduleLoaded extends StudentState {
  final List<Schedule> schedules;
  final DateTime startDate;

  const WeekScheduleLoaded({
    required this.schedules,
    required this.startDate,
  });

  @override
  List<Object?> get props => [schedules, startDate];
}


class GradesLoaded extends StudentState {
  final List<Grade> grades;

  const GradesLoaded(this.grades);

  @override
  List<Object?> get props => [grades];
}

class CourseGradesLoaded extends StudentState {
  final List<Grade> grades;
  final String courseId;

  const CourseGradesLoaded({
    required this.grades,
    required this.courseId,
  });

  @override
  List<Object?> get props => [grades, courseId];
}


class ProfileLoaded extends StudentState {
  final StudentProfile profile;

  const ProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class ProfileUpdated extends StudentState {
  final StudentProfile profile;

  const ProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}

class CourseEnrolled extends StudentState {
  const CourseEnrolled();
}

class RatingSubmitted extends StudentState {
  const RatingSubmitted();
}

class ReviewHistoryLoaded extends StudentState {
  final List<Review> reviews;

  const ReviewHistoryLoaded(this.reviews);

  @override
  List<Object?> get props => [reviews];
}


class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}
