import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../auth/token_store.dart';
import '../auth/session_expiry_notifier.dart';
import 'api_interceptors.dart';

class DioConfig {
  final TokenStore tokenStore;
  final Environment environment;
  final SessionExpiryNotifier sessionExpiryNotifier;

  DioConfig({
    required this.tokenStore,
    required this.environment,
    SessionExpiryNotifier? sessionExpiryNotifier,
  }) : sessionExpiryNotifier = sessionExpiryNotifier ?? SessionExpiryNotifier();

  Dio createDio() {
    final dio = Dio(
      BaseOptions(
        baseUrl: Environment.baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'X-Client-Type': 'mobile', 
        },
      ),
    );

    
    dio.interceptors.addAll([
      AuthInterceptor(
        tokenStore: tokenStore,
        dio: dio,
        sessionExpiryNotifier: sessionExpiryNotifier,
      ),
      LoggingInterceptor(environment: environment),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
