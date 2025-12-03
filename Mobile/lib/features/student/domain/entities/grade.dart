import 'package:equatable/equatable.dart';


class Grade extends Equatable {
  final String id;
  final String courseName;
  final String examType; 
  final double score;
  final double maxScore;
  final DateTime examDate;
  final String? feedback;

  const Grade({
    required this.id,
    required this.courseName,
    required this.examType,
    required this.score,
    required this.maxScore,
    required this.examDate,
    this.feedback,
  });

  double get percentage => (score / maxScore) * 100;

  String get letterGrade {
    final percent = percentage;
    if (percent >= 90) return 'A';
    if (percent >= 80) return 'B';
    if (percent >= 70) return 'C';
    if (percent >= 60) return 'D';
    return 'F';
  }

  @override
  List<Object?> get props => [
        id,
        courseName,
        examType,
        score,
        maxScore,
        examDate,
        feedback,
      ];

  Grade copyWith({
    String? id,
    String? courseName,
    String? examType,
    double? score,
    double? maxScore,
    DateTime? examDate,
    String? feedback,
  }) {
    return Grade(
      id: id ?? this.id,
      courseName: courseName ?? this.courseName,
      examType: examType ?? this.examType,
      score: score ?? this.score,
      maxScore: maxScore ?? this.maxScore,
      examDate: examDate ?? this.examDate,
      feedback: feedback ?? this.feedback,
    );
  }
}
