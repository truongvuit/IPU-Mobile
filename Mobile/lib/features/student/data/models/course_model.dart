import '../../domain/entities/course.dart';

class CourseModel extends Course {
  const CourseModel({
    required super.id,
    required super.name,
    required super.description,
    required super.imageUrl,
    required super.category,
    required super.price,
    required super.duration,
    super.totalStudents,
    required super.level,
    super.teacherName,
    super.isEnrolled,
    super.startDate,
    super.endDate,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['courseId']?.toString() ?? json['id']?.toString() ?? '',
      name: json['courseName'] ?? json['name'] ?? '',
      description: json['description'] ?? '',
      imageUrl: json['image'] ?? json['imageUrl'] ?? '',
      category: json['categoryName'] ?? json['category'] ?? '',
      price: (json['tuitionFee'] ?? json['price'] ?? 0).toDouble(),
      duration: json['studyHours'] ?? json['duration'] ?? 0,
      totalStudents: json['totalStudents'] ?? 0,
      level: json['entryLevel'] ?? json['level'] ?? 'Beginner',
      teacherName: json['teacherName'],
      isEnrolled: json['isEnrolled'] ?? false,
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'courseId': id,
      'courseName': name,
      'description': description,
      'image': imageUrl,
      'categoryName': category,
      'tuitionFee': price,
      'studyHours': duration,
      'totalStudents': totalStudents,
      'entryLevel': level,
      'teacherName': teacherName,
      'isEnrolled': isEnrolled,
      'startDate': startDate?.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
    };
  }

  factory CourseModel.fromEntity(Course course) {
    return CourseModel(
      id: course.id,
      name: course.name,
      description: course.description,
      imageUrl: course.imageUrl,
      category: course.category,
      price: course.price,
      duration: course.duration,
      totalStudents: course.totalStudents,
      level: course.level,
      teacherName: course.teacherName,
      isEnrolled: course.isEnrolled,
      startDate: course.startDate,
      endDate: course.endDate,
    );
  }

  @override
  CourseModel copyWith({
    String? id,
    String? name,
    String? description,
    String? imageUrl,
    String? category,
    double? price,
    int? duration,
    int? totalStudents,
    String? level,
    String? teacherName,
    bool? isEnrolled,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return CourseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      category: category ?? this.category,
      price: price ?? this.price,
      duration: duration ?? this.duration,
      totalStudents: totalStudents ?? this.totalStudents,
      level: level ?? this.level,
      teacherName: teacherName ?? this.teacherName,
      isEnrolled: isEnrolled ?? this.isEnrolled,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
    );
  }
}
