import '../../domain/entities/course.dart';


class CourseClassInfoModel extends CourseClassInfo {
  const CourseClassInfoModel({
    required super.classId,
    required super.className,
    super.instructorName,
    super.startDate,
    super.endDate,
    super.schedulePattern,
    super.status,
    super.maxCapacity,
    super.currentEnrollment,
  });

  factory CourseClassInfoModel.fromJson(Map<String, dynamic> json) {
    return CourseClassInfoModel(
      classId: json['classId'] as int,
      className: json['className'] ?? '',
      instructorName: json['instructorName'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : null,
      endDate: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : null,
      schedulePattern: json['schedulePattern'],
      status: json['status'],
      maxCapacity: json['maxCapacity'],
      currentEnrollment: json['currentEnrollment'],
    );
  }
}

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
    super.availableClasses,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    
    List<CourseClassInfo> classes = [];
    if (json['classInfos'] != null) {
      classes = (json['classInfos'] as List)
          .map((c) => CourseClassInfoModel.fromJson(c as Map<String, dynamic>))
          .toList();
    }
    
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
      availableClasses: classes,
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
      availableClasses: course.availableClasses,
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
    List<CourseClassInfo>? availableClasses,
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
      availableClasses: availableClasses ?? this.availableClasses,
    );
  }
}
