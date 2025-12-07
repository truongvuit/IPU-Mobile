


class CartPreview {
  final List<CartPreviewItem> items;
  final CartPreviewSummary summary;

  const CartPreview({required this.items, required this.summary});

  factory CartPreview.fromJson(Map<String, dynamic> json) {
    return CartPreview(
      items:
          (json['items'] as List<dynamic>?)
              ?.map(
                (item) =>
                    CartPreviewItem.fromJson(item as Map<String, dynamic>),
              )
              .toList() ??
          [],
      summary: CartPreviewSummary.fromJson(
        json['summary'] as Map<String, dynamic>? ?? {},
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((item) => item.toJson()).toList(),
    'summary': summary.toJson(),
  };

  
  bool get hasSingleCourseDiscount => summary.totalSingleCourseDiscount > 0;

  
  bool get hasComboDiscount => summary.appliedCombos.isNotEmpty;

  
  bool get hasReturningDiscount => summary.returningDiscountAmount > 0;

  
  bool get hasAnyDiscount => summary.totalDiscountAmount > 0;
}

class CartPreviewItem {
  final int courseClassId;
  final String courseName;
  final String className;
  final double tuitionFee;              
  final double singleCourseDiscount;    
  final int singleCourseDiscountPercent; 
  final double originalPrice;            
  final double finalPrice;

  const CartPreviewItem({
    required this.courseClassId,
    required this.courseName,
    required this.className,
    required this.tuitionFee,
    required this.singleCourseDiscount,
    required this.singleCourseDiscountPercent,
    required this.originalPrice,
    required this.finalPrice,
  });

  factory CartPreviewItem.fromJson(Map<String, dynamic> json) {
    return CartPreviewItem(
      courseClassId: json['courseClassId'] as int? ?? 0,
      courseName: json['courseName'] as String? ?? '',
      className: json['className'] as String? ?? '',
      tuitionFee: _parseDouble(json['tuitionFee']),
      singleCourseDiscount: _parseDouble(json['singleCourseDiscount']),
      singleCourseDiscountPercent: json['singleCourseDiscountPercent'] as int? ?? 0,
      originalPrice: _parseDouble(json['originalPrice']),
      finalPrice: _parseDouble(json['finalPrice']),
    );
  }

  Map<String, dynamic> toJson() => {
    'courseClassId': courseClassId,
    'courseName': courseName,
    'className': className,
    'tuitionFee': tuitionFee,
    'singleCourseDiscount': singleCourseDiscount,
    'singleCourseDiscountPercent': singleCourseDiscountPercent,
    'originalPrice': originalPrice,
    'finalPrice': finalPrice,
  };

  
  bool get hasSingleCourseDiscount => singleCourseDiscount > 0;

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class CartPreviewSummary {
  final double totalTuitionFee;           
  final double totalSingleCourseDiscount; 
  final double totalOriginalPrice;        
  final double totalComboDiscount;        
  final List<ComboDiscountInfo> appliedCombos;
  final double returningDiscountAmount;
  final double totalDiscountAmount;       
  final double finalAmount;

  const CartPreviewSummary({
    required this.totalTuitionFee,
    required this.totalSingleCourseDiscount,
    required this.totalOriginalPrice,
    required this.totalComboDiscount,
    required this.appliedCombos,
    required this.returningDiscountAmount,
    required this.totalDiscountAmount,
    required this.finalAmount,
  });

  factory CartPreviewSummary.fromJson(Map<String, dynamic> json) {
    return CartPreviewSummary(
      totalTuitionFee: _parseDouble(json['totalTuitionFee']),
      totalSingleCourseDiscount: _parseDouble(json['totalSingleCourseDiscount']),
      totalOriginalPrice: _parseDouble(json['totalOriginalPrice']),
      totalComboDiscount: _parseDouble(json['totalComboDiscount']),
      appliedCombos:
          (json['appliedCombos'] as List<dynamic>?)
              ?.map(
                (combo) =>
                    ComboDiscountInfo.fromJson(combo as Map<String, dynamic>),
              )
              .toList() ??
          [],
      returningDiscountAmount: _parseDouble(json['returningDiscountAmount']),
      totalDiscountAmount: _parseDouble(json['totalDiscountAmount']),
      finalAmount: _parseDouble(json['finalAmount']),
    );
  }

  Map<String, dynamic> toJson() => {
    'totalTuitionFee': totalTuitionFee,
    'totalSingleCourseDiscount': totalSingleCourseDiscount,
    'totalOriginalPrice': totalOriginalPrice,
    'totalComboDiscount': totalComboDiscount,
    'appliedCombos': appliedCombos.map((combo) => combo.toJson()).toList(),
    'returningDiscountAmount': returningDiscountAmount,
    'totalDiscountAmount': totalDiscountAmount,
    'finalAmount': finalAmount,
  };

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}

class ComboDiscountInfo {
  final String comboName;
  final int discountPercent;
  final double discountAmount;
  final List<String> courseNames;

  const ComboDiscountInfo({
    required this.comboName,
    required this.discountPercent,
    required this.discountAmount,
    required this.courseNames,
  });

  factory ComboDiscountInfo.fromJson(Map<String, dynamic> json) {
    return ComboDiscountInfo(
      comboName: json['comboName'] as String? ?? '',
      discountPercent: json['discountPercent'] as int? ?? 0,
      discountAmount: _parseDouble(json['discountAmount']),
      courseNames:
          (json['courseNames'] as List<dynamic>?)
              ?.map((name) => name.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() => {
    'comboName': comboName,
    'discountPercent': discountPercent,
    'discountAmount': discountAmount,
    'courseNames': courseNames,
  };

  
  String get description {
    if (courseNames.isEmpty) return comboName;
    return '$comboName (${courseNames.join(' + ')})';
  }

  static double _parseDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }
}
