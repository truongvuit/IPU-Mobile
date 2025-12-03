import 'package:equatable/equatable.dart';

class AdminCourse extends Equatable {
  final String id;
  final String name;
  final String description;
  final String level;
  final double tuitionFee;
  final int durationWeeks;
  final int totalClasses;
  final int activeClasses;
  final int totalStudents;
  final double rating;
  final String? imageUrl;

  const AdminCourse({
    required this.id,
    required this.name,
    required this.description,
    required this.level,
    required this.tuitionFee,
    required this.durationWeeks,
    this.totalClasses = 0,
    this.activeClasses = 0,
    this.totalStudents = 0,
    this.rating = 0.0,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    level,
    tuitionFee,
    durationWeeks,
    totalClasses,
    activeClasses,
    totalStudents,
    rating,
    imageUrl,
  ];

  factory AdminCourse.fromJson(Map<String, dynamic> json) {
    return AdminCourse(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      level: json['level'] ?? '',
      tuitionFee: (json['tuitionFee'] ?? 0).toDouble(),
      durationWeeks: json['durationWeeks'] ?? 0,
      totalClasses: json['totalClasses'] ?? 0,
      activeClasses: json['activeClasses'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      rating: (json['rating'] ?? 0.0).toDouble(),
      imageUrl: json['imageUrl'],
    );
  }
}
