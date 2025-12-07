import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../constants/app_constants.dart';


abstract class TokenStore {
  Future<void> saveAccessToken(String token);
  Future<void> saveRefreshToken(String token);
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> clearTokens();
}


class SecureTokenStore implements TokenStore {
  final FlutterSecureStorage _secureStorage;

  SecureTokenStore({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
              ),
              iOptions: IOSOptions(
                accessibility: KeychainAccessibility.first_unlock_this_device,
              ),
            );

  @override
  Future<void> saveAccessToken(String token) async {
    await _secureStorage.write(
      key: AppConstants.keyAuthToken,
      value: token,
    );
  }

  @override
  Future<void> saveRefreshToken(String token) async {
    await _secureStorage.write(
      key: AppConstants.keyRefreshToken,
      value: token,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConstants.keyAuthToken);
  }

  @override
  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConstants.keyRefreshToken);
  }

  @override
  Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConstants.keyAuthToken);
    await _secureStorage.delete(key: AppConstants.keyRefreshToken);
  }
}
