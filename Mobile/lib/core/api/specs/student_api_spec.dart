

class StudentApiSpec {
  
  static const String _studentBase = '/students';
  static const String _classesBase = '/courseclasses';
  static const String _coursesBase = '/courses';

  
  
  
  
  static const String getDashboard = _studentBase;
  static const String getProfile = _studentBase;
  static const String updateProfile = _studentBase; 

  
  
  
  
  static const String getEnrolledClasses = '$_studentBase/get-classes-enrolled';

  
  static const String getEnrolledCourses = '$_studentBase/get-courses_enrolled';

  
  static String getClassById(String id) => '$_classesBase/$id';

  
  static const String getCourses = '$_coursesBase/activecourses';

  
  static String getCourseById(String id) => '$_coursesBase/$id';

  
  
  
  
  static const String getSchedule = '$_studentBase/schedule-by-week';

  
  static String getAttendance(String sessionId) =>
      '$_classesBase/sessions/$sessionId/attendance';

  
  
  
  
  static const String getGrades = '$_studentBase/grades';

  
  static String getGradesByClass(String classId) =>
      '$_studentBase/grades/class/$classId';

  
  
  
  
  static const String reviews = '$_studentBase/reviews';

  
  
  
  
  static const String cartPreview = '/cart/preview';

  
  static const String createOrder = '/orders';
}
