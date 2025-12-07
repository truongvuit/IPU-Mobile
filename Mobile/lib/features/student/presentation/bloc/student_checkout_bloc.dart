import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/datasources/student_api_datasource.dart';
import '../../domain/entities/student_cart_preview.dart';
import 'student_checkout_event.dart';
import 'student_checkout_state.dart';


class StudentCheckoutBloc
    extends Bloc<StudentCheckoutEvent, StudentCheckoutState> {
  final StudentApiDataSource apiDataSource;

  StudentCheckoutBloc({required this.apiDataSource})
    : super(const StudentCheckoutInitial()) {
    on<LoadCartPreview>(_onLoadCartPreview);
    on<CreateOrder>(_onCreateOrder);
    on<ResetCheckout>(_onResetCheckout);
  }

  Future<void> _onLoadCartPreview(
    LoadCartPreview event,
    Emitter<StudentCheckoutState> emit,
  ) async {
    emit(const StudentCheckoutLoading());

    try {
      final cartPreview = await apiDataSource.getCartPreview(event.classIds);
      emit(StudentCheckoutPreviewLoaded(cartPreview: cartPreview));
    } catch (e) {
      
      final userMessage = _getUserFriendlyErrorMessage(
        e,
        'Không thể tải thông tin giỏ hàng',
      );
      emit(StudentCheckoutError(message: userMessage));
    }
  }

  Future<void> _onCreateOrder(
    CreateOrder event,
    Emitter<StudentCheckoutState> emit,
  ) async {
    final currentState = state;
    StudentCartPreview? cartPreview;

    if (currentState is StudentCheckoutPreviewLoaded) {
      cartPreview = currentState.cartPreview;
    }

    emit(
      StudentCheckoutCreatingOrder(
        cartPreview:
            cartPreview ??
            const StudentCartPreview(
              items: [],
              summary: StudentCartSummary(
                totalTuitionFee: 0,
                totalDiscount: 0,
                totalAmount: 0,
              ),
            ),
      ),
    );

    try {
      final orderResult = await apiDataSource.createOrder(
        classIds: event.classIds,
      );

      
      final totalAmount = (orderResult['totalAmount'] as num).toDouble();
      final paymentResult = await apiDataSource.createPayment(
        invoiceId: orderResult['invoiceId'] as int,
        totalAmount: totalAmount,
      );

      emit(
        StudentCheckoutOrderCreated(
          invoiceId: orderResult['invoiceId'] as int,
          totalAmount: (orderResult['totalAmount'] as num).toDouble(),
          
          paymentUrl: paymentResult['payUrl'] as String,
        ),
      );
    } catch (e) {
      
      final userMessage = _getUserFriendlyErrorMessage(
        e,
        'Không thể tạo đơn hàng',
      );
      emit(
        StudentCheckoutError(message: userMessage, cartPreview: cartPreview),
      );
    }
  }

  void _onResetCheckout(
    ResetCheckout event,
    Emitter<StudentCheckoutState> emit,
  ) {
    emit(const StudentCheckoutInitial());
  }

  
  
  String _getUserFriendlyErrorMessage(dynamic error, String defaultMessage) {
    
    if (error is Exception) {
      final errorStr = error.toString();
      
      if (errorStr.contains('SocketException') ||
          errorStr.contains('Connection refused')) {
        return '$defaultMessage. Vui lòng kiểm tra kết nối mạng.';
      }
      if (errorStr.contains('TimeoutException')) {
        return '$defaultMessage. Yêu cầu đã hết thời gian, vui lòng thử lại.';
      }
      if (errorStr.contains('ServerException')) {
        
        final msgMatch = RegExp(
          r'ServerException:\s*(.+)',
        ).firstMatch(errorStr);
        if (msgMatch != null && msgMatch.group(1) != null) {
          final serverMsg = msgMatch.group(1)!;
          
          if (serverMsg.contains('lỗi') ||
              serverMsg.contains('không') ||
              serverMsg.contains('thất bại')) {
            return serverMsg;
          }
        }
      }
    }
    
    return '$defaultMessage. Vui lòng thử lại sau.';
  }
}
