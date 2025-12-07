

class AuthApiSpec {
  static const String baseUrl = '/auth';

  
  
  
  static const String login = '$baseUrl/login';
  static const String signup = '$baseUrl/signup'; 
  static const String logout = '$baseUrl/logout';
  static const String refreshToken = '$baseUrl/refreshtoken';
  static const String verify = '$baseUrl/verify'; 
  static const String resend = '$baseUrl/resend'; 

  
  
  
  static const String forgotPassword = '$baseUrl/forgot-password';
  static const String verifyCode = '$baseUrl/verify-code';
  static const String resetPassword = '$baseUrl/reset-password';
  static const String changePassword = '$baseUrl/change-password';

  
  
  
  
  
  
  
  static const String getCurrentUser = '/users/name-email';
  static const String getStudentInfo = '/students';
  static const String getTeacherInfo = '/lecturers/me';
}
