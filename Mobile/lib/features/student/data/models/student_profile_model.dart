import '../../domain/entities/student_profile.dart';

class StudentProfileModel extends StudentProfile {
  const StudentProfileModel({
    required super.id,
    required super.studentCode,
    required super.fullName,
    super.avatarUrl,
    super.dateOfBirth,
    super.gender,
    super.email,
    super.phoneNumber,
    super.address,
    super.currentClass,
    super.gpa,
    super.totalCredits,
    super.activeCourses,
  });

  factory StudentProfileModel.fromJson(Map<String, dynamic> json) {
    return StudentProfileModel(
      id:
          json['studentId']?.toString() ??
          json['userId']?.toString() ??
          json['id']?.toString() ??
          '',
      studentCode: json['studentCode'] ?? json['maHocVien'] ?? '',
      fullName: json['name'] ?? json['fullName'] ?? json['hoTen'] ?? '',
      avatarUrl: json['image'] ?? json['avatarUrl'] ?? json['anhDaiDien'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : json['ngaySinh'] != null
          ? DateTime.parse(json['ngaySinh'])
          : null,
      gender: json['gender']?.toString() ?? json['gioiTinh'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['soDienThoai'],
      address: json['address'] ?? json['diaChi'],
      currentClass: json['currentClass'] ?? json['lopHienTai'] ?? json['jobs'],
      gpa: (json['gpa'] ?? 0.0).toDouble(),
      totalCredits: json['totalCredits'] ?? 0,
      activeCourses: json['activeCourses'] ?? 0,
    );
  }

  
  
  Map<String, dynamic> toJson() {
    return {
      'name': fullName,
      'phoneNumber': phoneNumber,
      'address': address,
      'image': avatarUrl,
      'jobs': currentClass, 
      'dateOfBirth': dateOfBirth?.toIso8601String().split('T')[0], 
      'gender': gender == 'Nam' || gender == 'true' ? true : false,
    };
  }

  factory StudentProfileModel.fromEntity(StudentProfile profile) {
    return StudentProfileModel(
      id: profile.id,
      studentCode: profile.studentCode,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      address: profile.address,
      currentClass: profile.currentClass,
      gpa: profile.gpa,
      totalCredits: profile.totalCredits,
      activeCourses: profile.activeCourses,
    );
  }

  @override
  StudentProfileModel copyWith({
    String? id,
    String? studentCode,
    String? fullName,
    String? Function()? avatarUrl,
    DateTime? Function()? dateOfBirth,
    String? Function()? gender,
    String? Function()? email,
    String? Function()? phoneNumber,
    String? Function()? address,
    String? Function()? currentClass,
    double? gpa,
    int? totalCredits,
    int? activeCourses,
  }) {
    return StudentProfileModel(
      id: id ?? this.id,
      studentCode: studentCode ?? this.studentCode,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl != null ? avatarUrl() : this.avatarUrl,
      dateOfBirth: dateOfBirth != null ? dateOfBirth() : this.dateOfBirth,
      gender: gender != null ? gender() : this.gender,
      email: email != null ? email() : this.email,
      phoneNumber: phoneNumber != null ? phoneNumber() : this.phoneNumber,
      address: address != null ? address() : this.address,
      currentClass: currentClass != null ? currentClass() : this.currentClass,
      gpa: gpa ?? this.gpa,
      totalCredits: totalCredits ?? this.totalCredits,
      activeCourses: activeCourses ?? this.activeCourses,
    );
  }
}
