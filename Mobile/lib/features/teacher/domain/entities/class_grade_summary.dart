import 'package:equatable/equatable.dart';

class ClassGradeSummary extends Equatable {
  final String studentId; 
  final String studentName; 
  final String email;
  final String phone; 
  final String classId; 
  final String className; 
  final String courseName; 

  final double? attendanceScore; 
  final double? midtermScore; 
  final double? finalScore; 

  final double finalGrade; 
  final String classification; 
  final DateTime? lastGradedDate; 

  final String
  completionStatus; 

  const ClassGradeSummary({
    required this.studentId,
    required this.studentName,
    required this.email,
    required this.phone,
    required this.classId,
    required this.className,
    required this.courseName,
    this.attendanceScore,
    this.midtermScore,
    this.finalScore,
    required this.finalGrade,
    required this.classification,
    this.lastGradedDate,
    required this.completionStatus,
  });

  
  bool get isCompleted => completionStatus == 'Hoàn thành';

  
  bool get hasAnyGrade =>
      attendanceScore != null || midtermScore != null || finalScore != null;

  String get classificationColor {
    switch (classification) {
      case 'Xuất sắc':
        return '#4CAF50'; 
      case 'Giỏi':
        return '#2196F3'; 
      case 'Khá':
        return '#FF9800'; 
      case 'Trung bình':
        return '#FFC107'; 
      case 'Yếu':
        return '#F44336'; 
      default:
        return '#9E9E9E'; 
    }
  }

  
  String get classificationIcon {
    switch (classification) {
      case 'Xuất sắc':
        return '🏆';
      case 'Giỏi':
        return '⭐';
      case 'Khá':
        return '👍';
      case 'Trung bình':
        return '📝';
      case 'Yếu':
        return '📉';
      default:
        return '❓';
    }
  }

  @override
  List<Object?> get props => [
    studentId,
    studentName,
    email,
    phone,
    classId,
    className,
    courseName,
    attendanceScore,
    midtermScore,
    finalScore,
    finalGrade,
    classification,
    lastGradedDate,
    completionStatus,
  ];

  ClassGradeSummary copyWith({
    String? studentId,
    String? studentName,
    String? email,
    String? phone,
    String? classId,
    String? className,
    String? courseName,
    double? attendanceScore,
    double? midtermScore,
    double? finalScore,
    double? finalGrade,
    String? classification,
    DateTime? lastGradedDate,
    String? completionStatus,
  }) {
    return ClassGradeSummary(
      studentId: studentId ?? this.studentId,
      studentName: studentName ?? this.studentName,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      courseName: courseName ?? this.courseName,
      attendanceScore: attendanceScore ?? this.attendanceScore,
      midtermScore: midtermScore ?? this.midtermScore,
      finalScore: finalScore ?? this.finalScore,
      finalGrade: finalGrade ?? this.finalGrade,
      classification: classification ?? this.classification,
      lastGradedDate: lastGradedDate ?? this.lastGradedDate,
      completionStatus: completionStatus ?? this.completionStatus,
    );
  }
}
