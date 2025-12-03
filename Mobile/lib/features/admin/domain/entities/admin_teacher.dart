import 'package:equatable/equatable.dart';

class AdminTeacher extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final List<String> subjects;
  final double rating;
  final int totalClasses;
  final int totalStudents;
  final double attendanceRate;
  final int activeClasses;
  final String status;
  final String? experience;
  final String? qualifications;
  final List<TeacherReview> recentReviews;
  final List<TeacherSchedule> todaySchedule;

  const AdminTeacher({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.subjects = const [],
    this.rating = 0.0,
    this.totalClasses = 0,
    this.totalStudents = 0,
    this.attendanceRate = 0.0,
    this.activeClasses = 0,
    this.status = 'active',
    this.experience,
    this.qualifications,
    this.recentReviews = const [],
    this.todaySchedule = const [],
  });

  String get statusText {
    switch (status) {
      case 'active':
        return 'Đang dạy';
      case 'inactive':
        return 'Nghỉ việc';
      case 'on_leave':
        return 'Nghỉ phép';
      default:
        return 'Không xác định';
    }
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phoneNumber,
    avatarUrl,
    subjects,
    rating,
    totalClasses,
    totalStudents,
    attendanceRate,
    activeClasses,
    status,
    experience,
    qualifications,
    recentReviews,
    todaySchedule,
  ];

  AdminTeacher copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    List<String>? subjects,
    double? rating,
    int? totalClasses,
    int? totalStudents,
    double? attendanceRate,
    int? activeClasses,
    String? status,
    String? experience,
    String? qualifications,
    List<TeacherReview>? recentReviews,
    List<TeacherSchedule>? todaySchedule,
  }) {
    return AdminTeacher(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      subjects: subjects ?? this.subjects,
      rating: rating ?? this.rating,
      totalClasses: totalClasses ?? this.totalClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      activeClasses: activeClasses ?? this.activeClasses,
      status: status ?? this.status,
      experience: experience ?? this.experience,
      qualifications: qualifications ?? this.qualifications,
      recentReviews: recentReviews ?? this.recentReviews,
      todaySchedule: todaySchedule ?? this.todaySchedule,
    );
  }

  factory AdminTeacher.fromJson(Map<String, dynamic> json) {
    return AdminTeacher(
      id: json['id'] ?? '',
      fullName: json['fullName'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'],
      avatarUrl: json['avatarUrl'],
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalClasses: json['totalClasses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
      activeClasses: json['activeClasses'] ?? 0,
      status: json['status'] ?? 'active',
      experience: json['experience'],
      qualifications: json['qualifications'],
      recentReviews:
          (json['recentReviews'] as List<dynamic>?)
              ?.map((e) => TeacherReview.fromJson(e))
              .toList() ??
          [],
      todaySchedule:
          (json['todaySchedule'] as List<dynamic>?)
              ?.map((e) => TeacherSchedule.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Teacher Review (Đánh giá)
class TeacherReview extends Equatable {
  final String id;
  final String studentName;
  final String? studentAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;

  const TeacherReview({
    required this.id,
    required this.studentName,
    this.studentAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    studentName,
    studentAvatar,
    rating,
    comment,
    createdAt,
  ];

  factory TeacherReview.fromJson(Map<String, dynamic> json) {
    return TeacherReview(
      id: json['id'] ?? '',
      studentName: json['studentName'] ?? '',
      studentAvatar: json['studentAvatar'],
      rating: (json['rating'] ?? 0.0).toDouble(),
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}

/// Teacher Schedule (Lịch dạy)
class TeacherSchedule extends Equatable {
  final String id;
  final String className;
  final String? classRoom;
  final DateTime startTime;
  final DateTime endTime;
  final String? subject; // IELTS, TOEIC, etc.
  final int studentCount;

  const TeacherSchedule({
    required this.id,
    required this.className,
    this.classRoom,
    required this.startTime,
    required this.endTime,
    this.subject,
    this.studentCount = 0,
  });

  @override
  List<Object?> get props => [
    id,
    className,
    classRoom,
    startTime,
    endTime,
    subject,
    studentCount,
  ];

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      id: json['id'] ?? '',
      className: json['className'] ?? '',
      classRoom: json['classRoom'],
      startTime: json['startTime'] != null
          ? DateTime.parse(json['startTime'])
          : DateTime.now(),
      endTime: json['endTime'] != null
          ? DateTime.parse(json['endTime'])
          : DateTime.now(),
      subject: json['subject'],
      studentCount: json['studentCount'] ?? 0,
    );
  }
}
