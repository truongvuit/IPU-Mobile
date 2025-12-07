enum PaymentMethod {
  cash, 
  transfer, 
  card,
  vnpay,
}

class QuickRegistration {
  final String? id;
  final String studentName;
  final String? studentGroup;
  final String phoneNumber;
  final String? email;
  final String classId;
  final String className;
  
  final double tuitionFee;
  
  final double discount;
  
  
  final double? finalAmount;
  final String? promotionCode;
  final PaymentMethod paymentMethod;
  final String? notes;
  final DateTime registrationDate;
  final String? status;
  final int? invoiceId;

  const QuickRegistration({
    this.id,
    required this.studentName,
    this.studentGroup,
    required this.phoneNumber,
    this.email,
    required this.classId,
    required this.className,
    required this.tuitionFee,
    this.discount = 0,
    this.finalAmount,
    this.promotionCode,
    required this.paymentMethod,
    this.notes,
    required this.registrationDate,
    this.status,
    this.invoiceId,
  });

  
  double get totalAmount => finalAmount ?? (tuitionFee - discount);

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.transfer:
        return 'Chuyển khoản';
      case PaymentMethod.card:
        return 'Quét thẻ';
      case PaymentMethod.vnpay:
        return 'VNPay';
    }
  }

  QuickRegistration copyWith({
    String? id,
    String? studentName,
    String? studentGroup,
    String? phoneNumber,
    String? email,
    String? classId,
    String? className,
    double? tuitionFee,
    double? discount,
    double? finalAmount,
    String? promotionCode,
    PaymentMethod? paymentMethod,
    String? notes,
    DateTime? registrationDate,
    String? status,
    int? invoiceId,
  }) {
    return QuickRegistration(
      id: id ?? this.id,
      studentName: studentName ?? this.studentName,
      studentGroup: studentGroup ?? this.studentGroup,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      tuitionFee: tuitionFee ?? this.tuitionFee,
      discount: discount ?? this.discount,
      finalAmount: finalAmount ?? this.finalAmount,
      promotionCode: promotionCode ?? this.promotionCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
      invoiceId: invoiceId ?? this.invoiceId,
    );
  }
}
