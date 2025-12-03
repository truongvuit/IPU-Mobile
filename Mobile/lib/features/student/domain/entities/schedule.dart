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
  });

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
    );
  }
}
