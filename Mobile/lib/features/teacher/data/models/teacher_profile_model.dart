import '../../domain/entities/teacher_profile.dart';


class TeacherProfileModel extends TeacherProfile {
  const TeacherProfileModel({
    required super.id,
    required super.teacherCode,
    required super.fullName,
    super.avatarUrl,
    super.dateOfBirth,
    super.gender,
    super.email,
    super.phoneNumber,
    super.address,
    super.specialization,
    super.certificates,
    super.totalClasses,
    super.totalStudents,
    super.rating,
  });

  
  
  factory TeacherProfileModel.fromJson(Map<String, dynamic> json) {
    
    List<String> certs = [];
    if (json['qualifications'] != null && json['qualifications'] is List) {
      certs = (json['qualifications'] as List)
          .map((q) {
            
            final degreeName = q['degreeName'] ?? '';
            final level = q['level'] ?? '';
            return level.isNotEmpty ? '$degreeName ($level)' : degreeName;
          })
          .where((s) => s.isNotEmpty)
          .map((e) => e.toString())
          .toList();
    } else if (json['certificates'] != null) {
      if (json['certificates'] is List) {
        certs = (json['certificates'] as List)
            .map((e) => e.toString())
            .toList();
      }
    } else if (json['bangCap'] != null && json['bangCap'] is List) {
      certs = (json['bangCap'] as List).map((e) => e.toString()).toList();
    }

    return TeacherProfileModel(
      id:
          json['lecturerId']?.toString() ??
          json['maGiangVien']?.toString() ??
          '',
      teacherCode:
          json['teacherCode'] ??
          json['lecturerId']?.toString() ??
          json['maGiangVien'] ??
          '',
      fullName: json['fullName'] ?? json['hoTen'] ?? '',
      
      avatarUrl: json['imagePath'] ?? json['avatarUrl'] ?? json['hinhAnh'],
      dateOfBirth: json['dateOfBirth'] != null
          ? DateTime.parse(json['dateOfBirth'])
          : json['ngaySinh'] != null
          ? DateTime.parse(json['ngaySinh'])
          : null,
      gender: json['gender'] ?? json['gioiTinh'],
      email: json['email'],
      phoneNumber: json['phoneNumber'] ?? json['soDienThoai'],
      address: json['address'] ?? json['diaChi'],
      specialization: json['specialization'] ?? json['chuyenMon'],
      certificates: certs,
      
      totalClasses: json['totalClasses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
    );
  }

  
  Map<String, dynamic> toJson() {
    return {
      'lecturerId': id,
      'teacherCode': teacherCode,
      'fullName': fullName,
      'avatarUrl': avatarUrl,
      'dateOfBirth': dateOfBirth?.toIso8601String(),
      'gender': gender,
      'email': email,
      'phoneNumber': phoneNumber,
      'address': address,
      'specialization': specialization,
      'certificates': certificates,
      'totalClasses': totalClasses,
      'totalStudents': totalStudents,
      'rating': rating,
    };
  }

  factory TeacherProfileModel.fromEntity(TeacherProfile profile) {
    return TeacherProfileModel(
      id: profile.id,
      teacherCode: profile.teacherCode,
      fullName: profile.fullName,
      avatarUrl: profile.avatarUrl,
      dateOfBirth: profile.dateOfBirth,
      gender: profile.gender,
      email: profile.email,
      phoneNumber: profile.phoneNumber,
      address: profile.address,
      specialization: profile.specialization,
      certificates: profile.certificates,
      totalClasses: profile.totalClasses,
      totalStudents: profile.totalStudents,
      rating: profile.rating,
    );
  }

  @override
  TeacherProfileModel copyWith({
    String? id,
    String? teacherCode,
    String? fullName,
    String? avatarUrl,
    DateTime? dateOfBirth,
    String? gender,
    String? email,
    String? phoneNumber,
    String? address,
    String? specialization,
    List<String>? certificates,
    int? totalClasses,
    int? totalStudents,
    double? rating,
  }) {
    return TeacherProfileModel(
      id: id ?? this.id,
      teacherCode: teacherCode ?? this.teacherCode,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      gender: gender ?? this.gender,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      address: address ?? this.address,
      specialization: specialization ?? this.specialization,
      certificates: certificates ?? this.certificates,
      totalClasses: totalClasses ?? this.totalClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      rating: rating ?? this.rating,
    );
  }
}
