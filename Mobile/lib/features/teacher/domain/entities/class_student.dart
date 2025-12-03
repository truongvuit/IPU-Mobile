import 'package:equatable/equatable.dart';


class ClassStudent extends Equatable {
  final String id;
  final String studentCode;
  final String fullName;
  final String? avatarUrl;
  final String? email;
  final String? phoneNumber;
  final double? averageScore;
  final int totalAbsences;
  final int totalPresences;
  final DateTime enrollmentDate;

  const ClassStudent({
    required this.id,
    required this.studentCode,
    required this.fullName,
    this.avatarUrl,
    this.email,
    this.phoneNumber,
    this.averageScore,
    this.totalAbsences = 0,
    this.totalPresences = 0,
    required this.enrollmentDate,
  });

  double get attendanceRate {
    final total = totalPresences + totalAbsences;
    if (total == 0) return 0.0;
    return (totalPresences / total) * 100;
  }

  @override
  List<Object?> get props => [
        id,
        studentCode,
        fullName,
        avatarUrl,
        email,
        phoneNumber,
        averageScore,
        totalAbsences,
        totalPresences,
        enrollmentDate,
      ];

  ClassStudent copyWith({
    String? id,
    String? studentCode,
    String? fullName,
    String? avatarUrl,
    String? email,
    String? phoneNumber,
    double? averageScore,
    int? totalAbsences,
    int? totalPresences,
    DateTime? enrollmentDate,
  }) {
    return ClassStudent(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      averageScore: averageScore ?? this.averageScore,
      totalAbsences: totalAbsences ?? this.totalAbsences,
      totalPresences: totalPresences ?? this.totalPresences,
      enrollmentDate: enrollmentDate ?? this.enrollmentDate,
    );
  }
}
