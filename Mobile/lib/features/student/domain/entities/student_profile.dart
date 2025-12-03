import 'package:equatable/equatable.dart';

class StudentProfile extends Equatable {
  final String id;
  final String studentCode;
  final String fullName;
  final String? avatarUrl;
  final DateTime? dateOfBirth;
  final String? gender;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? currentClass;
  final double gpa;
  final int totalCredits;
  final int activeCourses;

  const StudentProfile({
    required this.id,
    required this.studentCode,
    required this.fullName,
    this.avatarUrl,
    this.dateOfBirth,
    this.gender,
    this.email,
    this.phoneNumber,
    this.address,
    this.currentClass,
    this.gpa = 0.0,
    this.totalCredits = 0,
    this.activeCourses = 0,
  });

  @override
  List<Object?> get props => [
    id,
    studentCode,
    fullName,
    avatarUrl,
    dateOfBirth,
    gender,
    email,
    phoneNumber,
    address,
    currentClass,
    gpa,
    totalCredits,
    activeCourses,
  ];

  StudentProfile copyWith({
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
    return StudentProfile(
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
