import '../../domain/entities/teacher_schedule.dart';


class TeacherScheduleModel extends TeacherSchedule {
  const TeacherScheduleModel({
    required super.id,
    required super.classId,
    required super.className,
    required super.startTime,
    required super.endTime,
    required super.room,
    super.note,
  });

  
  factory TeacherScheduleModel.fromJson(Map<String, dynamic> json) {
    return TeacherScheduleModel(
      id: json['id']?.toString() ?? json['scheduleId']?.toString() ?? '',
      classId: json['classId']?.toString() ?? json['maLop']?.toString() ?? '',
      className: json['className'] ?? json['tenLop'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      room: json['room'] ?? json['roomName'] ?? json['tenPhong'] ?? 'N/A',
      note: json['note'],
    );
  }

  
  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classId': classId,
      'className': className,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'room': room,
      'note': note,
    };
  }

  
  factory TeacherScheduleModel.fromEntity(TeacherSchedule schedule) {
    return TeacherScheduleModel(
      id: schedule.id,
      classId: schedule.classId,
      className: schedule.className,
      startTime: schedule.startTime,
      endTime: schedule.endTime,
      room: schedule.room,
      note: schedule.note,
    );
  }

  @override
  TeacherScheduleModel copyWith({
    String? id,
    String? classId,
    String? className,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    String? note,
  }) {
    return TeacherScheduleModel(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      note: note ?? this.note,
    );
  }
}
