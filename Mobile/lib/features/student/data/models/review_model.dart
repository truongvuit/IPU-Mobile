import '../../domain/entities/review.dart';

class ReviewModel extends Review {
  const ReviewModel({
    required super.id,
    required super.classId,
    required super.className,
    required super.courseId,
    required super.courseName,
    super.courseImage,
    super.teacherRating,
    super.facilityRating,
    required super.overallRating,
    super.averageRating,
    super.comment,
    required super.createdAt,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['reviewId'] ?? 0,
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      courseId: json['courseId'] ?? 0,
      courseName: json['courseName'] ?? '',
      courseImage: json['courseImage'],
      teacherRating: json['teacherRating'],
      facilityRating: json['facilityRating'],
      overallRating: json['overallRating'] ?? 0,
      averageRating: json['averageRating']?.toDouble(),
      comment: json['comment'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'reviewId': id,
      'classId': classId,
      'className': className,
      'courseId': courseId,
      'courseName': courseName,
      'courseImage': courseImage,
      'teacherRating': teacherRating,
      'facilityRating': facilityRating,
      'overallRating': overallRating,
      'averageRating': averageRating,
      'comment': comment,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ReviewModel.fromEntity(Review review) {
    return ReviewModel(
      id: review.id,
      classId: review.classId,
      className: review.className,
      courseId: review.courseId,
      courseName: review.courseName,
      courseImage: review.courseImage,
      teacherRating: review.teacherRating,
      facilityRating: review.facilityRating,
      overallRating: review.overallRating,
      averageRating: review.averageRating,
      comment: review.comment,
      createdAt: review.createdAt,
    );
  }

  @override
  ReviewModel copyWith({
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
    return ReviewModel(
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
