import 'package:equatable/equatable.dart';

class ClassStudent extends Equatable {
  final String name;
  final String code;
  final String? avatarUrl;

  const ClassStudent({
    required this.name,
    required this.code,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [name, code, avatarUrl];
}

class StudentClass extends Equatable {
  
  final String id;
  
  
  final String courseId;
  
  
  final String courseName;
  
  
  final String imageUrl;
  
  
  final String teacherName;
  
  
  final String room;
  
  
  final DateTime startTime;
  
  
  final DateTime endTime;
  
  
  final String status;
  
  
  final bool isOnline;
  
  
  final int currentStudents;
  
  
  final List<DateTime> schedule;
  
  
  final String? meetingUrl;

  
  final String? teacherSpecialization;

  
  final String? teacherCertificates;

  
  final String? courseType;

  
  final String? level;

  
  final String? duration;

  
  final int? maxStudents;

  
  final List<ClassStudent> students;

  
  final double attendanceRate;

  
  final double progress;

  const StudentClass({
    required this.id,
    required this.courseId,
    required this.courseName,
    required this.imageUrl,
    required this.teacherName,
    required this.room,
    required this.startTime,
    required this.endTime,
    required this.status,
    this.isOnline = false,
    required this.currentStudents,
    this.schedule = const [],
    this.meetingUrl,
    this.teacherSpecialization,
    this.teacherCertificates,
    this.courseType,
    this.level,
    this.duration,
    this.maxStudents,
    this.students = const [],
    this.attendanceRate = 0.0,
    this.progress = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        courseId,
        courseName,
        imageUrl,
        teacherName,
        room,
        startTime,
        endTime,
        status,
        isOnline,
        currentStudents,
        schedule,
        meetingUrl,
        teacherSpecialization,
        teacherCertificates,
        courseType,
        level,
        duration,
        maxStudents,
        students,
        attendanceRate,
        progress,
      ];

  StudentClass copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? imageUrl,
    String? teacherName,
    String? room,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    bool? isOnline,
    int? currentStudents,
    List<DateTime>? schedule,
    String? meetingUrl,
    String? teacherSpecialization,
    String? teacherCertificates,
    String? courseType,
    String? level,
    String? duration,
    int? maxStudents,
    List<ClassStudent>? students,
    double? attendanceRate,
    double? progress,
  }) {
    return StudentClass(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      imageUrl: imageUrl ?? this.imageUrl,
      teacherName: teacherName ?? this.teacherName,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      currentStudents: currentStudents ?? this.currentStudents,
      schedule: schedule ?? this.schedule,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      teacherSpecialization: teacherSpecialization ?? this.teacherSpecialization,
      teacherCertificates: teacherCertificates ?? this.teacherCertificates,
      courseType: courseType ?? this.courseType,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      maxStudents: maxStudents ?? this.maxStudents,
      students: students ?? this.students,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      progress: progress ?? this.progress,
    );
  }
}
