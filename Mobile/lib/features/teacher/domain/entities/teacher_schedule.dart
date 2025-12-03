import 'package:equatable/equatable.dart';

class TeacherSchedule extends Equatable {
  final String id;
  final String classId;
  final String className;
  final DateTime startTime;
  final DateTime endTime;
  final String room;
  final String? note;

  const TeacherSchedule({
    required this.id,
    required this.classId,
    required this.className,
    required this.startTime,
    required this.endTime,
    required this.room,
    this.note,
  });

  bool get isToday {
    final now = DateTime.now();
    return startTime.year == now.year &&
        startTime.month == now.month &&
        startTime.day == now.day;
  }

  bool get isUpcoming => startTime.isAfter(DateTime.now());

  factory TeacherSchedule.fromJson(Map<String, dynamic> json) {
    return TeacherSchedule(
      id: json['id'] ?? '',
      classId: json['classId'] ?? '',
      className: json['className'] ?? '',
      startTime: DateTime.tryParse(json['startTime'] ?? '') ?? DateTime.now(),
      endTime: DateTime.tryParse(json['endTime'] ?? '') ??
          DateTime.now().add(const Duration(hours: 1)),
      room: json['room'] ?? 'N/A',
      note: json['note'],
    );
  }

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

  TeacherSchedule copyWith({
    String? id,
    String? classId,
    String? className,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    String? note,
  }) {
    return TeacherSchedule(
      id: id ?? this.id,
      classId: classId ?? this.classId,
      className: className ?? this.className,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        classId,
        className,
        startTime,
        endTime,
        room,
        note,
      ];
}
