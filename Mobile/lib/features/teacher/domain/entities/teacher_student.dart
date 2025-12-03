import 'package:equatable/equatable.dart';

class TeacherStudent extends Equatable {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final String? avatar;
  final String? studentCode;
  final double? averageScore;

  const TeacherStudent({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.avatar,
    this.studentCode,
    this.averageScore,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    email,
    phone,
    avatar,
    studentCode,
    averageScore,
  ];
}
