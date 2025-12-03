class AppStrings {
  // Common
  static const String appName = 'Trung Tâm Ngoại Ngữ';
  static const String error = 'Đã có lỗi xảy ra';
  static const String retry = 'Thử lại';
  static const String cancel = 'Hủy';
  static const String confirm = 'Xác nhận';
  static const String save = 'Lưu';
  static const String delete = 'Xóa';
  static const String edit = 'Chỉnh sửa';
  static const String search = 'Tìm kiếm';
  static const String noData = 'Không có dữ liệu';
  static const String loading = 'Đang tải...';
  
  // Greetings
  static String welcomeGreeting(String userName) {
    final hour = DateTime.now().hour;
    String greeting;
    if (hour < 12) {
      greeting = 'Chào buổi sáng';
    } else if (hour < 18) {
      greeting = 'Chào buổi chiều';
    } else {
      greeting = 'Chào buổi tối';
    }
    return '$greeting, $userName!';
  }
  
  // Day names
  static String dayOfWeek(int day) {
    switch (day) {
      case 1: return 'Thứ 2';
      case 2: return 'Thứ 3';
      case 3: return 'Thứ 4';
      case 4: return 'Thứ 5';
      case 5: return 'Thứ 6';
      case 6: return 'Thứ 7';
      case 7: return 'Chủ nhật';
      default: return '';
    }
  }

  // Auth
  static const String login = 'Đăng nhập';
  static const String logout = 'Đăng xuất';
  static const String forgotPassword = 'Quên mật khẩu?';
  static const String emailOrPhone = 'Email hoặc số điện thoại';
  static const String password = 'Mật khẩu';
  static const String rememberMe = 'Ghi nhớ đăng nhập';

  // Student
  static const String studentDashboard = 'Trang chủ';
  static const String studentSchedule = 'Lịch học';
  static const String studentGrades = 'Điểm số';
  static const String studentProfile = 'Tài khoản';

  // Teacher
  static const String teacherDashboard = 'Trang chủ';
  static const String teacherSchedule = 'Lịch dạy';
  static const String teacherClasses = 'Lớp học';
  static const String teacherMaterials = 'Tài liệu';
  static const String teacherProfile = 'Hồ sơ';
}
