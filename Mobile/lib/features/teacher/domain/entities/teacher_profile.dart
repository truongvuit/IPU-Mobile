import 'package:equatable/equatable.dart';


class TeacherProfile extends Equatable {
  final String id;
  final String teacherCode;
  final String fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? specialization; 
  final List<String> certificates;
  final int totalClasses;
  final int totalStudents;
  final double rating;

  const TeacherProfile({
    required this.id,
    required this.teacherCode,
    required this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.phoneNumber,
    this.address,
    this.specialization,
    this.certificates = const [],
    this.totalClasses = 0,
    this.totalStudents = 0,
    this.rating = 0.0,
  });

  @override
  List<Object?> get props => [
        id,
        teacherCode,
        fullName,
        avatarUrl,
        dateOfBirth,
        gender,
        email,
        phoneNumber,
        address,
        specialization,
        certificates,
        totalClasses,
        totalStudents,
        rating,
      ];

  TeacherProfile copyWith({
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
    return TeacherProfile(
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
