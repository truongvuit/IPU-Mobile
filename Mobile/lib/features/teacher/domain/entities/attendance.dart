import 'package:equatable/equatable.dart';


class AttendanceRecord extends Equatable {
  final String id;
  final String studentId;
  final String classId;
  final DateTime date;
  final String status; 
  final String? note;
  final DateTime createdAt;
  final String? studentName;
  final String? studentCode;
  final String? studentAvatar;

  const AttendanceRecord({
    required this.id,
    required this.studentId,
    required this.classId,
    required this.date,
    required this.status,
    this.note,
    required this.createdAt,
    this.studentName,
    this.studentCode,
    this.studentAvatar,
  });

  bool get isPresent => status == 'present';
  bool get isAbsent => status == 'absent';
  bool get isLate => status == 'late';
  bool get isExcused => status == 'excused';

  @override
  List<Object?> get props => [
        id,
        studentId,
        classId,
        date,
        status,
        note,
        createdAt,
        studentName,
        studentCode,
        studentAvatar,
      ];

  AttendanceRecord copyWith({
    String? id,
    String? studentId,
    String? classId,
    DateTime? date,
    String? status,
    String? note,
    DateTime? createdAt,
    String? studentName,
    String? studentCode,
    String? studentAvatar,
  }) {
    return AttendanceRecord(
      id: id ?? this.id,
      studentId: studentId ?? this.studentId,
      classId: classId ?? this.classId,
      date: date ?? this.date,
      status: status ?? this.status,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      studentName: studentName ?? this.studentName,
      studentCode: studentCode ?? this.studentCode,
      studentAvatar: studentAvatar ?? this.studentAvatar,
    );
  }
}


class AttendanceSession extends Equatable {
  final String id;
  final String classId;
  final DateTime date;
  final List<AttendanceRecord> records;
  final bool isCompleted;

  const AttendanceSession({
    required this.id,
    required this.classId,
    required this.date,
    required this.records,
    this.isCompleted = false,
  });

  int get totalPresent => records.where((r) => r.isPresent || r.isLate).length;
  int get totalAbsent => records.where((r) => r.isAbsent).length;
  int get totalExcused => records.where((r) => r.isExcused).length;
  int get totalPending => records.where((r) => r.status == 'pending').length;

  @override
  List<Object?> get props => [id, classId, date, records, isCompleted];
}
