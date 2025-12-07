import 'payment_api_data_source.dart';
import '../domain/vnpay_models.dart';





class VNPayService {
  final PaymentApiDataSource paymentApiDataSource;

  VNPayService({required this.paymentApiDataSource});

  
  
  
  
  
  
  
  
  
  Future<String> createPaymentUrl({
    required int invoiceId,
    required int amount,
    String? orderInfo,
    required String userRole,
  }) async {
    try {
      final request = VNPayCreatePaymentRequest(
        invoiceId: invoiceId,
        amount: amount.toString(),
        orderInfo: orderInfo ?? 'Thanh toán hóa đơn #$invoiceId',
      );

      final response = await paymentApiDataSource.createVNPayPayment(
        request,
        userRole: userRole,
      );

      if (response.payUrl.isEmpty) {
        throw Exception('Không nhận được URL thanh toán từ server');
      }

      return response.payUrl;
    } catch (e) {
      throw Exception('Không thể tạo thanh toán: ${e.toString()}');
    }
  }

  
  
  
  
  
  Future<VNPayCreatePaymentResponse> createPayment({
    required int invoiceId,
    required int amount,
    String? orderInfo,
    required String userRole,
  }) async {
    final request = VNPayCreatePaymentRequest(
      invoiceId: invoiceId,
      amount: amount.toString(),
      orderInfo: orderInfo ?? 'Thanh toán hóa đơn #$invoiceId',
    );

    return await paymentApiDataSource.createVNPayPayment(
      request,
      userRole: userRole,
    );
  }
}
