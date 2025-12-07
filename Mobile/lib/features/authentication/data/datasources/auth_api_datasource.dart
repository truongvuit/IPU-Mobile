import 'package:dio/dio.dart';
import '../../../../core/api/dio_client.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthApiDataSource {
  Future<AuthTokensModel> login(String email, String password);
  Future<void> logout();
  Future<AuthTokensModel> refreshToken(String refreshToken);
  Future<void> forgotPassword(String email);
  Future<bool> verifyResetCode(String code);
  Future<void> resendCode(String email);
  Future<void> resetPassword({
    required String code,
    required String newPassword,
    required String confirmPassword,
  });
  Future<UserModel> getCurrentUser();

  
  
  @Deprecated('Backend endpoint not implemented')
  Future<void> changePassword(String currentPassword, String newPassword);
}

class AuthApiDataSourceImpl implements AuthApiDataSource {
  final DioClient dioClient;

  AuthApiDataSourceImpl({required this.dioClient});

  @override
  Future<AuthTokensModel> login(String email, String password) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.login,
        data: {'identifier': email, 'password': password},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return AuthTokensModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Login failed');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Login failed');
    }
  }

  @override
  Future<void> logout() async {
    try {
      await dioClient.post(ApiEndpoints.logout);
    } catch (e) {
      throw const ServerException('Logout failed');
    }
  }

  @override
  Future<AuthTokensModel> refreshToken(String refreshToken) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': refreshToken},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return AuthTokensModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          response.data['message'] ?? 'Token refresh failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Token refresh failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Token refresh failed');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email': email},
      );

      if (response.statusCode != 200 || response.data['code'] != 1000) {
        throw ServerException(
          response.data['message'] ?? 'Forgot password failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Forgot password failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('Forgot password failed');
    }
  }

  @override
  Future<bool> verifyResetCode(String code) async {
    try {
      
      final response = await dioClient.get(
        '/auth/verify-reset-code',
        queryParameters: {'code': code},
      );

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return true;
      }
      throw ServerException(
        response.data['message'] ?? 'Invalid verification code',
      );
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Verification failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('Verify code failed');
    }
  }

  @override
  Future<void> resendCode(String email) async {
    await forgotPassword(email);
  }

  @override
  Future<void> resetPassword({
    required String code,
    required String newPassword,
    required String confirmPassword,
  }) async {
    try {
      final response = await dioClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'code': code,
          'newPassword': newPassword,
          'confirmPassword': confirmPassword,
        },
      );

      if (response.statusCode != 200 || response.data['code'] != 1000) {
        throw ServerException(
          response.data['message'] ?? 'Reset password failed',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Reset password failed',
        );
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('Reset password failed');
    }
  }

  @override
  Future<UserModel> getCurrentUser() async {
    try {
      final response = await dioClient.get(ApiEndpoints.userProfile);

      if (response.statusCode == 200 && response.data['code'] == 1000) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(response.data['message'] ?? 'Get user failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(e.response!.data['message'] ?? 'Get user failed');
      }
      throw ServerException(e.message ?? 'Network error');
    } catch (e) {
      throw const ServerException('Get user failed');
    }
  }

  @override
  Future<void> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    
    
    throw const ServerException(
      'Chức năng đổi mật khẩu chưa được hỗ trợ. '
      'Vui lòng sử dụng chức năng "Quên mật khẩu" để đặt lại mật khẩu.',
    );

    /* FUTURE IMPLEMENTATION - Uncomment when backend adds /auth/change-password:
    try {
      final response = await dioClient.post(
        ApiEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
          'confirmPassword': newPassword,
        },
      );

      if (response.statusCode != 200 || response.data['code'] != 1000) {
        throw ServerException(
          response.data['message'] ?? 'Đổi mật khẩu thất bại',
        );
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        throw ServerException(
          e.response!.data['message'] ?? 'Đổi mật khẩu thất bại',
        );
      }
      throw ServerException(e.message ?? 'Lỗi kết nối');
    } catch (e) {
      if (e is ServerException) rethrow;
      throw const ServerException('Đổi mật khẩu thất bại');
    }
    */
  }
}
