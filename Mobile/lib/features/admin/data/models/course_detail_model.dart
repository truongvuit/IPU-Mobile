import '../../domain/entities/course_detail.dart';

class CourseDetailModel extends CourseDetail {
  const CourseDetailModel({
    required super.id,
    required super.name,
    required super.totalHours,
    required super.tuitionFee,
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
    );
  }

  factory CourseDetailModel.fromEntity(CourseDetail entity) {
    return CourseDetailModel(
      id: entity.id,
      name: entity.name,
      totalHours: entity.totalHours,
      tuitionFee: entity.tuitionFee,
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
    return {
      'tenkhoahoc': name,
      'sogiohoc': totalHours,
      'hocphi': tuitionFee,
      'video': videoUrl,
      'hinhanh': imageUrl,
      'mota': description,
      'dauvao': entryRequirement,
      'daura': exitRequirement,
      'madanhmuc': categoryId,
      'trangthai': isActive,
    };
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
