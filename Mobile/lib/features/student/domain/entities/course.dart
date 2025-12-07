import 'package:equatable/equatable.dart';


class CourseClassInfo extends Equatable {
  final int classId;
  final String className;
  final String? instructorName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? schedulePattern;
  final String? status;
  final int? maxCapacity;
  final int? currentEnrollment;

  const CourseClassInfo({
    required this.classId,
    required this.className,
    this.instructorName,
    this.startDate,
    this.endDate,
    this.schedulePattern,
    this.status,
    this.maxCapacity,
    this.currentEnrollment,
  });

  bool get hasAvailableSlots =>
      maxCapacity == null ||
      currentEnrollment == null ||
      currentEnrollment! < maxCapacity!;

  @override
  List<Object?> get props => [
        classId,
        className,
        instructorName,
        startDate,
        endDate,
        schedulePattern,
        status,
        maxCapacity,
        currentEnrollment,
      ];
}

class Course extends Equatable {
  final String id;
  final String name;
  final String description;
  final String imageUrl;
  final String category;
  final double price;
  final int duration;
  final int totalStudents;
  final String level;
  final String? teacherName;
  final bool isEnrolled;
  final DateTime? startDate;
  final DateTime? endDate;
  final List<CourseClassInfo> availableClasses;

  const Course({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
    required this.category,
    required this.price,
    required this.duration,
    this.totalStudents = 0,
    required this.level,
    this.teacherName,
    this.isEnrolled = false,
    this.startDate,
    this.endDate,
    this.availableClasses = const [],
  });

  
  List<int> get availableClassIds =>
      availableClasses.map((c) => c.classId).toList();

  @override
  List<Object?> get props => [
    id,
    name,
    description,
    imageUrl,
    category,
    price,
    duration,
    totalStudents,
    level,
    teacherName,
    isEnrolled,
    startDate,
    endDate,
    availableClasses,
  ];

  Course copyWith({
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
    return Course(
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
