import '../../domain/entities/grade.dart';

class GradeModel extends Grade {
  const GradeModel({
    required super.id,
    required super.courseName,
    required super.examType,
    required super.score,
    required super.maxScore,
    required super.examDate,
    super.feedback,
  });

  factory GradeModel.fromJson(Map<String, dynamic> json) {
    return GradeModel(
      id: json['gradeId']?.toString() ?? json['maPhieu']?.toString() ?? '',
      courseName: json['courseName'] ?? json['tenKhoaHoc'] ?? '',
      examType:
          json['examType'] ?? _mapGradeType(json['loaiDiem']) ?? 'Assignment',
      score: (json['score'] ?? json['diem'] ?? 0).toDouble(),
      maxScore: (json['maxScore'] ?? 10).toDouble(),
      examDate: json['examDate'] != null
          ? DateTime.parse(json['examDate'])
          : json['ngayLap'] != null
          ? DateTime.parse(json['ngayLap'])
          : DateTime.now(),
      feedback: json['feedback'] ?? json['ghiChu'],
    );
  }

  static String _mapGradeType(String? loaiDiem) {
    if (loaiDiem == null) return 'Assignment';
    if (loaiDiem.contains('1')) return 'Quiz';
    if (loaiDiem.contains('2')) return 'Midterm';
    if (loaiDiem.contains('3')) return 'Final';
    return loaiDiem;
  }

  Map<String, dynamic> toJson() {
    return {
      'gradeId': id,
      'courseName': courseName,
      'examType': examType,
      'score': score,
      'maxScore': maxScore,
      'examDate': examDate.toIso8601String(),
      'feedback': feedback,
    };
  }

  factory GradeModel.fromEntity(Grade grade) {
    return GradeModel(
      id: grade.id,
      courseName: grade.courseName,
      examType: grade.examType,
      score: grade.score,
      maxScore: grade.maxScore,
      examDate: grade.examDate,
      feedback: grade.feedback,
    );
  }

  @override
  GradeModel copyWith({
    String? id,
    String? courseName,
    String? examType,
    double? score,
    double? maxScore,
    DateTime? examDate,
    String? feedback,
  }) {
    return GradeModel(
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
