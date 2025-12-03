import 'package:equatable/equatable.dart';

class AdminTeacher extends Equatable {
  final String id;
  final String fullName;
  final String? email;
  final String? phoneNumber;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final List<String> subjects;
  final double rating;
  final int totalReviews;
  final int totalClasses;
  final int totalStudents;
  final double attendanceRate;
  final int activeClasses;
  final String status;
  final String? experience;
  final String? qualifications;
  final List<TeacherQualification> qualificationsList;
  final List<TeacherReview> recentReviews;
  final List<TeacherSchedule> todaySchedule;
  final TeacherAccountInfo? accountInfo;

  const AdminTeacher({
    required this.id,
    required this.fullName,
    this.email,
    this.phoneNumber,
    this.avatarUrl,
    this.dateOfBirth,
    this.subjects = const [],
    this.rating = 0.0,
    this.totalReviews = 0,
    this.totalClasses = 0,
    this.totalStudents = 0,
    this.attendanceRate = 0.0,
    this.activeClasses = 0,
    this.status = 'active',
    this.experience,
    this.qualifications,
    this.qualificationsList = const [],
    this.recentReviews = const [],
    this.todaySchedule = const [],
    this.accountInfo,
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

  
  String get qualificationsText {
    if (qualificationsList.isEmpty) {
      return qualifications ?? 'Chưa cập nhật';
    }
    return qualificationsList
        .map((q) => '${q.degreeName}${q.level != null ? " (${q.level})" : ""}')
        .join(', ');
  }

  @override
  List<Object?> get props => [
    id,
    fullName,
    email,
    phoneNumber,
    avatarUrl,
    dateOfBirth,
    subjects,
    rating,
    totalReviews,
    totalClasses,
    totalStudents,
    attendanceRate,
    activeClasses,
    status,
    experience,
    qualifications,
    qualificationsList,
    recentReviews,
    todaySchedule,
    accountInfo,
  ];

  AdminTeacher copyWith({
    String? id,
    String? fullName,
    String? email,
    String? phoneNumber,
    String? avatarUrl,
    DateTime? dateOfBirth,
    List<String>? subjects,
    double? rating,
    int? totalReviews,
    int? totalClasses,
    int? totalStudents,
    double? attendanceRate,
    int? activeClasses,
    String? status,
    String? experience,
    String? qualifications,
    List<TeacherQualification>? qualificationsList,
    List<TeacherReview>? recentReviews,
    List<TeacherSchedule>? todaySchedule,
    TeacherAccountInfo? accountInfo,
  }) {
    return AdminTeacher(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      subjects: subjects ?? this.subjects,
      rating: rating ?? this.rating,
      totalReviews: totalReviews ?? this.totalReviews,
      totalClasses: totalClasses ?? this.totalClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      activeClasses: activeClasses ?? this.activeClasses,
      status: status ?? this.status,
      experience: experience ?? this.experience,
      qualifications: qualifications ?? this.qualifications,
      qualificationsList: qualificationsList ?? this.qualificationsList,
      recentReviews: recentReviews ?? this.recentReviews,
      todaySchedule: todaySchedule ?? this.todaySchedule,
      accountInfo: accountInfo ?? this.accountInfo,
    );
  }

  factory AdminTeacher.fromJson(Map<String, dynamic> json) {
    
    List<TeacherQualification> qualList = [];
    if (json['qualifications'] is List) {
      qualList = (json['qualifications'] as List)
          .map((e) => TeacherQualification.fromJson(e))
          .toList();
    }

    
    TeacherAccountInfo? accountInfo;
    if (json['accountInfo'] != null) {
      accountInfo = TeacherAccountInfo.fromJson(json['accountInfo']);
    }

    return AdminTeacher(
      id: (json['lecturerId'] ?? json['id'] ?? '').toString(),
      fullName: json['fullName'] ?? json['hoten'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['sdt'],
      avatarUrl: json['imagePath'] ?? json['avatarUrl'] ?? json['hinhanh'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'])
          : null,
      subjects:
          (json['subjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      rating: (json['rating'] ?? 0.0).toDouble(),
      totalReviews: json['totalReviews'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
      activeClasses: json['activeClasses'] ?? json['totalClasses'] ?? 0,
      status: json['status'] ?? 'active',
      experience: json['experience'],
      qualifications: json['qualifications'] is String ? json['qualifications'] : null,
      qualificationsList: qualList,
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
      accountInfo: accountInfo,
    );
  }
}


class TeacherQualification extends Equatable {
  final int? degreeId;
  final String? degreeName;
  final String? level;

  const TeacherQualification({
    this.degreeId,
    this.degreeName,
    this.level,
  });

  @override
  List<Object?> get props => [degreeId, degreeName, level];

  factory TeacherQualification.fromJson(Map<String, dynamic> json) {
    return TeacherQualification(
      degreeId: json['degreeId'],
      degreeName: json['degreeName'],
      level: json['level'],
    );
  }
}


class TeacherAccountInfo extends Equatable {
  final int? userId;
  final String? username;
  final String? password;
  final String? role;
  final DateTime? createdAt;
  final bool isVerified;

  const TeacherAccountInfo({
    this.userId,
    this.username,
    this.password,
    this.role,
    this.createdAt,
    this.isVerified = false,
  });

  @override
  List<Object?> get props => [userId, username, password, role, createdAt, isVerified];

  factory TeacherAccountInfo.fromJson(Map<String, dynamic> json) {
    return TeacherAccountInfo(
      userId: json['userId'],
      username: json['username'],
      password: json['password'],
      role: json['role'],
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
      isVerified: json['isVerified'] ?? false,
    );
  }
}


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


class TeacherSchedule extends Equatable {
  final String id;
  final String className;
  final String? classRoom;
  final DateTime startTime;
  final DateTime endTime;
  final String? subject; 
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
