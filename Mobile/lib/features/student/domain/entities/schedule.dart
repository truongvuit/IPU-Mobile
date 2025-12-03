import 'package:equatable/equatable.dart';

class Schedule extends Equatable {
  final String id;
  final String classId;
  final String className;
  final String teacherName;
  final String room;
  final DateTime startTime;
  final DateTime endTime;
  final bool isOnline;
  final String? meetingLink;
  final String? courseName;
  final String? status;
  final String? note;
  final String? period; 

  const Schedule({
    required this.id,
    required this.classId,
    required this.className,
    required this.teacherName,
    required this.room,
    required this.startTime,
    required this.endTime,
    this.isOnline = false,
    this.meetingLink,
    this.courseName,
    this.status,
    this.note,
    this.period,
  });

  
  factory Schedule.fromSessionInfo(
    Map<String, dynamic> json,
    DateTime sessionDate,
    String period,
  ) {
    final startTimeStr = json['startTime'] as String? ?? '08:00';
    final durationMinutes = json['durationMinutes'] as int? ?? 90;

    
    final timeParts = startTimeStr.split(':');
    final hour = int.tryParse(timeParts[0]) ?? 8;
    final minute = timeParts.length > 1 ? int.tryParse(timeParts[1]) ?? 0 : 0;

    final startTime = DateTime(
      sessionDate.year,
      sessionDate.month,
      sessionDate.day,
      hour,
      minute,
    );
    final endTime = startTime.add(Duration(minutes: durationMinutes));

    return Schedule(
      id: (json['sessionId']?.toString() ?? ''),
      classId: (json['classId']?.toString() ?? ''),
      className: json['className'] as String? ?? '',
      teacherName: json['instructorName'] as String? ?? '',
      room: json['roomName'] as String? ?? '',
      startTime: startTime,
      endTime: endTime,
      isOnline: false,
      courseName: json['courseName'] as String?,
      status: json['status'] as String?,
      note: json['note'] as String?,
      period: period,
    );
  }

  @override
  List<Object?> get props => [
    id,
    classId,
    className,
    teacherName,
    room,
    startTime,
    endTime,
    isOnline,
    meetingLink,
    courseName,
    status,
    note,
    period,
  ];

  Schedule copyWith({
    String? id,
    String? classId,
    String? className,
    String? teacherName,
    String? room,
    DateTime? startTime,
    DateTime? endTime,
    bool? isOnline,
    String? meetingLink,
    String? courseName,
    String? status,
    String? note,
    String? period,
  }) {
    return Schedule(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      teacherName: teacherName ?? this.teacherName,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isOnline: isOnline ?? this.isOnline,
      meetingLink: meetingLink ?? this.meetingLink,
      courseName: courseName ?? this.courseName,
      status: status ?? this.status,
      note: note ?? this.note,
      period: period ?? this.period,
    );
  }
}
