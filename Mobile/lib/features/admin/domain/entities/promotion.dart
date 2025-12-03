import 'package:equatable/equatable.dart';

enum DiscountType { percentage, fixedAmount }

enum PromotionStatus { active, scheduled, expired, draft }

/// Loại khuyến mãi: đơn lẻ hoặc combo
enum PromotionType { 
  single,  // Áp dụng cho 1 hoặc nhiều khóa, chọn 1 khóa là được
  combo,   // Phải chọn đúng tất cả các khóa trong combo mới áp dụng được
}

class Promotion extends Equatable {
  final String id;
  final String code;
  final String title;
  final String description;
  final DiscountType discountType;
  final double discountValue;
  final DateTime startDate;
  final DateTime endDate;
  final int? usageLimit;
  final int usageCount;
  final PromotionStatus status;
  final double? minOrderValue;
  final List<String>? applicableCourseIds;
  final List<String>? applicableCourseNames;
  final PromotionType promotionType; // Loại khuyến mãi
  final bool requireAllCourses; // true nếu phải chọn tất cả khóa trong danh sách

  const Promotion({
    required this.id,
    required this.code,
    required this.title,
    required this.description,
    required this.discountType,
    required this.discountValue,
    required this.startDate,
    required this.endDate,
    this.usageLimit,
    this.usageCount = 0,
    required this.status,
    this.minOrderValue,
    this.applicableCourseIds,
    this.applicableCourseNames,
    this.promotionType = PromotionType.single,
    this.requireAllCourses = false,
  });

  @override
  List<Object?> get props => [
    id,
    code,
    title,
    description,
    discountType,
    discountValue,
    startDate,
    endDate,
    usageLimit,
    usageCount,
    status,
    minOrderValue,
    applicableCourseIds,
    applicableCourseNames,
    promotionType,
    requireAllCourses,
  ];

  bool get isValid {
    final now = DateTime.now();
    return status == PromotionStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || usageCount < usageLimit!);
  }

  /// Kiểm tra xem khuyến mãi có thể áp dụng cho danh sách khóa học đã chọn không
  bool canApplyForCourses(List<String> selectedCourseIds) {
    if (!isValid) return false;
    
    // Nếu không có ràng buộc khóa học, áp dụng cho tất cả
    if (applicableCourseIds == null || applicableCourseIds!.isEmpty) {
      return true;
    }
    
    // Nếu là combo (requireAllCourses = true), phải chọn đúng tất cả khóa
    if (requireAllCourses || promotionType == PromotionType.combo) {
      // Kiểm tra xem tất cả khóa trong combo có được chọn không
      return applicableCourseIds!.every(
        (courseId) => selectedCourseIds.contains(courseId),
      );
    }
    
    // Nếu là single, chỉ cần 1 khóa trong danh sách được chọn
    return selectedCourseIds.any(
      (courseId) => applicableCourseIds!.contains(courseId),
    );
  }

  double calculateDiscount(double originalPrice) {
    if (minOrderValue != null && originalPrice < minOrderValue!) {
      return 0;
    }
    if (discountType == DiscountType.percentage) {
      return originalPrice * (discountValue / 100);
    } else {
      return discountValue;
    }
  }
}
