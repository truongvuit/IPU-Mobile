import '../../domain/entities/admin_student.dart';

class AdminStudentModel extends AdminStudent {
  const AdminStudentModel({
    required super.id,
    required super.fullName,
    required super.email,
    required super.phoneNumber,
    super.avatarUrl,
    super.dateOfBirth,
    super.address,
    super.occupation,
    super.educationLevel,
    required super.enrollmentDate,
    required super.totalClassesEnrolled,
    required super.enrolledClassIds,
  });

  factory AdminStudentModel.fromJson(Map<String, dynamic> json) {
    return AdminStudentModel(
      id: json['id']?.toString() ?? json['mahocvien']?.toString() ?? '',
      fullName: json['fullName'] as String? ?? json['hoten'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber:
          json['phoneNumber'] as String? ?? json['sdt'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String? ?? json['anhdaidien'] as String?,
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.tryParse(json['dateOfBirth'].toString())
          : (json['ngaysinh'] != null
                ? DateTime.tryParse(json['ngaysinh'].toString())
                : null),
      address: json['address'] as String? ?? json['diachi'] as String?,
      occupation:
          json['occupation'] as String? ?? json['nghenghiep'] as String?,
      educationLevel:
          json['educationLevel'] as String? ?? json['trinhdo'] as String?,
      enrollmentDate:
          DateTime.tryParse(
            json['enrollmentDate'] as String? ??
                json['ngaydangky'] as String? ??
                '',
          ) ??
          DateTime.now(),
      totalClassesEnrolled:
          json['totalClassesEnrolled'] as int? ??
          json['solophocdangky'] as int? ??
          0,
      enrolledClassIds:
          (json['enrolledClassIds'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          (json['danhsachlophoc'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'address': address,
      'occupation': occupation,
      'educationLevel': educationLevel,
      'enrollmentDate': enrollmentDate.toIso8601String(),
      'totalClassesEnrolled': totalClassesEnrolled,
      'enrolledClassIds': enrolledClassIds,
    };
  }

  
  
  Map<String, dynamic> toUpdateJson() {
    return {
      'fullName': fullName,
      'email': email,
      'phoneNumber': phoneNumber,
      'dateOfBirth': dateOfBirth?.toIso8601String().split(
        'T',
      )[0], 
      'address': address,
      'occupation': occupation,
      'educationLevel': educationLevel,
      'avatarUrl': avatarUrl,
      
    };
  }

  factory AdminStudentModel.fromEntity(AdminStudent entity) {
    return AdminStudentModel(
      id: entity.id,
      fullName: entity.fullName,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      avatarUrl: entity.avatarUrl,
      dateOfBirth: entity.dateOfBirth,
      address: entity.address,
      occupation: entity.occupation,
      educationLevel: entity.educationLevel,
      enrollmentDate: entity.enrollmentDate,
      totalClassesEnrolled: entity.totalClassesEnrolled,
      enrolledClassIds: entity.enrolledClassIds,
    );
  }

  AdminStudent toEntity() {
    return AdminStudent(
      id: id,
      fullName: fullName,
      email: email,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
      dateOfBirth: dateOfBirth,
      address: address,
      occupation: occupation,
      educationLevel: educationLevel,
      enrollmentDate: enrollmentDate,
      totalClassesEnrolled: totalClassesEnrolled,
      enrolledClassIds: enrolledClassIds,
    );
  }
}
