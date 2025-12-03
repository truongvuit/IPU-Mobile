import '../../domain/entities/grade.dart';

/// GradeModel extends Grade entity
/// Matches backend GradeResponse structure
class GradeModel extends Grade {
  const GradeModel({
    super.gradeId,
    super.classId,
    super.className,
    super.courseId,
    super.courseName,
    super.courseImage,
    super.attendanceScore,
    super.midtermScore,
    super.finalScore,
    super.totalScore,
    super.grade,
    super.status,
    super.comment,
    super.lastGradedAt,
    super.gradedByName,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      gradeId: json['gradeId'] as int?,
      classId: json['classId'] as int?,
      className: json['className'] as String?,
      courseId: json['courseId'] as int?,
      courseName: json['courseName'] as String?,
      courseImage: json['courseImage'] as String?,
      attendanceScore: _parseDouble(json['attendanceScore']),
      midtermScore: _parseDouble(json['midtermScore']),
      finalScore: _parseDouble(json['finalScore']),
      totalScore: _parseDouble(json['totalScore']),
      grade: json['grade'] as String?,
      status: json['status'] as String?,
      comment: json['comment'] as String?,
      lastGradedAt: json['lastGradedAt'] != null 
          ? DateTime.tryParse(json['lastGradedAt'].toString())
          : null,
      gradedByName: json['gradedByName'] as String?,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'gradeId': gradeId,
      'classId': classId,
      'className': className,
      'courseId': courseId,
      'courseName': courseName,
      'courseImage': courseImage,
      'attendanceScore': attendanceScore,
      'midtermScore': midtermScore,
      'finalScore': finalScore,
      'totalScore': totalScore,
      'grade': grade,
      'status': status,
      'comment': comment,
      'lastGradedAt': lastGradedAt?.toIso8601String(),
      'gradedByName': gradedByName,
    };
  }

  factory GradeModel.fromEntity(Grade entity) {
    return GradeModel(
      gradeId: entity.gradeId,
      classId: entity.classId,
      className: entity.className,
      courseId: entity.courseId,
      courseName: entity.courseName,
      courseImage: entity.courseImage,
      attendanceScore: entity.attendanceScore,
      midtermScore: entity.midtermScore,
      finalScore: entity.finalScore,
      totalScore: entity.totalScore,
      grade: entity.grade,
      status: entity.status,
      comment: entity.comment,
      lastGradedAt: entity.lastGradedAt,
      gradedByName: entity.gradedByName,
    );
  }

  GradeModel copyWith({
    int? gradeId,
    int? classId,
    String? className,
    int? courseId,
    String? courseName,
    String? courseImage,
    double? attendanceScore,
    double? midtermScore,
    double? finalScore,
    double? totalScore,
    String? grade,
    String? status,
    String? comment,
    DateTime? lastGradedAt,
    String? gradedByName,
  }) {
    return GradeModel(
      gradeId: gradeId ?? this.gradeId,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseImage: courseImage ?? this.courseImage,
      attendanceScore: attendanceScore ?? this.attendanceScore,
      midtermScore: midtermScore ?? this.midtermScore,
      finalScore: finalScore ?? this.finalScore,
      totalScore: totalScore ?? this.totalScore,
      grade: grade ?? this.grade,
      status: status ?? this.status,
      comment: comment ?? this.comment,
      lastGradedAt: lastGradedAt ?? this.lastGradedAt,
      gradedByName: gradedByName ?? this.gradedByName,
    );
  }
}
