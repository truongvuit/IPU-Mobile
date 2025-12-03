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
  Future<void> forgotPassword(String emailOrPhone);
  Future<void> verifyCode(String code, String emailOrPhone);
  Future<void> resendCode(String emailOrPhone);
  Future<void> resetPassword(
    String newPassword,
    String verificationCode,
    String emailOrPhone,
  );
  Future<UserModel> getCurrentUser();
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
  Future<void> forgotPassword(String emailOrPhone) async {
    try {
      await dioClient.post(
        ApiEndpoints.forgotPassword,
        data: {'email_or_phone': emailOrPhone},
      );
    } catch (e) {
      throw const ServerException('Forgot password failed');
    }
  }

  @override
  Future<void> verifyCode(String code, String emailOrPhone) async {
    try {
      await dioClient.post(
        ApiEndpoints.verifyCode,
        data: {'code': code, 'email_or_phone': emailOrPhone},
      );
    } catch (e) {
      throw const ServerException('Verify code failed');
    }
  }

  @override
  Future<void> resendCode(String emailOrPhone) async {
    await forgotPassword(emailOrPhone);
  }

  @override
  Future<void> resetPassword(
    String newPassword,
    String verificationCode,
    String emailOrPhone,
  ) async {
    try {
      await dioClient.post(
        ApiEndpoints.resetPassword,
        data: {
          'new_password': newPassword,
          'verification_code': verificationCode,
          'email_or_phone': emailOrPhone,
        },
      );
    } catch (e) {
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
    try {
      await dioClient.post(
        ApiEndpoints.changePassword,
        data: {
          'current_password': currentPassword,
          'new_password': newPassword,
        },
      );
    } catch (e) {
      throw const ServerException('Change password failed');
    }
  }
}
