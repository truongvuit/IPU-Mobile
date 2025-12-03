import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import '../network/dio_config.dart';

class DioClient {
  late final Dio dio;
  final SharedPreferences sharedPreferences;
  final Environment environment;

  DioClient({required this.sharedPreferences, Environment? environment})
    : environment = environment ?? Environment.current {
    final dioConfig = DioConfig(
      sharedPreferences: sharedPreferences,
      environment: this.environment,
    );
    dio = dioConfig.createDio();
  }

  /// Get the base URL for the API
  String get baseUrl => Environment.baseUrl;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PATCH request
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.patch(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      if (data != null) ...data,
    });

    return await dio.post(path, data: formData);
  }
}
