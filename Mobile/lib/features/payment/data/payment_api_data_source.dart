import 'package:dio/dio.dart';
import 'package:trungtamngoaingu/core/api/dio_client.dart';
import '../domain/vnpay_models.dart';

class PaymentApiDataSource {
  final DioClient dioClient;

  PaymentApiDataSource({required this.dioClient});

  

  
  
  
  Future<VNPayCreatePaymentResponse> createVNPayPayment(
    VNPayCreatePaymentRequest request, {
    required String userRole,
  }) async {
    try {
      
      final response = await dioClient.post(
        '/orders/payment/create?platform=mobile',
        data: request.toJson(),
        
        
        
        
        
        options: Options(
          headers: {'X-Client-Type': 'mobile', 'X-User-Role': userRole},
        ),
      );
      
      final body = response.data is Map<String, dynamic>
          ? response.data as Map<String, dynamic>
          : <String, dynamic>{};
      final data = body['data'] is Map<String, dynamic>
          ? body['data'] as Map<String, dynamic>
          : body;
      return VNPayCreatePaymentResponse.fromJson(data);
    } on DioException catch (e) {
      final errorMessage = e.response?.data?['message'] ?? e.message;
      throw Exception('Không thể tạo thanh toán VNPay: $errorMessage');
    }
  }
}
