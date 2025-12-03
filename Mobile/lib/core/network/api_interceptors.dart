import 'package:dio/dio.dart';
import 'dart:developer';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import 'api_exception.dart';

/// Interceptor để tự động thêm Authorization header
class AuthInterceptor extends Interceptor {
  final SharedPreferences sharedPreferences;
  final Dio dio;

  // Sử dụng cùng key với AuthLocalDataSource
  static const String _accessTokenKey = 'auth_token';
  static const String _refreshTokenKey = 'refresh_token';

  AuthInterceptor({required this.sharedPreferences, required this.dio});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final token = sharedPreferences.getString(_accessTokenKey);
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    // Handle 401 Unauthorized - Refresh token
    if (err.response?.statusCode == 401) {
      final refreshToken = sharedPreferences.getString(_refreshTokenKey);
      if (refreshToken != null && refreshToken.isNotEmpty) {
        try {
          // Gọi API refresh token
          final response = await dio.post(
            '/auth/refreshtoken',
            data: {'refreshToken': refreshToken},
            options: Options(headers: {'Authorization': ''}),
          );

          final newAccessToken = response.data['data']['accessToken'];
          final newRefreshToken = response.data['data']['refreshToken'];

          // Lưu token mới
          await sharedPreferences.setString(_accessTokenKey, newAccessToken);
          await sharedPreferences.setString(_refreshTokenKey, newRefreshToken);

          // Retry request với token mới
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } catch (e) {
          // Refresh token failed - logout user
          await sharedPreferences.remove(_accessTokenKey);
          await sharedPreferences.remove(_refreshTokenKey);
          return handler.reject(err);
        }
      }
    }
    super.onError(err, handler);
  }
}

/// Interceptor để log requests/responses (chỉ dùng trong development)
class LoggingInterceptor extends Interceptor {
  final Environment environment;

  LoggingInterceptor({required this.environment});

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Environment.enableLogging) {
      log('═══ REQUEST ═══');
      log('${options.method} ${options.uri}');
      log('Headers: ${options.headers}');
      if (options.data != null) log('Body: ${options.data}');
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Environment.enableLogging) {
      log('═══ RESPONSE ═══');
      log('${response.statusCode} ${response.requestOptions.uri}');
      log('Data: ${response.data}');
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Environment.enableLogging) {
      log('═══ ERROR ═══');
      log('${err.response?.statusCode} ${err.requestOptions.uri}');
      log('Message: ${err.message}');
      log('Data: ${err.response?.data}');
    }
    super.onError(err, handler);
  }
}

/// Interceptor để handle errors và convert sang ApiException
class ErrorInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final apiException = _handleError(err);
    return handler.reject(
      DioException(
        requestOptions: err.requestOptions,
        response: err.response,
        type: err.type,
        error: apiException,
      ),
    );
  }

  ApiException _handleError(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException.timeout(message: 'Kết nối quá thời gian chờ');

      case DioExceptionType.badResponse:
        final statusCode = error.response?.statusCode;
        final data = error.response?.data;

        if (statusCode == 400) {
          return ApiException.badRequest(
            message: data?['message'] ?? 'Dữ liệu không hợp lệ',
          );
        } else if (statusCode == 401) {
          return ApiException.unauthorized(message: 'Phiên đăng nhập hết hạn');
        } else if (statusCode == 403) {
          return ApiException.forbidden(message: 'Bạn không có quyền truy cập');
        } else if (statusCode == 404) {
          return ApiException.notFound(message: 'Không tìm thấy dữ liệu');
        } else if (statusCode != null && statusCode >= 500) {
          return ApiException.serverError(
            message: 'Lỗi máy chủ, vui lòng thử lại sau',
          );
        }
        return ApiException.unknown(
          message: data?['message'] ?? 'Đã xảy ra lỗi',
        );

      case DioExceptionType.cancel:
        return ApiException.requestCancelled(message: 'Yêu cầu đã bị hủy');

      case DioExceptionType.connectionError:
      case DioExceptionType.unknown:
      default:
        return ApiException.noInternetConnection(
          message: 'Không có kết nối internet',
        );
    }
  }
}
