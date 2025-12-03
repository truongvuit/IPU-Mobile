import 'package:equatable/equatable.dart';

enum DiscountType { percentage, fixedAmount }

enum PromotionStatus { active, scheduled, expired, draft }

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
  ];

  bool get isValid {
    final now = DateTime.now();
    return status == PromotionStatus.active &&
        now.isAfter(startDate) &&
        now.isBefore(endDate) &&
        (usageLimit == null || usageCount < usageLimit!);
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
