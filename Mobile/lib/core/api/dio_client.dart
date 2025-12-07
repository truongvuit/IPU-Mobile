import 'package:dio/dio.dart';
import '../config/environment.dart';
import '../auth/token_store.dart';
import '../auth/session_expiry_notifier.dart';
import '../network/dio_config.dart';
import '../network/error_handler.dart';
import '../errors/exceptions.dart';

class DioClient {
  late final Dio dio;
  final TokenStore tokenStore;
  final Environment environment;
  final SessionExpiryNotifier sessionExpiryNotifier;

  DioClient({
    required this.tokenStore,
    Environment? environment,
    SessionExpiryNotifier? sessionExpiryNotifier,
  }) : environment = environment ?? Environment.current,
       sessionExpiryNotifier =
           sessionExpiryNotifier ?? SessionExpiryNotifier() {
    final dioConfig = DioConfig(
      tokenStore: tokenStore,
      environment: this.environment,
      sessionExpiryNotifier: this.sessionExpiryNotifier,
    );
    dio = dioConfig.createDio();
  }

  
  String get baseUrl => Environment.baseUrl;

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.get(
        path,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.put(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  
  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    try {
      return await dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: options,
      );
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getUserFriendlyMessage(e));
    }
  }

  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
  }) async {
    try {
      final formData = FormData.fromMap({
        fieldName: await MultipartFile.fromFile(filePath),
        if (data != null) ...data,
      });

      return await dio.post(path, data: formData);
    } on DioException catch (e) {
      throw ServerException(ErrorHandler.getUserFriendlyMessage(e));
    }
  }
}
