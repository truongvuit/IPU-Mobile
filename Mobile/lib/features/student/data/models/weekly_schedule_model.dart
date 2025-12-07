import 'package:equatable/equatable.dart';

class WeeklyScheduleResponse extends Equatable {
  final String weekStart;
  final String weekEnd;
  final List<WeeklyScheduleDay> days;

  const WeeklyScheduleResponse({
    required this.weekStart,
    required this.weekEnd,
    required this.days,
  });

  factory WeeklyScheduleResponse.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleResponse(
      weekStart: json['weekStart'] as String? ?? '',
      weekEnd: json['weekEnd'] as String? ?? '',
      days: (json['days'] as List<dynamic>? ?? [])
          .map((e) => WeeklyScheduleDay.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'weekStart': weekStart,
    'weekEnd': weekEnd,
    'days': days.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [weekStart, weekEnd, days];

  List<WeeklyScheduleSession> getSessionsForDate(String date) {
    for (final day in days) {
      if (day.date == date) {
        return day.periods.expand((p) => p.sessions).toList();
      }
    }
    return [];
  }

  List<WeeklyScheduleSession> get allSessions {
    return days.expand((day) => day.periods.expand((p) => p.sessions)).toList();
  }

  void operator [](String other) {}
}

class WeeklyScheduleDay extends Equatable {
  final String date;
  final String dayOfWeek;
  final List<WeeklySchedulePeriod> periods;

  const WeeklyScheduleDay({
    required this.date,
    required this.dayOfWeek,
    required this.periods,
  });

  factory WeeklyScheduleDay.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleDay(
      date: json['date'] as String? ?? '',

      dayOfWeek:
          json['dayName'] as String? ?? json['dayOfWeek'] as String? ?? '',
      periods: (json['periods'] as List<dynamic>? ?? [])
          .map((e) => WeeklySchedulePeriod.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'date': date,
    'dayOfWeek': dayOfWeek,
    'periods': periods.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [date, dayOfWeek, periods];

  bool get hasSessions => periods.any((p) => p.sessions.isNotEmpty);
}

class WeeklySchedulePeriod extends Equatable {
  final String periodName;
  final List<WeeklyScheduleSession> sessions;

  const WeeklySchedulePeriod({
    required this.periodName,
    required this.sessions,
  });

  factory WeeklySchedulePeriod.fromJson(Map<String, dynamic> json) {
    return WeeklySchedulePeriod(
      periodName:
          json['period'] as String? ?? json['periodName'] as String? ?? '',
      sessions: (json['sessions'] as List<dynamic>? ?? [])
          .map((e) => WeeklyScheduleSession.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'periodName': periodName,
    'sessions': sessions.map((e) => e.toJson()).toList(),
  };

  @override
  List<Object?> get props => [periodName, sessions];
}

class WeeklyScheduleSession extends Equatable {
  final int sessionId;
  final int classId;
  final String className;
  final String courseName;
  final String timeSlot;
  final String room;
  final String lecturerName;
  final String? status;
  final String? note;
  final String? schedulePattern;
  final String? sessionDate;
  final int? durationMinutes;

  const WeeklyScheduleSession({
    this.sessionId = 0,
    required this.classId,
    required this.className,
    required this.courseName,
    required this.timeSlot,
    required this.room,
    required this.lecturerName,
    this.status,
    this.note,
    this.schedulePattern,
    this.sessionDate,
    this.durationMinutes,
  });

  factory WeeklyScheduleSession.fromJson(Map<String, dynamic> json) {
    return WeeklyScheduleSession(
      sessionId: _parseInt(json['sessionId']),
      classId: _parseInt(json['classId']),
      className: json['className'] as String? ?? '',
      courseName: json['courseName'] as String? ?? '',

      timeSlot:
          json['startTime'] as String? ?? json['timeSlot'] as String? ?? '',

      room: json['roomName'] as String? ?? json['room'] as String? ?? '',

      lecturerName:
          json['instructorName'] as String? ??
          json['lecturerName'] as String? ??
          '',
      status: json['status'] as String?,
      note: json['note'] as String?,
      schedulePattern: json['schedulePattern'] as String?,
      sessionDate: json['sessionDate'] as String?,
      durationMinutes: json['durationMinutes'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
    'sessionId': sessionId,
    'classId': classId,
    'className': className,
    'courseName': courseName,
    'startTime': timeSlot,
    'roomName': room,
    'instructorName': lecturerName,
    if (status != null) 'status': status,
    if (note != null) 'note': note,
    if (schedulePattern != null) 'schedulePattern': schedulePattern,
    if (sessionDate != null) 'sessionDate': sessionDate,
    if (durationMinutes != null) 'durationMinutes': durationMinutes,
  };

  @override
  List<Object?> get props => [
    sessionId,
    classId,
    className,
    courseName,
    timeSlot,
    room,
    lecturerName,
    status,
    note,
    schedulePattern,
    sessionDate,
    durationMinutes,
  ];
}

int _parseInt(dynamic value) {
  if (value == null) return 0;
  if (value is int) return value;
  if (value is String) return int.tryParse(value) ?? 0;
  return 0;
}
