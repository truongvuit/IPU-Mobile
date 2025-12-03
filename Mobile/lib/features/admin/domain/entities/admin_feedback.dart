import 'package:equatable/equatable.dart';

class AdminFeedback extends Equatable {
  final String id;
  final String studentName;
  final String? studentAvatar;
  final double rating;
  final String comment;
  final DateTime createdAt;
  final String className;
  final double? teacherRating;
  final double? facilityRating;
  final double? overallRating;

  const AdminFeedback({
    required this.id,
    required this.studentName,
    this.studentAvatar,
    required this.rating,
    required this.comment,
    required this.createdAt,
    required this.className,
    this.teacherRating,
    this.facilityRating,
    this.overallRating,
  });

  @override
  List<Object?> get props => [
    id,
    studentName,
    studentAvatar,
    rating,
    comment,
    createdAt,
    className,
    teacherRating,
    facilityRating,
    overallRating,
  ];

  factory AdminFeedback.fromJson(Map<String, dynamic> json) {
    // Calculate rating from averageRating or individual ratings
    double rating = 0.0;
    if (json['averageRating'] != null) {
      rating = (json['averageRating'] as num).toDouble();
    } else if (json['rating'] != null) {
      rating = (json['rating'] as num).toDouble();
    } else {
      // Calculate from individual ratings if available
      final teacherRating = (json['teacherRating'] as num?)?.toDouble() ?? 0.0;
      final facilityRating = (json['facilityRating'] as num?)?.toDouble() ?? 0.0;
      final overallRating = (json['overallRating'] as num?)?.toDouble() ?? 0.0;
      int count = 0;
      double sum = 0;
      if (teacherRating > 0) { sum += teacherRating; count++; }
      if (facilityRating > 0) { sum += facilityRating; count++; }
      if (overallRating > 0) { sum += overallRating; count++; }
      if (count > 0) rating = sum / count;
    }

    return AdminFeedback(
      id: (json['reviewId'] ?? json['id'] ?? '').toString(),
      studentName: json['studentName'] ?? 'Ẩn danh',
      studentAvatar: json['studentAvatar'],
      rating: rating,
      comment: json['comment'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      className: json['className'] ?? '',
      teacherRating: (json['teacherRating'] as num?)?.toDouble(),
      facilityRating: (json['facilityRating'] as num?)?.toDouble(),
      overallRating: (json['overallRating'] as num?)?.toDouble(),
    );
  }
}
