/// Authentication API Endpoints Specification
/// Mapping với BE APIs thực tế - /auth/*
class AuthApiSpec {
  static const String baseUrl = '/auth';

  // ====================================================================
  // AUTHENTICATION
  // ====================================================================
  static const String login = '$baseUrl/login';
  static const String signup = '$baseUrl/signup'; // Student registration
  static const String logout = '$baseUrl/logout';
  static const String refreshToken = '$baseUrl/refreshtoken';
  static const String verify = '$baseUrl/verify'; // Email/phone verification
  static const String resend = '$baseUrl/resend'; // Resend verification code

  // ====================================================================
  // PASSWORD MANAGEMENT
  // ====================================================================
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String verifyCode = '$baseUrl/verify-code';
  static const String resetPassword = '$baseUrl/reset-password';
  static const String changePassword = '$baseUrl/change-password';

  // ====================================================================
  // USER INFO - Sử dụng endpoints khác
  // ====================================================================
  /// Lấy thông tin user hiện tại theo role:
  /// - Student: GET /students
  /// - Teacher: GET /lecturers/me
  /// - Admin: GET /users/name-email
  static const String getCurrentUser = '/users/name-email';
  static const String getStudentInfo = '/students';
  static const String getTeacherInfo = '/lecturers/me';
}
