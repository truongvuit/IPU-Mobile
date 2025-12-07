import '../../domain/entities/course_detail.dart';

class CourseObjectiveModel extends CourseObjective {
  const CourseObjectiveModel({required super.id, required super.name});

  factory CourseObjectiveModel.fromJson(Map<String, dynamic> json) {
    return CourseObjectiveModel(
      id: json['id'] ?? 0,
      name: json['objectiveName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'objectiveName': name};
}

class ModuleContentModel extends ModuleContent {
  const ModuleContentModel({required super.id, required super.name});

  factory ModuleContentModel.fromJson(Map<String, dynamic> json) {
    return ModuleContentModel(
      id: json['id'] ?? 0,
      name: json['contentName'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {'id': id, 'contentName': name};
}

class ModuleDocumentModel extends ModuleDocument {
  const ModuleDocumentModel({
    required super.id,
    super.fileName,
    super.link,
    super.description,
    super.image,
  });

  factory ModuleDocumentModel.fromJson(Map<String, dynamic> json) {
    return ModuleDocumentModel(
      id: json['documentId'] ?? 0,
      fileName: json['fileName'],
      link: json['link'],
      description: json['description'],
      image: json['image'],
    );
  }

  Map<String, dynamic> toJson() => {
    'documentId': id,
    'fileName': fileName,
    'link': link,
    'description': description,
    'image': image,
  };
}

class CourseModuleModel extends CourseModule {
  const CourseModuleModel({
    required super.id,
    required super.name,
    super.duration,
    super.contents,
    super.documents,
  });

  factory CourseModuleModel.fromJson(Map<String, dynamic> json) {
    final contentsList = json['contents'] as List? ?? [];
    final documentsList = json['documents'] as List? ?? [];

    return CourseModuleModel(
      id: json['moduleId'] ?? 0,
      name: json['moduleName'] ?? '',
      duration: json['duration'],
      contents: contentsList
          .map((c) => ModuleContentModel.fromJson(c as Map<String, dynamic>))
          .toList(),
      documents: documentsList
          .map((d) => ModuleDocumentModel.fromJson(d as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'moduleId': id,
    'moduleName': name,
    'duration': duration,
    'contents': (contents as List<ModuleContentModel>)
        .map((c) => c.toJson())
        .toList(),
    'documents': (documents as List<ModuleDocumentModel>)
        .map((d) => d.toJson())
        .toList(),
  };
}

class CourseClassInfoModel extends CourseClassInfo {
  const CourseClassInfoModel({
    required super.classId,
    required super.className,
    super.courseName,
    super.roomName,
    super.instructorName,
    super.startDate,
    super.endDate,
    super.schedulePattern,
    super.status,
    super.maxCapacity,
    super.currentEnrollment,
    super.tuitionFee,
  });

  factory CourseClassInfoModel.fromJson(Map<String, dynamic> json) {
    return CourseClassInfoModel(
      classId: json['classId'] ?? 0,
      className: json['className'] ?? '',
      courseName: json['courseName'],
      roomName: json['roomName'],
      instructorName: json['instructorName'],
      startDate: json['startDate'] != null
          ? DateTime.tryParse(json['startDate'].toString())
          : null,
      endDate: json['endDate'] != null
          ? DateTime.tryParse(json['endDate'].toString())
          : null,
      schedulePattern: json['schedulePattern'],
      status: json['status'],
      maxCapacity: json['maxCapacity'],
      currentEnrollment: json['currentEnrollment'],
      tuitionFee: json['tuitionFee']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
    'classId': classId,
    'className': className,
    'courseName': courseName,
    'roomName': roomName,
    'instructorName': instructorName,
    'startDate': startDate?.toIso8601String(),
    'endDate': endDate?.toIso8601String(),
    'schedulePattern': schedulePattern,
    'status': status,
    'maxCapacity': maxCapacity,
    'currentEnrollment': currentEnrollment,
    'tuitionFee': tuitionFee,
  };
}

class CourseDetailModel extends CourseDetail {
  const CourseDetailModel({
    required super.id,
    required super.name,
    required super.totalHours,
    required super.tuitionFee,
    super.promotionPrice,
    super.videoUrl,
    required super.isActive,
    required super.createdAt,
    super.createdBy,
    super.imageUrl,
    super.description,
    super.entryRequirement,
    super.exitRequirement,
    super.categoryId,
    super.categoryName,
    super.level,
    super.totalClasses,
    super.activeClasses,
    super.totalStudents,
    super.totalRevenue,
    super.averageRating,
    super.reviewCount,
    super.objectives,
    super.modules,
    super.classInfos,
  });

  factory CourseDetailModel.fromJson(Map<String, dynamic> json) {
    return CourseDetailModel(
      id: json['makhoahoc']?.toString() ?? '',
      name: json['tenkhoahoc']?.toString() ?? '',
      totalHours: int.tryParse(json['sogiohoc']?.toString() ?? '0') ?? 0,
      tuitionFee: double.tryParse(json['hocphi']?.toString() ?? '0') ?? 0.0,
      videoUrl: json['video']?.toString(),
      isActive: json['trangthai'] == true || json['trangthai'] == 1,
      createdAt: json['ngaytao'] != null
          ? DateTime.tryParse(json['ngaytao'].toString()) ?? DateTime.now()
          : DateTime.now(),
      createdBy: json['nguoitao']?.toString(),
      imageUrl: json['hinhanh']?.toString(),
      description: json['mota']?.toString(),
      entryRequirement: json['dauvao']?.toString(),
      exitRequirement: json['daura']?.toString(),
      categoryId: json['madanhmuc']?.toString(),
      categoryName: json['danhmuc']?.toString(),
      level: json['level']?.toString(),
      totalClasses: int.tryParse(json['tong_so_lop']?.toString() ?? '0') ?? 0,
      activeClasses:
          int.tryParse(json['so_lop_dangmo']?.toString() ?? '0') ?? 0,
      totalStudents: int.tryParse(json['tong_hocvien']?.toString() ?? '0') ?? 0,
      totalRevenue:
          double.tryParse(json['tong_doanhthu']?.toString() ?? '0') ?? 0.0,
      averageRating:
          double.tryParse(json['diem_danhgia_tb']?.toString() ?? '0') ?? 0.0,
      reviewCount:
          int.tryParse(json['so_luong_danhgia']?.toString() ?? '0') ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'makhoahoc': id,
      'tenkhoahoc': name,
      'sogiohoc': totalHours,
      'hocphi': tuitionFee,
      'video': videoUrl,
      'trangthai': isActive,
      'ngaytao': createdAt.toIso8601String(),
      'nguoitao': createdBy,
      'hinhanh': imageUrl,
      'mota': description,
      'dauvao': entryRequirement,
      'daura': exitRequirement,
      'madanhmuc': categoryId,
      'danhmuc': categoryName,
      'level': level,
      'tong_so_lop': totalClasses,
      'so_lop_dangmo': activeClasses,
      'tong_hocvien': totalStudents,
      'tong_doanhthu': totalRevenue,
      'diem_danhgia_tb': averageRating,
      'so_luong_danhgia': reviewCount,
    };
  }

  CourseDetail toEntity() {
    return CourseDetail(
      id: id,
      name: name,
      totalHours: totalHours,
      tuitionFee: tuitionFee,
      promotionPrice: promotionPrice,
      videoUrl: videoUrl,
      isActive: isActive,
      createdAt: createdAt,
      createdBy: createdBy,
      imageUrl: imageUrl,
      description: description,
      entryRequirement: entryRequirement,
      exitRequirement: exitRequirement,
      categoryId: categoryId,
      categoryName: categoryName,
      level: level,
      totalClasses: totalClasses,
      activeClasses: activeClasses,
      totalStudents: totalStudents,
      totalRevenue: totalRevenue,
      averageRating: averageRating,
      reviewCount: reviewCount,
      objectives: objectives,
      modules: modules,
      classInfos: classInfos,
    );
  }

  factory CourseDetailModel.fromEntity(CourseDetail entity) {
    return CourseDetailModel(
      id: entity.id,
      name: entity.name,
      totalHours: entity.totalHours,
      tuitionFee: entity.tuitionFee,
      promotionPrice: entity.promotionPrice,
      videoUrl: entity.videoUrl,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      createdBy: entity.createdBy,
      imageUrl: entity.imageUrl,
      description: entity.description,
      entryRequirement: entity.entryRequirement,
      exitRequirement: entity.exitRequirement,
      categoryId: entity.categoryId,
      categoryName: entity.categoryName,
      level: entity.level,
      totalClasses: entity.totalClasses,
      activeClasses: entity.activeClasses,
      totalStudents: entity.totalStudents,
      totalRevenue: entity.totalRevenue,
      averageRating: entity.averageRating,
      reviewCount: entity.reviewCount,
      objectives: entity.objectives,
      modules: entity.modules,
      classInfos: entity.classInfos,
    );
  }
}

class UpdateCourseRequest {
  final String name;
  final int totalHours;
  final double tuitionFee;
  final String? videoUrl;
  final String? imageUrl;
  final String? description;
  final String? entryRequirement;
  final String? exitRequirement;
  final String? categoryId;
  final bool isActive;

  const UpdateCourseRequest({
    required this.name,
    required this.totalHours,
    required this.tuitionFee,
    this.videoUrl,
    this.imageUrl,
    this.description,
    this.entryRequirement,
    this.exitRequirement,
    this.categoryId,
    required this.isActive,
  });

  Map<String, dynamic> toJson() {
    final json = <String, dynamic>{
      'tenkhoahoc': name,
      'sogiohoc': totalHours,
      'hocphi': tuitionFee,
      'trangthai': isActive,
    };

    // Only include optional fields if they have values
    if (videoUrl != null && videoUrl!.isNotEmpty) {
      json['video'] = videoUrl;
    }
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      json['hinhanh'] = imageUrl;
    }
    if (description != null && description!.isNotEmpty) {
      json['mota'] = description;
    }
    if (entryRequirement != null && entryRequirement!.isNotEmpty) {
      json['dauvao'] = entryRequirement;
    }
    if (exitRequirement != null && exitRequirement!.isNotEmpty) {
      json['daura'] = exitRequirement;
    }
    if (categoryId != null) {
      json['madanhmuc'] = categoryId;
    }

    return json;
  }

  factory UpdateCourseRequest.fromCourseDetail(CourseDetail course) {
    return UpdateCourseRequest(
      name: course.name,
      totalHours: course.totalHours,
      tuitionFee: course.tuitionFee,
      videoUrl: course.videoUrl,
      imageUrl: course.imageUrl,
      description: course.description,
      entryRequirement: course.entryRequirement,
      exitRequirement: course.exitRequirement,
      categoryId: course.categoryId,
      isActive: course.isActive,
    );
  }
}
