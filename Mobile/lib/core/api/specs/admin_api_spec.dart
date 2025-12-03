class AdminApiSpec {
  static const String _adminBase = '/admin';
  static const String _classesBase = '/courseclasses';
  static const String _lecturersBase = '/lecturers';
  static const String _coursesBase = '/courses';

  static const String getProfile = '/users/name-email';
  static const String updateProfile = '/users';

  static const String getDashboardStats = '$_adminBase/dashboard/stats';
  static const String getRecentActivities = '$_adminBase/dashboard/activities';

  static const String getClasses = _classesBase;
  static String getClassById(String id) => '$_classesBase/$id';
  static const String createClass = _classesBase;
  static String updateClass(String id) => '$_classesBase/$id';
  static String deleteClass(String id) => '$_classesBase/$id';
  static String getClassStudents(String id) => '$_classesBase/$id';
  static const String filterClasses = '$_classesBase/filter';
  static const String scheduleByWeek = '$_classesBase/schedule-by-week';

  static const String getStudents = '$_adminBase/students';
  static String getStudentById(String id) => '$_adminBase/students/$id';
  static String updateStudent(String id) => '$_adminBase/students/$id';
  static String deleteStudent(String id) => '$_adminBase/students/$id';
  static String getStudentClasses(String id) =>
      '$_adminBase/students/$id/classes';

  static const String getTeachers = '$_lecturersBase/lecturer-name';
  static String getTeacherById(String id) => '$_lecturersBase/$id';
  static const String createTeacher = '/users/add-lecturer';
  static String updateTeacher(String id) => '$_lecturersBase/$id';
  static String deleteTeacher(String id) => '$_lecturersBase/$id';

  static const String getCourses = _coursesBase;
  static const String getActiveCourses = '$_coursesBase/activecourses';
  static const String getActiveCoursesName = '$_coursesBase/activecourses-name';
  static String getCourseById(String id) => '$_coursesBase/$id';
  static const String createCourse = _coursesBase;
  static String updateCourse(String id) => '$_coursesBase/$id';
  static String setCourseStatus(String id) => '$_coursesBase/status/$id';

  static const String getRooms = '/rooms/room-name';
  static String getRoomById(String id) => '/rooms/$id';
  static const String createRoom = '/rooms';
  static const String getAvailableRooms = '/rooms/available';

  static const String getAvailableClasses = '$_classesBase/filter';
  static const String checkPromotionCode = '/promotions/check';
  static const String submitRegistration = '/orders';
  static String processPayment(String orderId) => '/payment/momo/create';

  static const String getRevenueReport = '$_adminBase/reports/revenue';
  static const String getStudentReport = '$_adminBase/reports/students';
  static const String getTeacherReport = '$_adminBase/reports/teachers';
  static const String getClassroomReport = '$_adminBase/reports/classrooms';
}
