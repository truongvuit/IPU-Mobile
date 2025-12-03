import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/errors/exceptions.dart';
import '../models/auth_tokens_model.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveTokens(AuthTokensModel tokens);
  Future<AuthTokensModel?> getTokens();
  Future<void> clearTokens();
  Future<void> saveUser(UserModel user);
  Future<UserModel?> getUser();
  Future<void> clearUser();
  Future<void> setRememberMe(bool value);
  Future<bool> getRememberMe();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<void> saveTokens(AuthTokensModel tokens) async {
    await sharedPreferences.setString(
      AppConstants.keyAuthToken,
      tokens.accessToken,
    );
    await sharedPreferences.setString(
      AppConstants.keyRefreshToken,
      tokens.refreshToken,
    );
  }

  @override
  Future<AuthTokensModel?> getTokens() async {
    final accessToken = sharedPreferences.getString(AppConstants.keyAuthToken);
    final refreshToken = sharedPreferences.getString(AppConstants.keyRefreshToken);

    if (accessToken != null && refreshToken != null) {
      return AuthTokensModel(
        accessToken: accessToken,
        refreshToken: refreshToken,
      );
    }
    return null;
  }

  @override
  Future<void> clearTokens() async {
    await sharedPreferences.remove(AppConstants.keyAuthToken);
    await sharedPreferences.remove(AppConstants.keyRefreshToken);
  }

  @override
  Future<void> saveUser(UserModel user) async {
    await sharedPreferences.setString(
      AppConstants.keyUserId,
      json.encode(user.toJson()),
    );
  }

  @override
  Future<UserModel?> getUser() async {
    final userJson = sharedPreferences.getString(AppConstants.keyUserId);
    if (userJson != null) {
      try {
        return UserModel.fromJson(json.decode(userJson));
      } catch (e) {
        throw const CacheException('Failed to parse user data');
      }
    }
    return null;
  }

  @override
  Future<void> clearUser() async {
    await sharedPreferences.remove(AppConstants.keyUserId);
  }

  @override
  Future<void> setRememberMe(bool value) async {
    await sharedPreferences.setBool(AppConstants.keyRememberMe, value);
  }

  @override
  Future<bool> getRememberMe() async {
    return sharedPreferences.getBool(AppConstants.keyRememberMe) ?? false;
  }
}
