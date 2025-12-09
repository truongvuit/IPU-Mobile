import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_profile.dart';

abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}

class LoadTeacherDashboard extends TeacherEvent {
  final bool forceRefresh;
  const LoadTeacherDashboard({this.forceRefresh = false});
  @override
  List<Object> get props => [forceRefresh];
}

class LoadMyClasses extends TeacherEvent {}

class SearchClasses extends TeacherEvent {
  final String query;
  const SearchClasses(this.query);
  @override
  List<Object> get props => [query];
}

class FilterClasses extends TeacherEvent {
  final String status;
  const FilterClasses(this.status);
  @override
  List<Object> get props => [status];
}

class LoadClassDetail extends TeacherEvent {
  final String classId;
  const LoadClassDetail(this.classId);
  @override
  List<Object> get props => [classId];
}

class LoadClassStudents extends TeacherEvent {
  final String classId;
  const LoadClassStudents(this.classId);
  @override
  List<Object> get props => [classId];
}

class LoadStudentDetail extends TeacherEvent {
  final String studentId;
  const LoadStudentDetail(this.studentId);
  @override
  List<Object> get props => [studentId];
}

class SearchStudents extends TeacherEvent {
  final String query;
  const SearchStudents(this.query);
  @override
  List<Object> get props => [query];
}

class LoadAttendance extends TeacherEvent {
  final String sessionId;

  final String classId;

  const LoadAttendance({required this.sessionId, required this.classId});

  @override
  List<Object> get props => [sessionId, classId];
}

class BatchRecordAttendance extends TeacherEvent {
  final String sessionId;
  final List<Map<String, dynamic>> entries;
  const BatchRecordAttendance({required this.sessionId, required this.entries});
  @override
  List<Object> get props => [sessionId, entries];
}

class RecordAttendance extends TeacherEvent {
  final String classId;
  final String studentId;
  final String status;
  final String? note;
  const RecordAttendance({
    required this.classId,
    required this.studentId,
    required this.status,
    this.note,
  });
  @override
  List<Object?> get props => [classId, studentId, status, note];
}

class SubmitAttendance extends TeacherEvent {
  final String sessionId;
  const SubmitAttendance(this.sessionId);
  @override
  List<Object> get props => [sessionId];
}

class LoadClassScores extends TeacherEvent {
  final String classId;
  const LoadClassScores(this.classId);
  @override
  List<Object> get props => [classId];
}

class LoadStudentScores extends TeacherEvent {
  final String studentId;
  final String classId;
  const LoadStudentScores({required this.studentId, required this.classId});
  @override
  List<Object> get props => [studentId, classId];
}

class LoadWeekSchedule extends TeacherEvent {
  final DateTime date;
  const LoadWeekSchedule(this.date);
  @override
  List<Object> get props => [date];
}

class LoadTodaySchedule extends TeacherEvent {}

class LoadTeacherProfile extends TeacherEvent {}

class UpdateTeacherProfile extends TeacherEvent {
  final TeacherProfile profile;
  const UpdateTeacherProfile(this.profile);
  @override
  List<Object> get props => [profile];
}

/// Event để reset state khi đăng xuất
class ResetTeacherState extends TeacherEvent {}
