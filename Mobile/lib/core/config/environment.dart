import 'package:flutter/foundation.dart';

// Cấu hình môi trường ứng dụng
class Environment {
  static const bool useMockData = false;

  // For Android Emulator: use 10.0.2.2 (maps to host's localhost)
  // For Physical Device: use your PC's IP (e.g., 192.x.x.x)
  // static const String baseUrl = 'http://192.x.x.x:8080';
  // static const String baseUrl = 'http://10.0.2.2:8080';
  // Dùng dev tunnel URL trực tiếp (không cần 10.0.2.2)

  static String get baseUrl {
    // Dev tunnel - hoạt động mọi nơi
    const devTunnel = 'https://gj6c9g4g-8080.asse.devtunnels.ms';

    // Localhost cho emulator (fallback)
    const emulatorLocal = 'http://10.0.2.2:8080';

    // Localhost cho thiết bị vật lý (fallback)
    const physicalDeviceLocal = 'http://192.168.1.9:8080';

    // Dùng dev tunnel mặc định
    return physicalDeviceLocal;
  }

  static final String fullApiUrl = '$baseUrl/';

  // Logging chỉ bật trong debug mode để tránh lộ token và dữ liệu nhạy cảm
  static bool get enableDebugLogging => kDebugMode;
  static bool get enableLogging => kDebugMode;
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
