import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import 'api_interceptors.dart';

class DioConfig {
  final SharedPreferences sharedPreferences;
  final Environment environment;

  DioConfig({required this.sharedPreferences, required this.environment});

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
        },
      ),
    );

    // Add interceptors in order
    dio.interceptors.addAll([
      AuthInterceptor(sharedPreferences: sharedPreferences, dio: dio),
      LoggingInterceptor(environment: environment),
      ErrorInterceptor(),
    ]);

    return dio;
  }
}
