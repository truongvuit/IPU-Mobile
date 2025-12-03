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
      studentId: json['mahocvien']?.toString() ?? '',
      studentName: json['ten_hocvien']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phone: json['sdt']?.toString() ?? '',
      classId: json['malop']?.toString() ?? '',
      className: json['tenlop']?.toString() ?? '',
      courseName: json['tenkhoahoc']?.toString() ?? '',
      attendanceScore: json['diem_chuyencan'] != null
          ? double.tryParse(json['diem_chuyencan'].toString())
          : null,
      midtermScore: json['diem_giuaky'] != null
          ? double.tryParse(json['diem_giuaky'].toString())
          : null,
      finalScore: json['diem_cuoiky'] != null
          ? double.tryParse(json['diem_cuoiky'].toString())
          : null,
      finalGrade:
          double.tryParse(json['diem_tongket']?.toString() ?? '0') ?? 0.0,
      classification: json['xeploai']?.toString() ?? 'Chưa xếp loại',
      lastGradedDate: json['ngay_chamdiem_cuoicung'] != null
          ? DateTime.tryParse(json['ngay_chamdiem_cuoicung'].toString())
          : null,
      completionStatus:
          json['trangthai_hoantat']?.toString() ?? 'Chưa hoàn thành',
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'mahocvien': studentId,
      'ten_hocvien': studentName,
      'email': email,
      'sdt': phone,
      'malop': classId,
      'tenlop': className,
      'tenkhoahoc': courseName,
      'diem_chuyencan': attendanceScore,
      'diem_giuaky': midtermScore,
      'diem_cuoiky': finalScore,
      'diem_tongket': finalGrade,
      'xeploai': classification,
      'ngay_chamdiem_cuoicung': lastGradedDate?.toIso8601String(),
      'trangthai_hoantat': completionStatus,
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
