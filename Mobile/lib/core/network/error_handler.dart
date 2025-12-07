import 'package:dio/dio.dart';


class ErrorResult {
  final String message;
  final int? code;
  final int? httpStatusCode;

  const ErrorResult({
    required this.message,
    this.code,
    this.httpStatusCode,
  });
}




class ErrorHandler {
  
  static ErrorResult parseError(dynamic error) {
    if (error is DioException) {
      final httpStatus = error.response?.statusCode;
      
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ErrorResult(
            message: 'Lỗi kết nối. Vui lòng kiểm tra mạng và thử lại.',
            httpStatusCode: httpStatus,
          );

        case DioExceptionType.badResponse:
          final data = error.response?.data;
          
          
          if (data is Map<String, dynamic>) {
            final backendCode = data['code'] as int?;
            final backendMessage = data['message']?.toString();
            
            if (backendMessage != null && backendMessage.isNotEmpty) {
              return ErrorResult(
                message: backendMessage,
                code: backendCode,
                httpStatusCode: httpStatus,
              );
            }
          }
          
          
          String message;
          if (httpStatus == 400) {
            message = 'Dữ liệu không hợp lệ';
          } else if (httpStatus == 401) {
            message = 'Phiên đăng nhập hết hạn';
          } else if (httpStatus == 403) {
            message = 'Không có quyền truy cập';
          } else if (httpStatus == 404) {
            message = 'Không tìm thấy dữ liệu';
          } else if (httpStatus == 500) {
            message = 'Lỗi máy chủ. Vui lòng thử lại sau.';
          } else {
            message = 'Đã xảy ra lỗi (mã $httpStatus)';
          }
          
          return ErrorResult(
            message: message,
            httpStatusCode: httpStatus,
          );

        case DioExceptionType.cancel:
          return const ErrorResult(message: 'Yêu cầu đã bị hủy');

        case DioExceptionType.connectionError:
          return const ErrorResult(
            message: 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra kết nối mạng.',
          );

        case DioExceptionType.badCertificate:
          return const ErrorResult(
            message: 'Lỗi bảo mật kết nối. Vui lòng thử lại sau.',
          );

        case DioExceptionType.unknown:
          return const ErrorResult(message: 'Lỗi kết nối. Vui lòng thử lại.');
      }
    }

    
    final message = error.toString();
    if (message.contains('SocketException')) {
      return const ErrorResult(
        message: 'Không thể kết nối mạng. Vui lòng kiểm tra kết nối.',
      );
    }
    if (message.contains('FormatException')) {
      return const ErrorResult(
        message: 'Dữ liệu không hợp lệ. Vui lòng thử lại.',
      );
    }

    return ErrorResult(message: message);
  }

  
  static String getUserFriendlyMessage(dynamic error) {
    return parseError(error).message;
  }

  
  
  
  static int? getBackendErrorCode(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map<String, dynamic>) {
        return data['code'] as int?;
      }
    }
    return null;
  }

  
  static int? getErrorCode(dynamic error) {
    if (error is DioException) {
      return error.response?.statusCode;
    }
    return null;
  }

  
  static bool isNetworkError(dynamic error) {
    if (error is DioException) {
      return error.type == DioExceptionType.connectionTimeout ||
          error.type == DioExceptionType.sendTimeout ||
          error.type == DioExceptionType.receiveTimeout ||
          error.type == DioExceptionType.connectionError;
    }
    return error.toString().contains('SocketException');
  }

  
  static bool isAuthError(dynamic error) {
    if (error is DioException) {
      final statusCode = error.response?.statusCode;
      return statusCode == 401 || statusCode == 403;
    }
    return false;
  }
}
