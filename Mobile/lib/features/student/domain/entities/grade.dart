import 'package:equatable/equatable.dart';


class Grade extends Equatable {
  final int? gradeId;
  final int? classId;
  final String? className;
  final int? courseId;
  final String? courseName;
  final String? courseImage;

  
  final double? attendanceScore; 
  final double? midtermScore; 
  final double? finalScore; 

  
  final double? totalScore;
  final String? grade; 
  final String? status; 

  
  final String? comment;
  final DateTime? lastGradedAt;
  final String? gradedByName;

  const Grade({
    this.gradeId,
    this.classId,
    this.className,
    this.courseId,
    this.courseName,
    this.courseImage,
    this.attendanceScore,
    this.midtermScore,
    this.finalScore,
    this.totalScore,
    this.grade,
    this.status,
    this.comment,
    this.lastGradedAt,
    this.gradedByName,
  });

  factory Grade.fromJson(Map<String, dynamic> json) {
    return Grade(
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

  bool get isCompleted => status == 'Hoàn thành';

  String get displayTotalScore {
    if (totalScore == null) return '--';
    return totalScore!.toStringAsFixed(1);
  }

  @override
  List<Object?> get props => [
    gradeId,
    classId,
    className,
    courseId,
    courseName,
    courseImage,
    attendanceScore,
    midtermScore,
    finalScore,
    totalScore,
    grade,
    status,
    comment,
    lastGradedAt,
    gradedByName,
  ];
}
