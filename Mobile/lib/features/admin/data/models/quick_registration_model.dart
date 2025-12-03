import '../../domain/entities/quick_registration.dart';

class QuickRegistrationModel extends QuickRegistration {
  const QuickRegistrationModel({
    super.id,
    required super.studentName,
    super.studentGroup,
    required super.phoneNumber,
    super.email,
    required super.classId,
    required super.className,
    required super.tuitionFee,
    super.discount,
    super.promotionCode,
    required super.paymentMethod,
    super.notes,
    required super.registrationDate,
    super.status,
  });

  factory QuickRegistrationModel.fromJson(Map<String, dynamic> json) {
    return QuickRegistrationModel(
      id: json['id']?.toString(),
      studentName:
          json['studentName'] as String? ?? json['tenhocvien'] as String? ?? '',
      studentGroup:
          json['studentGroup'] as String? ?? json['nhomhocvien'] as String?,
      phoneNumber:
          json['phoneNumber'] as String? ?? json['sdt'] as String? ?? '',
      email: json['email'] as String?,
      classId: json['classId']?.toString() ?? json['malop']?.toString() ?? '',
      className:
          json['className'] as String? ?? json['tenlop'] as String? ?? '',
      tuitionFee:
          (json['tuitionFee'] as num?)?.toDouble() ??
          (json['hocphi'] as num?)?.toDouble() ??
          0,
      discount:
          (json['discount'] as num?)?.toDouble() ??
          (json['giamgia'] as num?)?.toDouble() ??
          0,
      promotionCode:
          json['promotionCode'] as String? ?? json['magiamgia'] as String?,
      paymentMethod: _parsePaymentMethod(
        json['paymentMethod'] as String? ??
            json['phuongthucthanhtoan'] as String?,
      ),
      notes: json['notes'] as String? ?? json['ghichu'] as String?,
      registrationDate:
          DateTime.tryParse(
            json['registrationDate'] as String? ??
                json['ngaydangky'] as String? ??
                '',
          ) ??
          DateTime.now(),
      status: json['status'] as String? ?? json['trangthai'] as String?,
    );
  }

  static PaymentMethod _parsePaymentMethod(String? method) {
    switch (method?.toLowerCase()) {
      case 'cash':
      case 'tiền mặt':
      case 'tienmat':
        return PaymentMethod.cash;
      case 'transfer':
      case 'chuyển khoản':
      case 'chuyenkhoan':
        return PaymentMethod.transfer;
      case 'card':
      case 'quét thẻ':
      case 'the':
        return PaymentMethod.card;
      default:
        return PaymentMethod.cash;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'studentName': studentName,
      'studentGroup': studentGroup,
      'phoneNumber': phoneNumber,
      'email': email,
      'classId': classId,
      'className': className,
      'tuitionFee': tuitionFee,
      'discount': discount,
      'promotionCode': promotionCode,
      'paymentMethod': paymentMethod.name,
      'notes': notes,
      'registrationDate': registrationDate.toIso8601String(),
      'status': status,
    };
  }

  factory QuickRegistrationModel.fromEntity(QuickRegistration entity) {
    return QuickRegistrationModel(
      id: entity.id,
      studentName: entity.studentName,
      studentGroup: entity.studentGroup,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      classId: entity.classId,
      className: entity.className,
      tuitionFee: entity.tuitionFee,
      discount: entity.discount,
      promotionCode: entity.promotionCode,
      paymentMethod: entity.paymentMethod,
      notes: entity.notes,
      registrationDate: entity.registrationDate,
      status: entity.status,
    );
  }
}
