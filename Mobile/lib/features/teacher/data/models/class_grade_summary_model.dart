import '../../domain/entities/class_grade_summary.dart';

class ClassGradeSummaryModel extends ClassGradeSummary {
  const ClassGradeSummaryModel({
    required super.studentId,
    required super.studentName,
    required super.email,
    required super.phone,
    required super.classId,
    required super.className,
    required super.courseName,
    super.attendanceScore,
    super.midtermScore,
    super.finalScore,
    required super.finalGrade,
    required super.classification,
    super.lastGradedDate,
    required super.completionStatus,
  });

  
  factory ClassGradeSummaryModel.fromJson(Map<String, dynamic> json) {
    return ClassGradeSummaryModel(
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['phoneNumber']?.toString() ?? '',
      classId: json['classId']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? '',
      attendanceScore: json['attendanceScore'] != null
          ? double.tryParse(json['attendanceScore'].toString())
          : null,
      midtermScore: json['midtermScore'] != null
          ? double.tryParse(json['midtermScore'].toString())
          : null,
      finalScore: json['finalScore'] != null
          ? double.tryParse(json['finalScore'].toString())
          : null,
      finalGrade: double.tryParse(json['totalScore']?.toString() ?? '0') ?? 0.0,
      classification: json['grade']?.toString() ?? 'Chưa xếp loại',
      lastGradedDate: json['lastGradedAt'] != null
          ? DateTime.tryParse(json['lastGradedAt'].toString())
          : null,
      completionStatus: json['status']?.toString() ?? 'Chưa hoàn thành',
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'studentId': studentId,
      'studentName': studentName,
      'email': email,
      'phoneNumber': phone,
      'classId': classId,
      'className': className,
      'courseName': courseName,
      'attendanceScore': attendanceScore,
      'midtermScore': midtermScore,
      'finalScore': finalScore,
      'totalScore': finalGrade,
      'grade': classification,
      'lastGradedAt': lastGradedDate?.toIso8601String(),
      'status': completionStatus,
    };
  }

  ClassGradeSummary toEntity() {
    return ClassGradeSummary(
      studentId: studentId,
      studentName: studentName,
      email: email,
      phone: phone,
      classId: classId,
      className: className,
      courseName: courseName,
      attendanceScore: attendanceScore,
      midtermScore: midtermScore,
      finalScore: finalScore,
      finalGrade: finalGrade,
      classification: classification,
      lastGradedDate: lastGradedDate,
      completionStatus: completionStatus,
    );
  }

  factory ClassGradeSummaryModel.fromEntity(ClassGradeSummary entity) {
    return ClassGradeSummaryModel(
      studentId: entity.studentId,
      studentName: entity.studentName,
      email: entity.email,
      phone: entity.phone,
      classId: entity.classId,
      className: entity.className,
      courseName: entity.courseName,
      attendanceScore: entity.attendanceScore,
      midtermScore: entity.midtermScore,
      finalScore: entity.finalScore,
      finalGrade: entity.finalGrade,
      classification: entity.classification,
      lastGradedDate: entity.lastGradedDate,
      completionStatus: entity.completionStatus,
    );
  }
}
