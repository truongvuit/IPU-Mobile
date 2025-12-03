import 'package:intl/intl.dart';

class DateFormatter {
  static final DateFormat dayMonthYear = DateFormat('dd/MM/yyyy');
  static final DateFormat dayMonthYearTime = DateFormat('dd/MM/yyyy HH:mm');
  static final DateFormat time = DateFormat('HH:mm');
  static final DateFormat fullDate = DateFormat('EEEE, dd/MM/yyyy', 'vi');
  static final DateFormat monthYear = DateFormat('MM/yyyy');
  static final DateFormat dayMonth = DateFormat('dd/MM');

  static String format(DateTime date, {String pattern = 'dd/MM/yyyy'}) {
    return DateFormat(pattern).format(date);
  }

  static String formatDate(DateTime date) {
    return dayMonthYear.format(date);
  }

  static String formatDateTime(DateTime date) {
    return dayMonthYearTime.format(date);
  }

  static String formatTime(DateTime date) {
    return time.format(date);
  }

  static String formatFullDate(DateTime date) {
    return fullDate.format(date);
  }

  static String formatMonthYear(DateTime date) {
    return monthYear.format(date);
  }

  static String formatDayMonth(DateTime date) {
    return dayMonth.format(date);
  }
  
  static String formatDayOfWeek(DateTime date) {
    // Vietnamese day of week
    final days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
    return days[date.weekday - 1];
  }

  static String getRelativeTime(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} năm trước';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} tháng trước';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }

  static String getWeekdayName(int weekday) {
    const weekdays = [
      'Thứ 2',
      'Thứ 3',
      'Thứ 4',
      'Thứ 5',
      'Thứ 6',
      'Thứ 7',
      'Chủ nhật',
    ];
    return weekdays[weekday - 1];
  }
}
