











class UserRoles {
  static const String admin = 'ADMIN';
  static const String student = 'STUDENT';
  static const String teacher = 'TEACHER';

  static const List<String> all = [admin, student, teacher];

  static bool isValid(String? role) => role != null && all.contains(role);
  static bool isTeacher(String? role) => role == teacher || role == admin;
}


class ClassStatus {
  static const String planned = 'Planned';
  static const String inProgress = 'InProgress';
  static const String completed = 'Completed';
  static const String closed = 'Closed';

  static const List<String> all = [planned, inProgress, completed, closed];

  static bool isValid(String? status) => status != null && all.contains(status);

  
  
  static bool isValidTransition(String from, String to) {
    final fromIndex = all.indexOf(from);
    final toIndex = all.indexOf(to);
    return fromIndex >= 0 && toIndex >= 0 && toIndex >= fromIndex;
  }
}


class NumericRanges {
  
  static const int capacityMin = 1;
  static const int capacityMax = 200;

  
  static const int discountMin = 0;
  static const int discountMax = 100;

  
  static const double gradeMin = 0;
  static const double gradeMax = 10;

  
  static const double tuitionMin = 0;

  
  static const int hoursMin = 1;
}


class DateRanges {
  
  static final DateTime birthdateMin = DateTime(1900, 1, 1);
  static final DateTime birthdateMax = DateTime(2100, 1, 1);
}






class DateValidators {
  
  static String? validateDateRange(DateTime? startDate, DateTime? endDate) {
    if (startDate == null || endDate == null) return null;
    if (endDate.isBefore(startDate)) {
      return 'Ngày kết thúc phải sau ngày bắt đầu';
    }
    return null;
  }

  
  static String? validateBirthdate(DateTime? date) {
    if (date == null) return null;
    if (date.isBefore(DateRanges.birthdateMin)) {
      return 'Ngày sinh không hợp lệ (quá xa trong quá khứ)';
    }
    if (date.isAfter(DateTime.now())) {
      return 'Ngày sinh không thể trong tương lai';
    }
    return null;
  }

  
  
  static bool Function(DateTime) endDatePredicate(DateTime? startDate) {
    return (DateTime day) {
      if (startDate == null) return true;
      return !day.isBefore(startDate);
    };
  }
}


class NumericValidators {
  
  static String? validateCapacity(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Vui lòng nhập số';
    if (parsed < NumericRanges.capacityMin ||
        parsed > NumericRanges.capacityMax) {
      return 'Sức chứa phải từ ${NumericRanges.capacityMin} đến ${NumericRanges.capacityMax}';
    }
    return null;
  }

  
  static String? validateDiscountPercent(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Vui lòng nhập số';
    if (parsed < NumericRanges.discountMin ||
        parsed > NumericRanges.discountMax) {
      return 'Phần trăm giảm giá phải từ ${NumericRanges.discountMin} đến ${NumericRanges.discountMax}';
    }
    return null;
  }

  
  static String? validateGrade(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return 'Vui lòng nhập số';
    if (parsed < NumericRanges.gradeMin || parsed > NumericRanges.gradeMax) {
      return 'Điểm phải từ ${NumericRanges.gradeMin.toInt()} đến ${NumericRanges.gradeMax.toInt()}';
    }
    return null;
  }

  
  static String? validateTuition(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = double.tryParse(value.replaceAll(',', ''));
    if (parsed == null) return 'Vui lòng nhập số';
    if (parsed < NumericRanges.tuitionMin) {
      return 'Học phí không thể âm';
    }
    return null;
  }

  
  static String? validateCourseHours(String? value) {
    if (value == null || value.isEmpty) return null;
    final parsed = int.tryParse(value);
    if (parsed == null) return 'Vui lòng nhập số';
    if (parsed < NumericRanges.hoursMin) {
      return 'Số giờ học phải lớn hơn 0';
    }
    return null;
  }
}


class CapacityValidators {
  
  static bool isFull(int enrolledCount, int capacity) {
    return enrolledCount >= capacity;
  }

  
  static int remainingSpots(int enrolledCount, int capacity) {
    return (capacity - enrolledCount).clamp(0, capacity);
  }
}
