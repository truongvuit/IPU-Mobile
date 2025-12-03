import '../../domain/entities/promotion.dart';

class PromotionModel extends Promotion {
  const PromotionModel({
    required super.id,
    required super.code,
    required super.title,
    required super.description,
    required super.discountType,
    required super.discountValue,
    required super.startDate,
    required super.endDate,
    super.usageLimit,
    super.usageCount,
    required super.status,
    super.minOrderValue,
    super.applicableCourseIds,
    super.applicableCourseNames,
    super.promotionType,
    super.requireAllCourses,
  });

  factory PromotionModel.fromJson(Map<String, dynamic> json) {
    // Parse promotion type
    PromotionType promotionType = PromotionType.single;
    if (json['promotionType'] != null) {
      promotionType = PromotionType.values.firstWhere(
        (e) => e.toString().split('.').last == json['promotionType'],
        orElse: () => PromotionType.single,
      );
    }
    // Nếu requireAllCourses = true, tự động set thành combo
    final requireAllCourses = json['requireAllCourses'] as bool? ?? false;
    if (requireAllCourses) {
      promotionType = PromotionType.combo;
    }

    return PromotionModel(
      id: json['id']?.toString() ?? '',
      code: json['code'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      discountType: DiscountType.values.firstWhere(
        (e) => e.toString().split('.').last == json['discountType'],
        orElse: () => DiscountType.fixedAmount,
      ),
      discountValue: (json['discountValue'] as num?)?.toDouble() ?? 0.0,
      startDate:
          DateTime.tryParse(json['startDate'] as String? ?? '') ??
          DateTime.now(),
      endDate:
          DateTime.tryParse(json['endDate'] as String? ?? '') ?? DateTime.now(),
      usageLimit: json['usageLimit'] as int?,
      usageCount: json['usageCount'] as int? ?? 0,
      status: PromotionStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => PromotionStatus.draft,
      ),
      minOrderValue: (json['minOrderValue'] as num?)?.toDouble(),
      applicableCourseIds: (json['applicableCourseIds'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      applicableCourseNames: (json['applicableCourseNames'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(),
      promotionType: promotionType,
      requireAllCourses: requireAllCourses,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'code': code,
      'title': title,
      'description': description,
      'discountType': discountType.toString().split('.').last,
      'discountValue': discountValue,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'usageLimit': usageLimit,
      'usageCount': usageCount,
      'status': status.toString().split('.').last,
      'minOrderValue': minOrderValue,
      'applicableCourseIds': applicableCourseIds,
      'applicableCourseNames': applicableCourseNames,
      'promotionType': promotionType.toString().split('.').last,
      'requireAllCourses': requireAllCourses,
    };
  }

  factory PromotionModel.fromEntity(Promotion entity) {
    return PromotionModel(
      id: entity.id,
      code: entity.code,
      title: entity.title,
      description: entity.description,
      discountType: entity.discountType,
      discountValue: entity.discountValue,
      startDate: entity.startDate,
      endDate: entity.endDate,
      usageLimit: entity.usageLimit,
      usageCount: entity.usageCount,
      status: entity.status,
      minOrderValue: entity.minOrderValue,
      applicableCourseIds: entity.applicableCourseIds,
      applicableCourseNames: entity.applicableCourseNames,
      promotionType: entity.promotionType,
      requireAllCourses: entity.requireAllCourses,
    );
  }
}
