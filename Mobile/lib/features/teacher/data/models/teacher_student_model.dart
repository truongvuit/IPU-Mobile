import '../../domain/entities/class_student.dart';

class TeacherStudentModel extends ClassStudent {
  const TeacherStudentModel({
    required super.id,
    required super.studentCode,
    required super.fullName,
    super.avatarUrl,
    super.email,
    super.phoneNumber,
    super.averageScore,
    super.totalAbsences,
    super.totalPresences,
    required super.enrollmentDate,
  });

  factory TeacherStudentModel.fromJson(Map<String, dynamic> json) {
    return TeacherStudentModel(
      id: (json['studentId'] ?? json['id'] ?? 0).toString(),
      studentCode: json['studentCode'] ?? json['maHocVien'] ?? '',
      fullName: json['studentName'] ?? json['fullName'] ?? json['hoTen'] ?? '',
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['soDienThoai'],
      avatarUrl: json['imagePath'] ?? json['avatar'] ?? json['hinhAnh'],
      averageScore: json['averageScore']?.toDouble(),
      totalAbsences: json['totalAbsences'] ?? json['soNgayVang'] ?? 0,
      totalPresences: json['totalPresences'] ?? json['soNgayCoMat'] ?? 0,
      enrollmentDate: json['enrollmentDate'] != null 
          ? DateTime.tryParse(json['enrollmentDate'].toString()) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'studentId': id,
      'studentCode': studentCode,
      'studentName': fullName,
      'email': email,
      if (phoneNumber != null) 'phoneNumber': phoneNumber,
      if (avatarUrl != null) 'imagePath': avatarUrl,
      if (averageScore != null) 'averageScore': averageScore,
      'totalAbsences': totalAbsences,
      'totalPresences': totalPresences,
      'enrollmentDate': enrollmentDate.toIso8601String(),
    };
  }
}
