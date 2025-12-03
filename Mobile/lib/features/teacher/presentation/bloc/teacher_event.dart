import 'package:equatable/equatable.dart';
import '../../domain/entities/student_score.dart';
import '../../domain/entities/teacher_profile.dart';

abstract class TeacherEvent extends Equatable {
  const TeacherEvent();

  @override
  List<Object?> get props => [];
}


class LoadTeacherDashboard extends TeacherEvent {}


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
  
  const LoadAttendance({
    required this.sessionId,
    required this.classId,
  });
  
  @override
  List<Object> get props => [sessionId, classId];
}

class RecordAttendance extends TeacherEvent {
  final String classId;
  final String studentId;
  final String status;
  final String? note;
  const RecordAttendance(this.classId, this.studentId, this.status, [this.note]);
  @override
  List<Object?> get props => [classId, studentId, status, note];
}

class SubmitAttendance extends TeacherEvent {
  final String sessionId;
  const SubmitAttendance(this.sessionId);
  @override
  List<Object> get props => [sessionId];
}

class BatchRecordAttendance extends TeacherEvent {
  final String sessionId;
  final List<Map<String, dynamic>> entries;
  const BatchRecordAttendance({required this.sessionId, required this.entries});
  @override
  List<Object> get props => [sessionId, entries];
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
  const LoadStudentScores(this.studentId, this.classId);
  @override
  List<Object> get props => [studentId, classId];
}

class SubmitScore extends TeacherEvent {
  final StudentScore score;
  const SubmitScore(this.score);
  @override
  List<Object> get props => [score];
}

class UpdateScore extends TeacherEvent {
  final StudentScore score;
  const UpdateScore(this.score);
  @override
  List<Object> get props => [score];
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
