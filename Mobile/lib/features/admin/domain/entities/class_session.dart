
enum SessionStatus {
  notCompleted, 
  completed, 
  canceled, 
}


class ClassSession {
  final int id;
  final DateTime date;
  final String? note;
  final SessionStatus status;

  const ClassSession({
    required this.id,
    required this.date,
    this.note,
    required this.status,
  });

  
  factory ClassSession.fromJson(Map<String, dynamic> json) {
    return ClassSession(
      id: json['sessionId'] ?? json['mabuoihoc'] ?? 0,
      date: _parseDate(json['date'] ?? json['sessionDate'] ?? json['ngayhoc']),
      note: json['note'] ?? json['ghichu'],
      status: _parseStatus(json['status'] ?? json['trangthai']),
    );
  }

  
  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  
  static SessionStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
      case 'hoanthanh':
      case 'đã hoàn thành':
        return SessionStatus.completed;
      case 'canceled':
      case 'huy':
      case 'đã hủy':
        return SessionStatus.canceled;
      case 'notcompleted':
      case 'not_completed':
      case 'chuahoanthanh':
      case 'chưa hoàn thành':
      default:
        return SessionStatus.notCompleted;
    }
  }

  
  String get statusText {
    switch (status) {
      case SessionStatus.completed:
        return 'Đã hoàn thành';
      case SessionStatus.canceled:
        return 'Đã hủy';
      case SessionStatus.notCompleted:
        return 'Chưa hoàn thành';
    }
  }

  
  String get statusValue {
    switch (status) {
      case SessionStatus.completed:
        return 'Completed';
      case SessionStatus.canceled:
        return 'Canceled';
      case SessionStatus.notCompleted:
        return 'NotCompleted';
    }
  }

  
  bool get isPast => date.isBefore(DateTime.now());

  
  bool get isToday {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  
  ClassSession copyWith({
    int? id,
    DateTime? date,
    String? note,
    SessionStatus? status,
  }) {
    return ClassSession(
      id: id ?? this.id,
      date: date ?? this.date,
      note: note ?? this.note,
      status: status ?? this.status,
    );
  }

  @override
  String toString() {
    return 'ClassSession(id: $id, date: $date, status: $status, note: $note)';
  }
}
