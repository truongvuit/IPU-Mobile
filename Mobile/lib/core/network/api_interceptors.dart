import 'dart:async';
import 'package:dio/dio.dart';
import 'dart:developer';
import '../config/environment.dart';
import '../auth/token_store.dart';
import '../auth/session_expiry_notifier.dart';
import 'api_exception.dart';


class AuthInterceptor extends Interceptor {
  final TokenStore tokenStore;
  final Dio dio;
  final SessionExpiryNotifier sessionExpiryNotifier;

  
  Future<String?>? _refreshFuture;
  bool _isRefreshing = false;

  AuthInterceptor({
    required this.tokenStore,
    required this.dio,
    SessionExpiryNotifier? sessionExpiryNotifier,
  }) : sessionExpiryNotifier = sessionExpiryNotifier ?? SessionExpiryNotifier();

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await tokenStore.getAccessToken();
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    
    // Skip token refresh for auth endpoints
    final path = err.requestOptions.path;
    if (path.contains('/auth/refreshtoken') ||
        path.contains('/auth/login') ||
        path.contains('/auth/signin') ||
        path.contains('/auth/register') ||
        path.contains('/auth/signup') ||
        path.contains('/auth/logout')) {
      return handler.next(err);
    }

    
    if (err.response?.statusCode == 401) {
      try {
        
        String? newToken;
        if (_isRefreshing && _refreshFuture != null) {
          newToken = await _refreshFuture;
        } else {
          
          _refreshFuture = _performRefresh();
          newToken = await _refreshFuture;
        }

        if (newToken != null) {
          
          final requestOptions = err.requestOptions;
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final retryResponse = await dio.fetch(requestOptions);
          return handler.resolve(retryResponse);
        } else {
          
          return handler.reject(err);
        }
      } catch (e) {
        return handler.reject(err);
      }
    }
    super.onError(err, handler);
  }

  
  Future<String?> _performRefresh() async {
    if (_isRefreshing) {
      return _refreshFuture;
    }

    _isRefreshing = true;
    try {
      final refreshToken = await tokenStore.getRefreshToken();
      if (refreshToken == null || refreshToken.isEmpty) {
        await _handleRefreshFailure();
        return null;
      }

      
      final response = await dio.post(
        '/auth/refreshtoken',
        data: {'refreshToken': refreshToken},
        options: Options(headers: {'Authorization': ''}),
      );

      final newAccessToken = response.data['data']['accessToken'];
      final newRefreshToken = response.data['data']['refreshToken'];

      
      await tokenStore.saveAccessToken(newAccessToken);
      await tokenStore.saveRefreshToken(newRefreshToken);

      return newAccessToken;
    } catch (e) {
      await _handleRefreshFailure();
      return null;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  
  Future<void> _handleRefreshFailure() async {
    await tokenStore.clearTokens();
    sessionExpiryNotifier.notifySessionExpired();
  }
}


class LoggingInterceptor extends Interceptor {
  final Environment environment;

  LoggingInterceptor({required this.environment});

  
  Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '[REDACTED]';
    }
    return sanitized;
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (Environment.enableLogging) {
      log('═══ REQUEST ═══');
      log('${options.method} ${options.uri}');
      log('Headers: ${_sanitizeHeaders(options.headers)}');
      if (options.data != null) {
        
        final dataStr = options.data.toString();
        if (dataStr.contains('password') || dataStr.contains('Token')) {
          log('Body: [REDACTED - contains sensitive data]');
        } else {
          log('Body: ${options.data}');
        }
      }
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (Environment.enableLogging) {
      log('═══ RESPONSE ═══');
      log('${response.statusCode} ${response.requestOptions.uri}');
      
      final dataStr = response.data.toString();
      if (dataStr.contains('Token') || dataStr.contains('accessToken')) {
        log('Data: [REDACTED - contains token]');
      } else {
        log('Data: ${response.data}');
      }
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (Environment.enableLogging) {
      log('═══ ERROR ═══');
      log('${err.response?.statusCode} ${err.requestOptions.uri}');
      log('Message: ${err.message}');
      
      if (err.response?.data != null) {
        final dataStr = err.response?.data.toString() ?? '';
        if (!dataStr.contains('Token') && !dataStr.contains('password')) {
          log('Data: ${err.response?.data}');
        }
      }
    }
    super.onError(err, handler);
  }
}


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
