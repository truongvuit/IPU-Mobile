import '../../domain/entities/schedule.dart';

class ScheduleModel extends Schedule {
  const ScheduleModel({
    required super.id,
    required super.classId,
    required super.className,
    required super.teacherName,
    required super.room,
    required super.startTime,
    required super.endTime,
    super.isOnline,
    super.meetingLink,
    super.courseName,
    super.status,
    super.note,
    super.period,
  });

  factory ScheduleModel.fromJson(Map<String, dynamic> json) {
    DateTime startTime;
    if (json['date'] != null && json['startTime'] != null) {
      final dateStr = json['date'];
      final timeStr = json['startTime'];
      startTime = DateTime.parse('$dateStr $timeStr');
    } else if (json['startTime'] != null) {
      startTime = DateTime.parse(json['startTime']);
    } else {
      startTime = DateTime.now();
    }

    DateTime endTime;
    if (json['endTime'] != null) {
      endTime = DateTime.parse(json['endTime']);
    } else if (json['minutesPerSession'] != null) {
      final minutes = json['minutesPerSession'] as int;
      endTime = startTime.add(Duration(minutes: minutes));
    } else {
      endTime = startTime.add(const Duration(hours: 2));
    }

    return ScheduleModel(
      id: json['scheduleId']?.toString() ?? json['id']?.toString() ?? '',
      classId: json['classId']?.toString() ?? json['maLop']?.toString() ?? '',
      className: json['className'] ?? json['tenLop'] ?? '',
      teacherName: json['lecturerName'] ?? json['tenGiangVien'] ?? '',
      room: json['roomName'] ?? json['tenPhong'] ?? '',
      startTime: startTime,
      endTime: endTime,
      isOnline: json['isOnline'] ?? false,
      meetingLink: json['meetingLink'],
      courseName: json['courseName'],
      status: json['status'],
      note: json['note'],
      period: json['period'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'teacherName': teacherName,
      'room': room,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'isOnline': isOnline,
      'meetingLink': meetingLink,
      'courseName': courseName,
      'status': status,
      'note': note,
      'period': period,
    };
  }

  factory ScheduleModel.fromEntity(Schedule schedule) {
    return ScheduleModel(
      id: schedule.id,
      classId: schedule.classId,
      className: schedule.className,
      teacherName: schedule.teacherName,
      room: schedule.room,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      isOnline: schedule.isOnline,
      meetingLink: schedule.meetingLink,
      courseName: schedule.courseName,
      status: schedule.status,
      note: schedule.note,
      period: schedule.period,
    );
  }

  @override
  ScheduleModel copyWith({
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
    return ScheduleModel(
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
