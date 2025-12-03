import 'package:equatable/equatable.dart';


class StudentScore extends Equatable {
  final String id;
  final String studentId;
  final String classId;
  final String examType; 
  final String examName;
  final double score;
  final double maxScore;
  final DateTime examDate;
  final String? feedback;
  final DateTime? submittedAt;
  final String? studentName;
  final String? studentCode;
  final String? studentAvatar;

  const StudentScore({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.examType,
    required this.examName,
    required this.score,
    required this.maxScore,
    required this.examDate,
    this.feedback,
    this.submittedAt,
    this.studentName,
    this.studentCode,
    this.studentAvatar,
  });

  double get percentage => (score / maxScore) * 100;

  String get letterGrade {
    if (percentage >= 90) return 'A';
    if (percentage >= 80) return 'B';
    if (percentage >= 70) return 'C';
    if (percentage >= 60) return 'D';
    return 'F';
  }

  @override
  List<Object?> get props => [
        id,
        studentId,
        classId,
        examType,
        examName,
        score,
        maxScore,
        examDate,
        feedback,
        submittedAt,
        studentName,
        studentCode,
        studentAvatar,
      ];

  StudentScore copyWith({
    String? id,
    String? studentId,
    String? classId,
    String? examType,
    String? examName,
    double? score,
    double? maxScore,
    DateTime? examDate,
    String? feedback,
    DateTime? submittedAt,
    String? studentName,
    String? studentCode,
    String? studentAvatar,
  }) {
    return StudentScore(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      examType: examType ?? this.examType,
      examName: examName ?? this.examName,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      examDate: examDate ?? this.examDate,
      feedback: feedback ?? this.feedback,
      submittedAt: submittedAt ?? this.submittedAt,
      studentName: studentName ?? this.studentName,
      studentCode: studentCode ?? this.studentCode,
      studentAvatar: studentAvatar ?? this.studentAvatar,
    );
  }
}
