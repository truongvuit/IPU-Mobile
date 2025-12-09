import 'package:equatable/equatable.dart';

import '../../domain/entities/admin_class.dart';

abstract class AdminEvent extends Equatable {
  const AdminEvent();

  @override
  List<Object?> get props => [];
}

class LoadAdminDashboard extends AdminEvent {
  const LoadAdminDashboard();
}

class RefreshAdminDashboard extends AdminEvent {
  const RefreshAdminDashboard();
}

class LoadAdminProfile extends AdminEvent {
  const LoadAdminProfile();
}

class UpdateAdminProfile extends AdminEvent {
  final String fullName;
  final String? phoneNumber;
  final String? avatarUrl;

  const UpdateAdminProfile({
    required this.fullName,
    this.phoneNumber,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [fullName, phoneNumber, avatarUrl];
}

class LoadClassList extends AdminEvent {
  final ClassStatus? statusFilter;

  const LoadClassList({this.statusFilter});

  @override
  List<Object?> get props => [statusFilter];
}

class LoadClassDetail extends AdminEvent {
  final String classId;

  const LoadClassDetail(this.classId);

  @override
  List<Object?> get props => [classId];
}

class UpdateClass extends AdminEvent {
  final String classId;
  final Map<String, dynamic> updates;

  const UpdateClass({required this.classId, required this.updates});

  @override
  List<Object?> get props => [classId, updates];
}

class LoadStudentList extends AdminEvent {
  final String? searchQuery;

  const LoadStudentList({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class LoadClassStudentList extends AdminEvent {
  final String classId;

  const LoadClassStudentList(this.classId);

  @override
  List<Object?> get props => [classId];
}

class LoadStudentDetail extends AdminEvent {
  final String studentId;

  const LoadStudentDetail(this.studentId);

  @override
  List<Object?> get props => [studentId];
}

class UpdateStudent extends AdminEvent {
  final String studentId;
  final Map<String, dynamic> updates;

  const UpdateStudent({required this.studentId, required this.updates});

  @override
  List<Object?> get props => [studentId, updates];
}

class LoadTeacherList extends AdminEvent {
  final String? searchQuery;

  const LoadTeacherList({this.searchQuery});

  @override
  List<Object?> get props => [searchQuery];
}

class LoadTeacherDetail extends AdminEvent {
  final String teacherId;

  const LoadTeacherDetail(this.teacherId);

  @override
  List<Object?> get props => [teacherId];
}

class LoadClassFeedbacks extends AdminEvent {
  final String classId;

  const LoadClassFeedbacks(this.classId);

  @override
  List<Object?> get props => [classId];
}

/// Event to reset admin bloc state (e.g., on logout)
class ResetAdminState extends AdminEvent {
  const ResetAdminState();
}
