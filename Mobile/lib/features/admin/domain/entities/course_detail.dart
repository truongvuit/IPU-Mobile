import 'package:equatable/equatable.dart';


class CourseObjective extends Equatable {
  final int id;
  final String name;

  const CourseObjective({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}


class ModuleContent extends Equatable {
  final int id;
  final String name;

  const ModuleContent({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}


class ModuleDocument extends Equatable {
  final int id;
  final String? fileName;
  final String? link;
  final String? description;
  final String? image;

  const ModuleDocument({
    required this.id,
    this.fileName,
    this.link,
    this.description,
    this.image,
  });

  @override
  List<Object?> get props => [id, fileName, link, description, image];
}


class CourseModule extends Equatable {
  final int id;
  final String name;
  final int? duration;
  final List<ModuleContent> contents;
  final List<ModuleDocument> documents;

  const CourseModule({
    required this.id,
    required this.name,
    this.duration,
    this.contents = const [],
    this.documents = const [],
  });

  @override
  List<Object?> get props => [id, name, duration, contents, documents];
}


class CourseClassInfo extends Equatable {
  final int classId;
  final String className;
  final String? courseName;
  final String? roomName;
  final String? instructorName;
  final DateTime? startDate;
  final DateTime? endDate;
  final String? schedulePattern;
  final String? status;
  final int? maxCapacity;
  final int? currentEnrollment;
  final double? tuitionFee;

  const CourseClassInfo({
    required this.classId,
    required this.className,
    this.courseName,
    this.roomName,
    this.instructorName,
    this.startDate,
    this.endDate,
    this.schedulePattern,
    this.status,
    this.maxCapacity,
    this.currentEnrollment,
    this.tuitionFee,
  });

  bool get isActive => status == 'InProgress' || status == 'ongoing';

  String get enrollmentText =>
      '${currentEnrollment ?? 0}/${maxCapacity ?? 0} học viên';

  @override
  List<Object?> get props => [
    classId,
    className,
    courseName,
    roomName,
    instructorName,
    startDate,
    endDate,
    schedulePattern,
    status,
    maxCapacity,
    currentEnrollment,
    tuitionFee,
  ];
}

class CourseDetail extends Equatable {
  final String id;
  final String name;
  final int totalHours;
  final double tuitionFee;
  final double? promotionPrice;
  final String? videoUrl;
  final bool isActive;
  final DateTime createdAt;
  final String? createdBy;
  final String? imageUrl;
  final String? description;
  final String? entryRequirement;
  final String? exitRequirement;

  final String? categoryId;
  final String? categoryName;
  final String? level;

  final int totalClasses;
  final int activeClasses;
  final int totalStudents;
  final double totalRevenue;
  final double averageRating;
  final int reviewCount;

  
  final List<CourseObjective> objectives;
  final List<CourseModule> modules;
  final List<CourseClassInfo> classInfos;

  const CourseDetail({
    required this.id,
    required this.name,
    required this.totalHours,
    required this.tuitionFee,
    this.promotionPrice,
    this.videoUrl,
    required this.isActive,
    required this.createdAt,
    this.createdBy,
    this.imageUrl,
    this.description,
    this.entryRequirement,
    this.exitRequirement,
    this.categoryId,
    this.categoryName,
    this.level,
    this.totalClasses = 0,
    this.activeClasses = 0,
    this.totalStudents = 0,
    this.totalRevenue = 0.0,
    this.averageRating = 0.0,
    this.reviewCount = 0,
    this.objectives = const [],
    this.modules = const [],
    this.classInfos = const [],
  });

  bool get isActiveStatus => isActive;

  bool get hasActiveClasses => activeClasses > 0;

  bool get hasStudents => totalStudents > 0;

  bool get canDelete => activeClasses == 0;

  String get statusText => isActive ? 'Đang mở' : 'Đã đóng';

  String get statusColor => isActive ? '#4CAF50' : '#9E9E9E';

  String get formattedTuitionFee {
    if (tuitionFee >= 1000000) {
      return '${(tuitionFee / 1000000).toStringAsFixed(1)}tr';
    }
    return '${tuitionFee.toStringAsFixed(0)}đ';
  }

  String get formattedRevenue {
    if (totalRevenue >= 1000000000) {
      return '${(totalRevenue / 1000000000).toStringAsFixed(1)}tỷ';
    } else if (totalRevenue >= 1000000) {
      return '${(totalRevenue / 1000000).toStringAsFixed(1)}tr';
    }
    return '${totalRevenue.toStringAsFixed(0)}đ';
  }

  double get ratingStars => averageRating;

  String get ratingColor {
    if (averageRating >= 4.5) return '#4CAF50';
    if (averageRating >= 4.0) return '#2196F3';
    if (averageRating >= 3.0) return '#FF9800';
    return '#F44336';
  }

  String get levelBadgeColor {
    switch (level?.toUpperCase()) {
      case 'A1':
      case 'A2':
        return '#4CAF50';
      case 'B1':
      case 'B2':
        return '#2196F3';
      case 'C1':
      case 'C2':
        return '#9C27B0';
      default:
        return '#9E9E9E';
    }
  }

  @override
  List<Object?> get props => [
    id,
    name,
    totalHours,
    tuitionFee,
    promotionPrice,
    videoUrl,
    isActive,
    createdAt,
    createdBy,
    imageUrl,
    description,
    entryRequirement,
    exitRequirement,
    categoryId,
    categoryName,
    level,
    totalClasses,
    activeClasses,
    totalStudents,
    totalRevenue,
    averageRating,
    reviewCount,
    objectives,
    modules,
    classInfos,
  ];

  CourseDetail copyWith({
    String? id,
    String? name,
    int? totalHours,
    double? tuitionFee,
    double? promotionPrice,
    String? videoUrl,
    bool? isActive,
    DateTime? createdAt,
    String? createdBy,
    String? imageUrl,
    String? description,
    String? entryRequirement,
    String? exitRequirement,
    String? categoryId,
    String? categoryName,
    String? level,
    int? totalClasses,
    int? activeClasses,
    int? totalStudents,
    double? totalRevenue,
    double? averageRating,
    int? reviewCount,
    List<CourseObjective>? objectives,
    List<CourseModule>? modules,
    List<CourseClassInfo>? classInfos,
  }) {
    return CourseDetail(
      id: id ?? this.id,
      name: name ?? this.name,
      totalHours: totalHours ?? this.totalHours,
      tuitionFee: tuitionFee ?? this.tuitionFee,
      promotionPrice: promotionPrice ?? this.promotionPrice,
      videoUrl: videoUrl ?? this.videoUrl,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      createdBy: createdBy ?? this.createdBy,
      imageUrl: imageUrl ?? this.imageUrl,
      description: description ?? this.description,
      entryRequirement: entryRequirement ?? this.entryRequirement,
      exitRequirement: exitRequirement ?? this.exitRequirement,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      level: level ?? this.level,
      totalClasses: totalClasses ?? this.totalClasses,
      activeClasses: activeClasses ?? this.activeClasses,
      totalStudents: totalStudents ?? this.totalStudents,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      averageRating: averageRating ?? this.averageRating,
      reviewCount: reviewCount ?? this.reviewCount,
      objectives: objectives ?? this.objectives,
      modules: modules ?? this.modules,
      classInfos: classInfos ?? this.classInfos,
    );
  }
}
