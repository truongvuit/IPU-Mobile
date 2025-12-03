class Environment {
  static const bool useMockData = false;

  static const String baseUrl = 'http://localhost:8080';
  static const String fullApiUrl = '$baseUrl/';

  static const bool enableDebugLogging = true;
  static const bool enableLogging = true;
  static const bool enableAnalytics = false;
  static const bool enableCrashReporting = false;

  static const int connectTimeout = 30;
  static const int receiveTimeout = 30;
  static const int sendTimeout = 30;

  static const String tokenKey = 'auth_token';
  static const String refreshTokenKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String userRoleKey = 'user_role';

  static Environment get current => const Environment._();

  const Environment._();
}
