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
  final List<Schedule> todaySchedules;
  final bool isRefreshing;
  final String? errorMessage;
  final bool? isFromCache;

  const DashboardLoaded({
    required this.upcomingClasses,
    this.profile,
    this.todaySchedules = const [],
    this.isRefreshing = false,
    this.errorMessage,
    this.isFromCache,
  });

  DashboardLoaded copyWith({
    List<StudentClass>? upcomingClasses,
    StudentProfile? profile,
    List<Schedule>? todaySchedules,
    bool? isRefreshing,
    String? errorMessage,
    bool? isFromCache,
  }) {
    return DashboardLoaded(
      upcomingClasses: upcomingClasses ?? this.upcomingClasses,
      profile: profile ?? this.profile,
      todaySchedules: todaySchedules ?? this.todaySchedules,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    upcomingClasses,
    profile,
    todaySchedules,
    isRefreshing,
    errorMessage,
    isFromCache,
  ];
}

class CoursesLoaded extends StudentState {
  final List<Course> courses;
  final bool isRefreshing;
  final String? errorMessage;

  const CoursesLoaded(
    this.courses, {
    this.isRefreshing = false,
    this.errorMessage,
  });

  CoursesLoaded copyWith({
    List<Course>? courses,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return CoursesLoaded(
      courses ?? this.courses,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [courses, isRefreshing, errorMessage];
}

class CourseDetailLoaded extends StudentState {
  final Course course;

  const CourseDetailLoaded(this.course);

  @override
  List<Object?> get props => [course];
}

class ClassesLoaded extends StudentState {
  final List<StudentClass> classes;
  final bool isRefreshing;
  final String? errorMessage;
  final bool isFromCache;

  const ClassesLoaded(
    this.classes, {
    this.isRefreshing = false,
    this.errorMessage,
    this.isFromCache = false,
  });

  ClassesLoaded copyWith({
    List<StudentClass>? classes,
    bool? isRefreshing,
    String? errorMessage,
    bool? isFromCache,
  }) {
    return ClassesLoaded(
      classes ?? this.classes,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [classes, isRefreshing, errorMessage, isFromCache];
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
  final bool isRefreshing;
  final String? errorMessage;
  final bool? isFromCache;

  const ScheduleLoaded({
    required this.schedules,
    required this.selectedDate,
    this.isRefreshing = false,
    this.errorMessage,
    this.isFromCache,
  });

  ScheduleLoaded copyWith({
    List<Schedule>? schedules,
    DateTime? selectedDate,
    bool? isRefreshing,
    String? errorMessage,
    bool? isFromCache,
  }) {
    return ScheduleLoaded(
      schedules: schedules ?? this.schedules,
      selectedDate: selectedDate ?? this.selectedDate,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    schedules,
    selectedDate,
    isRefreshing,
    errorMessage,
    isFromCache,
  ];
}

class WeekScheduleLoaded extends StudentState {
  final List<Schedule> schedules;
  final DateTime startDate;
  final bool isRefreshing;
  final String? errorMessage;
  final bool? isFromCache;

  const WeekScheduleLoaded({
    required this.schedules,
    required this.startDate,
    this.isRefreshing = false,
    this.errorMessage,
    this.isFromCache,
  });

  WeekScheduleLoaded copyWith({
    List<Schedule>? schedules,
    DateTime? startDate,
    bool? isRefreshing,
    String? errorMessage,
    bool? isFromCache,
  }) {
    return WeekScheduleLoaded(
      schedules: schedules ?? this.schedules,
      startDate: startDate ?? this.startDate,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [
    schedules,
    startDate,
    isRefreshing,
    errorMessage,
    isFromCache,
  ];
}

class GradesLoaded extends StudentState {
  final List<Grade> grades;
  final bool isRefreshing;
  final String? errorMessage;

  const GradesLoaded(
    this.grades, {
    this.isRefreshing = false,
    this.errorMessage,
  });

  GradesLoaded copyWith({
    List<Grade>? grades,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return GradesLoaded(
      grades ?? this.grades,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [grades, isRefreshing, errorMessage];
}

class CourseGradesLoaded extends StudentState {
  final List<Grade> grades;
  final String courseId;
  final bool isRefreshing;
  final String? errorMessage;
  final bool isFromCache;

  const CourseGradesLoaded({
    required this.grades,
    required this.courseId,
    this.isRefreshing = false,
    this.errorMessage,
    this.isFromCache = false,
  });

  CourseGradesLoaded copyWith({
    List<Grade>? grades,
    String? courseId,
    bool? isRefreshing,
    String? errorMessage,
    bool? isFromCache,
  }) {
    return CourseGradesLoaded(
      grades: grades ?? this.grades,
      courseId: courseId ?? this.courseId,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
      isFromCache: isFromCache ?? this.isFromCache,
    );
  }

  @override
  List<Object?> get props => [grades, courseId, isRefreshing, errorMessage, isFromCache];
}

class ClassGradesLoaded extends StudentState {
  final Grade? grade;
  final String classId;
  final bool isRefreshing;
  final String? errorMessage;

  const ClassGradesLoaded({
    required this.grade,
    required this.classId,
    this.isRefreshing = false,
    this.errorMessage,
  });

  ClassGradesLoaded copyWith({
    Grade? grade,
    String? classId,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return ClassGradesLoaded(
      grade: grade ?? this.grade,
      classId: classId ?? this.classId,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [grade, classId, isRefreshing, errorMessage];
}

class ProfileLoaded extends StudentState {
  final StudentProfile profile;
  final bool isRefreshing;
  final String? errorMessage;

  const ProfileLoaded(
    this.profile, {
    this.isRefreshing = false,
    this.errorMessage,
  });

  ProfileLoaded copyWith({
    StudentProfile? profile,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return ProfileLoaded(
      profile ?? this.profile,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [profile, isRefreshing, errorMessage];
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
  final bool isRefreshing;
  final String? errorMessage;

  const ReviewHistoryLoaded(
    this.reviews, {
    this.isRefreshing = false,
    this.errorMessage,
  });

  ReviewHistoryLoaded copyWith({
    List<Review>? reviews,
    bool? isRefreshing,
    String? errorMessage,
  }) {
    return ReviewHistoryLoaded(
      reviews ?? this.reviews,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [reviews, isRefreshing, errorMessage];
}

class ClassReviewLoaded extends StudentState {
  final Review? review;
  final String classId;

  const ClassReviewLoaded({this.review, required this.classId});

  @override
  List<Object?> get props => [review, classId];
}

class StudentError extends StudentState {
  final String message;

  const StudentError(this.message);

  @override
  List<Object?> get props => [message];
}

// ==================== CART STATE ====================

/// Represents an item in the shopping cart
class CartItem extends Equatable {
  final String courseId;
  final String courseName;
  final int classId;
  final String className;
  final double price;
  final String? imageUrl;

  const CartItem({
    required this.courseId,
    required this.courseName,
    required this.classId,
    required this.className,
    required this.price,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [courseId, classId, courseName, className, price];
}

/// Emitted when cart is updated (items added/removed)
class StudentCartUpdated extends StudentState {
  final List<CartItem> cartItems;

  const StudentCartUpdated({required this.cartItems});

  int get itemCount => cartItems.length;

  double get subtotal => cartItems.fold(0.0, (sum, item) => sum + item.price);

  List<int> get classIds => cartItems.map((e) => e.classId).toList();

  bool containsClass(int classId) =>
      cartItems.any((item) => item.classId == classId);

  @override
  List<Object?> get props => [cartItems];
}
