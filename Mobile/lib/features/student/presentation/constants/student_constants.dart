
class StudentConstants {
  StudentConstants._();

  
  static const int snackbarDuration = 2000;
  static const int animationDuration = 300;
  static const int debounceDelay = 500;
  static const int refreshDelay = 1000;

  
  static const int defaultPageSize = 10;
  static const int coursesPerPage = 9;
  static const int classesPerPage = 10;

  
  static const double minRating = 0.0;
  static const double maxRating = 5.0;
  static const int minCommentLength = 10;
  static const int maxCommentLength = 500;

  
  static const int daysInWeek = 7;
  static const int weeksToShow = 4;
  static const int monthsToShow = 3;

  
  static const int courseGridCrossAxisCount = 2;
  static const int courseGridCrossAxisCountDesktop = 3;
  static const double courseCardAspectRatio = 0.75;

  
  static const int maxUpcomingClasses = 5;
  static const int maxRecentGrades = 5;

  
  static const int maxImageSizeBytes = 5 * 1024 * 1024; 
  static const int imageQuality = 85;

  
  static const int maxNameLength = 100;
  static const int maxAddressLength = 200;
  static const int maxPhoneLength = 15;
  static const int maxEmailLength = 100;

  
  static const int minPasswordLength = 6;
  static const int maxPasswordLength = 20;
  
  
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

  
  
  static const String statusUpcoming = 'upcoming';
  static const String statusOngoing = 'ongoing';
  static const String statusCompleted = 'completed';
  static const String statusCancelled = 'cancelled';
}