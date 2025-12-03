enum PaymentMethod {
  cash, // Tiền mặt
  transfer, // Chuyển khoản
  card, // Quét thẻ
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
  final String? promotionCode;
  final PaymentMethod paymentMethod;
  final String? notes;
  final DateTime registrationDate;
  final String? status;

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
    this.promotionCode,
    required this.paymentMethod,
    this.notes,
    required this.registrationDate,
    this.status,
  });

  double get totalAmount => tuitionFee - discount;

  String get paymentMethodText {
    switch (paymentMethod) {
      case PaymentMethod.cash:
        return 'Tiền mặt';
      case PaymentMethod.transfer:
        return 'Chuyển khoản';
      case PaymentMethod.card:
        return 'Quét thẻ';
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
    String? promotionCode,
    PaymentMethod? paymentMethod,
    String? notes,
    DateTime? registrationDate,
    String? status,
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
      promotionCode: promotionCode ?? this.promotionCode,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      notes: notes ?? this.notes,
      registrationDate: registrationDate ?? this.registrationDate,
      status: status ?? this.status,
    );
  }
}
