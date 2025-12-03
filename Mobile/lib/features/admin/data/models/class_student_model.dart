import '../../domain/entities/class_student.dart';

class ClassStudentModel extends ClassStudent {
  const ClassStudentModel({
    required super.studentId,
    required super.classId,
    required super.fullName,
    required super.phoneNumber,
    super.avatarUrl,
    required super.attendanceRate,
    required super.enrollmentDate,
    required super.totalSessions,
    required super.attendedSessions,
    super.averageScore,
  });

  factory ClassStudentModel.fromJson(
    Map<String, dynamic> json, {
    String? classId,
  }) {
    return ClassStudentModel(
      studentId: (json['studentId'] ?? json['mahocvien'] ?? '').toString(),
      classId: classId ?? (json['classId'] ?? json['malop'] ?? '').toString(),

      fullName: json['fullName'] as String? ?? json['hoten'] as String? ?? '',

      phoneNumber:
          json['phone'] as String? ??
          json['phoneNumber'] as String? ??
          json['sdt'] as String? ??
          '',

      avatarUrl:
          json['avatar'] as String? ??
          json['avatarUrl'] as String? ??
          json['anhdaidien'] as String?,

      attendanceRate:
          (json['attendanceRate'] as num?)?.toDouble() ??
          (json['chuyencan'] as num?)?.toDouble() ??
          (json['ty_le_comat'] as num?)?.toDouble() ??
          0.0,

      enrollmentDate: _parseDate(json['enrollmentDate'] ?? json['ngaydangky']),

      totalSessions:
          json['totalSessions'] as int? ?? json['tongsobuoi'] as int? ?? 0,

      attendedSessions:
          json['attendedSessions'] as int? ?? json['sobuoidihoc'] as int? ?? 0,

      averageScore:
          (json['averageScore'] as num?)?.toDouble() ??
          (json['diemtrungbinh'] as num?)?.toDouble(),
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'classId': classId,
      'fullName': fullName,
      'phone': phoneNumber,
      'avatar': avatarUrl,
      'attendanceRate': attendanceRate,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'totalSessions': totalSessions,
      'attendedSessions': attendedSessions,
      'averageScore': averageScore,
    };
  }

  factory ClassStudentModel.fromEntity(ClassStudent entity) {
    return ClassStudentModel(
      studentId: entity.studentId,
      classId: entity.classId,
      fullName: entity.fullName,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      attendanceRate: entity.attendanceRate,
      enrollmentDate: entity.enrollmentDate,
      totalSessions: entity.totalSessions,
      attendedSessions: entity.attendedSessions,
      averageScore: entity.averageScore,
    );
  }

  ClassStudent toEntity() {
    return ClassStudent(
      studentId: studentId,
      classId: classId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      attendanceRate: attendanceRate,
      enrollmentDate: enrollmentDate,
      totalSessions: totalSessions,
      attendedSessions: attendedSessions,
      averageScore: averageScore,
    );
  }
}
