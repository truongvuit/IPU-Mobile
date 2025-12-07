import 'package:equatable/equatable.dart';



class StudentCartPreview extends Equatable {
  final List<StudentCartItem> items;
  final StudentCartSummary summary;

  const StudentCartPreview({
    required this.items,
    required this.summary,
  });

  factory StudentCartPreview.fromJson(Map<String, dynamic> json) {
    return StudentCartPreview(
      items: (json['items'] as List<dynamic>?)
              ?.map((item) =>
                  StudentCartItem.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      summary: StudentCartSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? json,
      ),
    );
  }

  @override
  List<Object?> get props => [items, summary];
}

class StudentCartItem extends Equatable {
  final int classId;
  final String className;
  final String courseName;
  final double tuitionFee;
  final double discountAmount;
  final double finalAmount;

  const StudentCartItem({
    required this.classId,
    required this.className,
    required this.courseName,
    required this.tuitionFee,
    required this.discountAmount,
    required this.finalAmount,
  });

  factory StudentCartItem.fromJson(Map<String, dynamic> json) {
    final tuition = _parseDouble(json['tuitionFee']);
    final finalAmt = _parseDouble(json['finalPrice'] ?? json['finalAmount']);
    
    return StudentCartItem(
      classId: json['courseClassId'] as int? ?? json['classId'] as int? ?? 0,
      className: json['className'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',
      tuitionFee: tuition,
      discountAmount: tuition - finalAmt,
      finalAmount: finalAmt,
    );
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  @override
  List<Object?> get props => [classId, className, courseName, tuitionFee, discountAmount, finalAmount];
}

class StudentCartSummary extends Equatable {
  final double totalTuitionFee;
  final double totalDiscount;
  final double totalAmount;
  final int courseDiscountPercent;
  final int comboDiscountPercent;
  final int returningStudentDiscountPercent;

  const StudentCartSummary({
    required this.totalTuitionFee,
    required this.totalDiscount,
    required this.totalAmount,
    this.courseDiscountPercent = 0,
    this.comboDiscountPercent = 0,
    this.returningStudentDiscountPercent = 0,
  });

  factory StudentCartSummary.fromJson(Map<String, dynamic> json) {
    final tuition = _parseDouble(json['totalTuitionFee']);
    final finalAmt = _parseDouble(json['finalAmount'] ?? json['totalAmount']);
    final discount = _parseDouble(json['totalDiscountAmount'] ?? json['totalDiscount']);
    
    return StudentCartSummary(
      totalTuitionFee: tuition,
      totalDiscount: discount,
      totalAmount: finalAmt,
      courseDiscountPercent: _parseInt(json['courseDiscountPercent']),
      comboDiscountPercent: _parseInt(json['comboDiscountPercent']),
      returningStudentDiscountPercent: _parseInt(json['returningStudentDiscountPercent']),
    );
  }

  bool get hasAnyDiscount => totalDiscount > 0;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static int _parseInt(dynamic value) {
    if (value == null) return 0;
    if (value is int) return value;
    if (value is double) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  @override
  List<Object?> get props => [
        totalTuitionFee,
        totalDiscount,
        totalAmount,
        courseDiscountPercent,
        comboDiscountPercent,
        returningStudentDiscountPercent,
      ];
}
