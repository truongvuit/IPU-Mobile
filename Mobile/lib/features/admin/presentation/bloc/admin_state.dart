import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_activity.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/admin_profile.dart';
import '../../domain/entities/admin_class.dart';
import '../../domain/entities/admin_student.dart';
import '../../domain/entities/class_student.dart';
import '../../domain/entities/admin_teacher.dart';
import '../../domain/entities/admin_feedback.dart';

abstract class AdminState extends Equatable {
  const AdminState();

  @override
  List<Object?> get props => [];
}

class AdminInitial extends AdminState {
  const AdminInitial();
}

class AdminLoading extends AdminState {
  const AdminLoading();
}

class AdminError extends AdminState {
  final String message;

  const AdminError(this.message);

  @override
  List<Object?> get props => [message];
}


class AdminDashboardLoaded extends AdminState {
  final AdminProfile profile;
  final AdminDashboardStats stats;
  final List<AdminActivity> recentActivities;
  
  final bool isFallbackData;

  const AdminDashboardLoaded({
    required this.profile,
    required this.stats,
    required this.recentActivities,
    this.isFallbackData = false,
  });

  @override
  List<Object?> get props => [profile, stats, recentActivities, isFallbackData];

  AdminDashboardLoaded copyWith({
    AdminProfile? profile,
    AdminDashboardStats? stats,
    List<AdminActivity>? recentActivities,
    bool? isFallbackData,
  }) {
    return AdminDashboardLoaded(
      profile: profile ?? this.profile,
      stats: stats ?? this.stats,
      recentActivities: recentActivities ?? this.recentActivities,
      isFallbackData: isFallbackData ?? this.isFallbackData,
    );
  }
}


class AdminProfileLoaded extends AdminState {
  final AdminProfile profile;

  const AdminProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class AdminProfileUpdating extends AdminState {
  const AdminProfileUpdating();
}

class AdminProfileUpdated extends AdminState {
  final AdminProfile profile;

  const AdminProfileUpdated(this.profile);

  @override
  List<Object?> get props => [profile];
}


class AdminProfileUpdateUnsupported extends AdminState {
  final String message;

  const AdminProfileUpdateUnsupported(this.message);

  @override
  List<Object?> get props => [message];
}


class ClassListLoaded extends AdminState {
  final List<AdminClass> classes;
  final ClassStatus? appliedFilter;

  const ClassListLoaded({required this.classes, this.appliedFilter});

  @override
  List<Object?> get props => [classes, appliedFilter];

  List<AdminClass> get ongoingClasses =>
      classes.where((c) => c.status == ClassStatus.ongoing).toList();

  List<AdminClass> get upcomingClasses =>
      classes.where((c) => c.status == ClassStatus.upcoming).toList();

  List<AdminClass> get completedClasses =>
      classes.where((c) => c.status == ClassStatus.completed).toList();
}

class ClassDetailLoaded extends AdminState {
  final AdminClass classInfo;
  final List<ClassStudent> students;

  const ClassDetailLoaded({required this.classInfo, required this.students});

  @override
  List<Object?> get props => [classInfo, students];
}

class ClassUpdating extends AdminState {
  const ClassUpdating();
}

class ClassUpdated extends AdminState {
  final AdminClass updatedClass;

  const ClassUpdated(this.updatedClass);

  @override
  List<Object?> get props => [updatedClass];
}


class StudentListLoaded extends AdminState {
  final List<AdminStudent> students;
  final String? searchQuery;

  const StudentListLoaded({required this.students, this.searchQuery});

  @override
  List<Object?> get props => [students, searchQuery];
}

class ClassStudentListLoaded extends AdminState {
  final String classId;
  final String className;
  final List<ClassStudent> students;

  const ClassStudentListLoaded({
    required this.classId,
    required this.className,
    required this.students,
  });

  @override
  List<Object?> get props => [classId, className, students];
}

class StudentDetailLoaded extends AdminState {
  final AdminStudent student;
  final List<AdminClass> enrolledClasses;

  const StudentDetailLoaded({
    required this.student,
    required this.enrolledClasses,
  });

  @override
  List<Object?> get props => [student, enrolledClasses];
}

class StudentUpdating extends AdminState {
  const StudentUpdating();
}

class StudentUpdated extends AdminState {
  final AdminStudent updatedStudent;

  const StudentUpdated(this.updatedStudent);

  @override
  List<Object?> get props => [updatedStudent];
}


class TeacherListLoaded extends AdminState {
  final List<AdminTeacher> teachers;
  final String? searchQuery;

  const TeacherListLoaded({required this.teachers, this.searchQuery});

  @override
  List<Object?> get props => [teachers, searchQuery];
}

class TeacherDetailLoaded extends AdminState {
  final AdminTeacher teacher;

  const TeacherDetailLoaded({required this.teacher});

  @override
  List<Object?> get props => [teacher];
}


class ClassFeedbacksLoaded extends AdminState {
  final String classId;
  final List<AdminFeedback> feedbacks;

  const ClassFeedbacksLoaded({required this.classId, required this.feedbacks});

  @override
  List<Object?> get props => [classId, feedbacks];
}
