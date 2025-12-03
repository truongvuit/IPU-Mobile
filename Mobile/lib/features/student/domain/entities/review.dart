import 'package:equatable/equatable.dart';

class Review extends Equatable {
  final int id;
  final int classId;
  final String className;
  final int courseId;
  final String courseName;
  final String? courseImage;
  final int? teacherRating;
  final int? facilityRating;
  final int overallRating;
  final double? averageRating;
  final String? comment;
  final DateTime createdAt;

  const Review({
    required this.id,
    required this.classId,
    required this.className,
    required this.courseId,
    required this.courseName,
    this.courseImage,
    this.teacherRating,
    this.facilityRating,
    required this.overallRating,
    this.averageRating,
    this.comment,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    classId,
    className,
    courseId,
    courseName,
    courseImage,
    teacherRating,
    facilityRating,
    overallRating,
    averageRating,
    comment,
    createdAt,
  ];

  Review copyWith({
    int? id,
    int? classId,
    String? className,
    int? courseId,
    String? courseName,
    String? courseImage,
    int? teacherRating,
    int? facilityRating,
    int? overallRating,
    double? averageRating,
    String? comment,
    DateTime? createdAt,
  }) {
    return Review(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      courseImage: courseImage ?? this.courseImage,
      teacherRating: teacherRating ?? this.teacherRating,
      facilityRating: facilityRating ?? this.facilityRating,
      overallRating: overallRating ?? this.overallRating,
      averageRating: averageRating ?? this.averageRating,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
