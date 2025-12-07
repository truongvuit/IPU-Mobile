

class TeacherApiSpec {
  
  static const String _lecturerBase = '/lecturers';
  static const String _classesBase = '/courseclasses';

  
  
  
  
  static const String getDashboard = '$_lecturerBase/me';
  static const String getProfile = '$_lecturerBase/me';

  
  static const String updateProfile = _lecturerBase;

  
  
  
  
  static const String getClasses = '$_classesBase/filter';

  
  static String getClassById(String id) => '$_classesBase/$id';

  
  static String getStudentInClass(String classId, String studentId) =>
      '$_classesBase/$classId';

  
  
  
  
  static const String getSchedule = '$_classesBase/schedule-by-week';

  
  
  
  
  static String getAttendance(String sessionId) =>
      '$_classesBase/sessions/$sessionId/attendance';

  
  static String submitAttendance(String sessionId) =>
      '$_lecturerBase/sessions/$sessionId/attendance';

  
  static String getGrades(String classId) =>
      '$_lecturerBase/grades/class/$classId';
  static const String submitGrades = '$_lecturerBase/grades';

  
  
  
  static const String getMaterials = '/files';
  static String getMaterialById(String id) => '/files/$id';
  static const String uploadMaterial = '/files';
}
