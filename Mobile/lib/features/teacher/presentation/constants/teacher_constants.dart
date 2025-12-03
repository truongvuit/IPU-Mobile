
class TeacherConstants {
  TeacherConstants._();

  
  static const int snackbarDuration = 2000;
  static const int animationDuration = 300;
  static const int refreshDelay = 1000;

  
  static const int defaultPageSize = 10;
  static const int studentsPerPage = 20;
  static const int materialsPerPage = 15;

  
  static const int daysInWeek = 7;
  static const int weeksToShow = 4;

  
  static const int classGridCrossAxisCount = 2;
  static const int classGridCrossAxisCountDesktop = 3;

  
  static const int maxRecentClasses = 3;
  static const int maxTodaySchedule = 5;

  
  static const String statusPresent = 'present';
  static const String statusAbsent = 'absent';
  static const String statusLate = 'late';
  static const String statusExcused = 'excused';

  
  static const String statusActive = 'active';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
  static const String statusUpcoming = 'upcoming';

  
  static const double minScore = 0.0;
  static const double maxScore = 10.0;

  
  static const int maxFileSizeBytes = 10 * 1024 * 1024; 
  static const List<String> allowedFileTypes = [
    'pdf',
    'doc',
    'docx',
    'ppt',
    'pptx',
    'xls',
    'xlsx',
    'zip',
  ];

  
  static const List<String> weekdayNamesShort = ['CN', 'T2', 'T3', 'T4', 'T5', 'T6', 'T7'];
  static const List<String> weekdayNamesFull = [
    'Chủ nhật',
    'Thứ hai',
    'Thứ ba',
    'Thứ tư',
    'Thứ năm',
    'Thứ sáu',
    'Thứ bảy',
  ];
}
