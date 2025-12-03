/// Student API Endpoints Specification
/// Mapping với BE APIs thực tế
class StudentApiSpec {
  // Base paths - khớp với BE endpoint patterns
  static const String _studentBase = '/students';
  static const String _classesBase = '/courseclasses';
  static const String _coursesBase = '/courses';

  // ====================================================================
  // PROFILE & DASHBOARD
  // ====================================================================
  /// GET /students - Lấy thông tin học viên từ token
  static const String getDashboard = _studentBase;
  static const String getProfile = _studentBase;
  static const String updateProfile = _studentBase; // PUT

  // ====================================================================
  // CLASSES & COURSES
  // ====================================================================
  /// GET /students/get-classes-enrolled - Lấy danh sách lớp đã đăng ký
  static const String getEnrolledClasses = '$_studentBase/get-classes-enrolled';
  /// Alias endpoint cho backward compatibility
  static const String getEnrolledCourses = '$_studentBase/get-courses_enrolled';
  /// GET /courseclasses/{id} - Chi tiết lớp học
  static String getClassById(String id) => '$_classesBase/$id';
  /// GET /courses/activecourses - Danh sách khóa học
  static const String getCourses = '$_coursesBase/activecourses';
  /// GET /courses/{id} - Chi tiết khóa học
  static String getCourseById(String id) => '$_coursesBase/$id';

  // ====================================================================
  // SCHEDULE & ATTENDANCE
  // ====================================================================
  /// GET /students/schedule-by-week?date={YYYY-MM-DD} - Lịch học theo tuần
  static const String getSchedule = '$_studentBase/schedule-by-week';
  /// GET /courseclasses/sessions/{sessionId}/attendance - Xem điểm danh
  static String getAttendance(String sessionId) => 
      '$_classesBase/sessions/$sessionId/attendance';

  // ====================================================================
  // GRADES - TODO: Cần tạo API BE
  // ====================================================================
  static const String getGrades = '$_studentBase/grades';
}
