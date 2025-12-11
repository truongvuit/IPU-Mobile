class AppConstants {
  static const double excellentGrade = 8.0;
  static const double goodGrade = 6.5;
  static const double averageGrade = 5.0;

  static const double highAttendance = 90.0;
  static const double mediumAttendance = 75.0;
  static const double lowAttendance = 50.0;

  static const String statusCompleted = 'Hoàn thành';
  static const String statusOngoing = 'Đang diễn ra';
  static const String statusUpcoming = 'Sắp diễn ra';
  static const String statusPending = 'Chờ xử lý';
  static const String statusPaid = 'Đã thanh toán';
  static const String statusOverdue = 'Quá hạn';
  static const String statusCancelled = 'Đã hủy';

  
  static const int paymentMethodCash = 1;
  static const int paymentMethodVNPay = 2;
  static const int paymentMethodTransfer = 3;

  
  static const int promotionTypeCourse = 1;
  static const int promotionTypeCombo = 2;
  static const int promotionTypeOldStudent = 3;
  static const int promotionTypeTime = 4;

  static const String _devBaseUrl = 'http://192.168.1.9:8080';

  static const String _androidEmulatorUrl = 'http://10.0.2.2:8080';

  static const String _deviceLanUrl = 'http://192.168.1.9:8080';

  static const String _productionUrl = 'https://api.yourdomain.com';

  static String get baseUrl {
    return _devBaseUrl;
  }

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  static const int defaultPageSize = 20;

  static const String keyAuthToken = 'auth_token';
  static const String keyRefreshToken = 'refresh_token';
  static const String keyUserId = 'user_id';
  static const String keyUserRole = 'user_role';
  static const String keySettings = 'app_settings';
  static const String keyRememberMe = 'remember_me';

  static const String roleStudent = 'student';
  static const String roleTeacher = 'teacher';

  static const String dateFormat = 'dd/MM/yyyy';
  static const String timeFormat = 'HH:mm';
  static const String dateTimeFormat = 'dd/MM/yyyy HH:mm';

  static const int minPasswordLength = 8;
  static const int maxPasswordLength = 32;
  static const int minPhoneLength = 10;
  static const int maxPhoneLength = 11;

  static const int maxFileSize = 10 * 1024 * 1024;
  static const List<String> allowedImageExtensions = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
  static const List<String> allowedDocExtensions = [
    'pdf',
    'doc',
    'docx',
    'xls',
    'xlsx',
    'ppt',
    'pptx',
  ];

  static const Duration mockDelay = Duration(milliseconds: 500);

  static const String privacyPolicyUrl = 'https://trungtamngoaingu.com/privacy';
  static const String termsUrl = 'https://trungtamngoaingu.com/terms';
  static const String supportEmail = 'support@trungtamngoaingu.com';
  static const String supportPhone = '1900-xxxx';

  static const String courseRegistrationWebUrl =
      'https://trungtamngoaingu.com/courses';

  static const String appName = 'Trung Tâm Ngoại Ngữ';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
}

class ApiEndpoints {
  static const String login = '/auth/login';
  static const String signup = '/auth/signup';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refreshtoken';
  static const String verify = '/auth/verify';
  static const String resend = '/auth/resend';
  static const String forgotPassword = '/auth/forgot-password';
  static const String verifyCode = '/auth/verify-code';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  static const String userProfile = '/users';
  static const String userNameEmail = '/users/name-email';
  static const String updateUser = '/users';

  static const String studentProfile = '/students';
  static const String studentUpdateProfile = '/students';
  static const String studentSchedule = '/students/schedule-by-week';
  static const String studentClassesEnrolled = '/students/get-classes-enrolled';
  static const String studentCoursesEnrolled = '/students/get-courses_enrolled';
  static const String studentGrades = '/students/grades';
  static const String studentReviews = '/students/reviews';

  static const String coursesActive = '/courses/activecourses';
  static const String coursesActiveName = '/courses/activecourses-name';
  static const String courses = '/courses';
  static const String courseDetail = '/courses';
  static const String courseRecommend = '/courses/recommedcousres';
  static const String courseCreate = '/courses';
  static const String courseUpdate = '/courses';
  static const String courseStatus = '/courses/status';

  static const String classes = '/courseclasses';
  static const String classDetail = '/courseclasses';
  static const String classCreate = '/courseclasses';
  static const String classUpdate = '/courseclasses';
  static const String classStatus = '/courseclasses';
  static const String classFilter = '/courseclasses/filter';
  static const String scheduleByWeek = '/courseclasses/schedule-by-week';

  static const String lecturersAvailable = '/lecturers/available';
  static const String lecturersName = '/lecturers/lecturer-name';
  static const String lecturerDetail = '/lecturers';

  static const String teacherProfile = '/lecturers/me';
  static const String teacherDetail = '/lecturers';
  static const String teacherClasses = '/courseclasses/filter';
  static const String teacherSchedule = '/courseclasses/schedule-by-week';
  static const String teacherClassStudents = '/courseclasses';
  static const String teacherClassDetail = '/courseclasses';
  static const String teacherMaterials = '/files';
  static const String teacherMaterialUpdate = '/files';
  static const String teacherAttendance = '/lecturers/sessions';

  static String teacherClassGrades(String classId) =>
      '/lecturers/grades/class/$classId';
  static const String teacherSubmitGrade = '/lecturers/grades';
  static String teacherUpdateGrade(String gradeId) =>
      '/lecturers/grades/$gradeId';

  static const String roomsAvailable = '/rooms/available';
  static const String roomsName = '/rooms/room-name';
  static const String roomDetail = '/rooms';
  static const String roomCreate = '/rooms';

  static const String uploadFile = '/files';
  static const String downloadFile = '/files';
  static const String deleteFile = '/files';

  static const String paymentMomoCreate = '/payment/momo/create';
  static const String paymentMomoStatus = '/payment/momo/status';

  static const String categories = '/categories';
  static const String categoryDetail = '/categories';
  static const String categoryCreate = '/categories';
  static const String categoryUpdate = '/categories';

  static const String modules = '/modules';
  static const String moduleCreate = '/modules';
  static const String moduleUpdate = '/modules';
  static const String moduleDelete = '/modules';

  static const String skills = '/skills';

  static const String scheduleCheckSuggest = '/schedules/check-and-suggest';
  static const String scheduleQuickCheck = '/schedules/quick-check';

  static const String enrollments = '/enrollments';
}

class ErrorMessages {
  static const String networkError = 'Không thể kết nối đến server';
  static const String serverError = 'Lỗi server, vui lòng thử lại sau';
  static const String unknownError = 'Đã xảy ra lỗi không xác định';
  static const String authError = 'Phiên đăng nhập đã hết hạn';
  static const String invalidCredentials = 'Email hoặc mật khẩu không đúng';
  static const String invalidEmail = 'Email không hợp lệ';
  static const String invalidPhone = 'Số điện thoại không hợp lệ';
  static const String invalidPassword = 'Mật khẩu không hợp lệ';
  static const String passwordMismatch = 'Mật khẩu không khớp';
  static const String requiredField = 'Trường này không được để trống';
  static const String fileTooLarge = 'File quá lớn';
  static const String invalidFileType = 'Loại file không được hỗ trợ';
}

class SuccessMessages {
  static const String loginSuccess = 'Đăng nhập thành công';
  static const String logoutSuccess = 'Đăng xuất thành công';
  static const String registerSuccess = 'Đăng ký thành công';
  static const String updateSuccess = 'Cập nhật thành công';
  static const String deleteSuccess = 'Xóa thành công';
  static const String uploadSuccess = 'Tải lên thành công';
  static const String paymentSuccess = 'Thanh toán thành công';
  static const String ratingSuccess = 'Đánh giá thành công';
  static const String attendanceSuccess = 'Điểm danh thành công';
  static const String gradeSuccess = 'Nhập điểm thành công';
}
