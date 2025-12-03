/// Teacher API Endpoints Specification
/// Mapping với BE APIs thực tế
class TeacherApiSpec {
  // Base paths - khớp với BE endpoint patterns
  static const String _lecturerBase = '/lecturers';
  static const String _classesBase = '/courseclasses';

  // ====================================================================
  // PROFILE & DASHBOARD
  // ====================================================================
  /// GET /lecturers/me - Lấy thông tin giảng viên từ token
  static const String getDashboard = '$_lecturerBase/me';
  static const String getProfile = '$_lecturerBase/me';
  /// PUT /lecturers/{id} - Cập nhật thông tin (TODO: cần thêm BE)
  static const String updateProfile = _lecturerBase;

  // ====================================================================
  // CLASSES & STUDENTS
  // ====================================================================
  /// GET /courseclasses/filter?lecturerId={id} - Lấy lớp của giảng viên
  static const String getClasses = '$_classesBase/filter';
  /// GET /courseclasses/{id} - Chi tiết lớp học (bao gồm danh sách students)
  static String getClassById(String id) => '$_classesBase/$id';
  /// Students included in class detail response
  static String getStudentInClass(String classId, String studentId) =>
      '$_classesBase/$classId';

  // ====================================================================
  // SCHEDULE
  // ====================================================================
  /// GET /courseclasses/schedule-by-week?lecturerId={id}&date={YYYY-MM-DD}
  static const String getSchedule = '$_classesBase/schedule-by-week';

  // ====================================================================
  // ATTENDANCE & GRADING
  // ====================================================================
  /// GET /courseclasses/sessions/{sessionId}/attendance - Xem điểm danh
  static String getAttendance(String sessionId) =>
      '$_classesBase/sessions/$sessionId/attendance';
  /// POST /lecturers/sessions/{sessionId}/attendance - Điểm danh
  static String submitAttendance(String sessionId) =>
      '$_lecturerBase/sessions/$sessionId/attendance';
  /// GET/POST grades - TODO: Cần tạo API BE
  static String getGrades(String classId) => '$_classesBase/$classId/grades';
  static String submitGrades(String classId) =>
      '$_classesBase/$classId/grades';

  // ====================================================================
  // MATERIALS - Sử dụng /files
  // ====================================================================
  static const String getMaterials = '/files';
  static String getMaterialById(String id) => '/files/$id';
  static const String uploadMaterial = '/files';
}
