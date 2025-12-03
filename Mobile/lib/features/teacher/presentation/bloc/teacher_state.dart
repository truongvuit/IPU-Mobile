import 'package:equatable/equatable.dart';
import '../../domain/entities/teacher_class.dart';
import '../../domain/entities/class_student.dart';
import '../../domain/entities/attendance.dart';
import '../../domain/entities/student_score.dart';
import '../../domain/entities/teacher_schedule.dart';
import '../../domain/entities/teacher_profile.dart';

abstract class TeacherState extends Equatable {
  const TeacherState();

  @override
  List<Object?> get props => [];
}

class TeacherInitial extends TeacherState {}

class TeacherLoading extends TeacherState {
  final String? action;

  const TeacherLoading({this.action});

  @override
  List<Object?> get props => [action];
}


class TeacherLoaded extends TeacherState {
  final TeacherProfile profile;
  final List<TeacherClass>? classes;
  final List<TeacherSchedule>? schedules;
  final List<ClassStudent>? students;

  const TeacherLoaded({
    required this.profile,
    this.classes,
    this.schedules,
    this.students,
  });

  @override
  List<Object?> get props => [profile, classes, schedules, students];

  TeacherLoaded copyWith({
    TeacherProfile? profile,
    List<TeacherClass>? classes,
    List<TeacherSchedule>? schedules,
    List<ClassStudent>? students,
  }) {
    return TeacherLoaded(
      profile: profile ?? this.profile,
      classes: classes ?? this.classes,
      schedules: schedules ?? this.schedules,
      students: students ?? this.students,
    );
  }
}



class DashboardLoaded extends TeacherState {
  final List<TeacherSchedule> todaySchedule;
  final List<TeacherClass> recentClasses;
  final TeacherProfile profile;
  final List<TeacherSchedule>? weekSchedule; 

  const DashboardLoaded({
    required this.todaySchedule,
    required this.recentClasses,
    required this.profile,
    this.weekSchedule,
  });

  @override
  List<Object?> get props => [todaySchedule, recentClasses, profile, weekSchedule];
}


class ClassesLoaded extends TeacherState {
  final List<TeacherClass> classes;
  const ClassesLoaded(this.classes);
  @override
  List<Object> get props => [classes];
}

class ClassDetailLoaded extends TeacherState {
  final TeacherClass classDetail;
  final List<ClassStudent> students;
  const ClassDetailLoaded(this.classDetail, this.students);
  @override
  List<Object> get props => [classDetail, students];
}

class ClassStudentLoaded extends TeacherState {
  final ClassStudent student;
  const ClassStudentLoaded(this.student);
  @override
  List<Object> get props => [student];
}


class StudentsLoaded extends TeacherState {
  final List<ClassStudent> students;
  const StudentsLoaded(this.students);
  @override
  List<Object> get props => [students];
}

class StudentDetailLoaded extends TeacherState {
  final ClassStudent student;
  final List<AttendanceRecord> attendanceHistory;
  final List<StudentScore> scores;
  const StudentDetailLoaded(this.student, this.attendanceHistory, this.scores);
  @override
  List<Object> get props => [student, attendanceHistory, scores];
}


class AttendanceLoaded extends TeacherState {
  final AttendanceSession session;
  const AttendanceLoaded(this.session);
  @override
  List<Object> get props => [session];
}

class AttendanceRecorded extends TeacherState {
  final AttendanceSession session;
  const AttendanceRecorded(this.session);
  @override
  List<Object> get props => [session];
}

class AttendanceSubmitted extends TeacherState {
  final String message;
  const AttendanceSubmitted(this.message);
  @override
  List<Object> get props => [message];
}


class ClassScoresLoaded extends TeacherState {
  final List<StudentScore> scores;
  const ClassScoresLoaded(this.scores);
  @override
  List<Object> get props => [scores];
}

class StudentScoresLoaded extends TeacherState {
  final List<StudentScore> scores;
  const StudentScoresLoaded(this.scores);
  @override
  List<Object> get props => [scores];
}

class ScoreSubmitted extends TeacherState {
  final String message;
  const ScoreSubmitted(this.message);
  @override
  List<Object> get props => [message];
}

class ScoreUpdated extends TeacherState {
  final String message;
  const ScoreUpdated(this.message);
  @override
  List<Object> get props => [message];
}


class ScheduleLoaded extends TeacherState {
  final List<TeacherSchedule> schedule;
  const ScheduleLoaded(this.schedule);
  @override
  List<Object> get props => [schedule];
}


class ProfileLoaded extends TeacherState {
  final TeacherProfile profile;
  const ProfileLoaded(this.profile);
  @override
  List<Object> get props => [profile];
}

class ProfileUpdated extends TeacherState {
  final String message;
  final TeacherProfile? profile;
  const ProfileUpdated(this.message, {this.profile});
  @override
  List<Object?> get props => [message, profile];
}


class TeacherError extends TeacherState {
  final String message;
  const TeacherError(this.message);
  @override
  List<Object> get props => [message];
}
