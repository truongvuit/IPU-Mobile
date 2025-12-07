import 'class_session.dart';

enum ClassStatus {
  ongoing,
  upcoming,
  completed,
}

class AdminClass {
  final String id;
  final String name;
  final String courseName;
  final String? courseId;
  final ClassStatus status;
  final String schedule;
  final String timeRange;
  final String room;
  final String teacherName;
  final String? teacherId;
  final DateTime startDate;
  final DateTime? endDate;
  final int totalStudents;
  final int maxStudents;
  final String? imageUrl;
  final double tuitionFee;
  final int totalSessions;
  final List<ClassSession> sessions;

  const AdminClass({
    required this.id,
    required this.name,
    required this.courseName,
    this.courseId,
    required this.status,
    required this.schedule,
    required this.timeRange,
    required this.room,
    required this.teacherName,
    this.teacherId,
    required this.startDate,
    this.endDate,
    required this.totalStudents,
    required this.maxStudents,
    this.imageUrl,
    this.tuitionFee = 0,
    this.totalSessions = 0,
    this.sessions = const [],
  });

  static final empty = AdminClass(
    id: '',
    name: '',
    courseName: '',
    status: ClassStatus.upcoming,
    schedule: '',
    timeRange: '',
    room: '',
    teacherName: '',
    startDate: DateTime.now(),
    totalStudents: 0,
    maxStudents: 0,
    tuitionFee: 0,
  );

  String get statusText {
    switch (status) {
      case ClassStatus.ongoing:
        return 'Đang diễn ra';
      case ClassStatus.upcoming:
        return 'Sắp tới';
      case ClassStatus.completed:
        return 'Đã kết thúc';
    }
  }

  String get studentCountText => '$totalStudents/$maxStudents';

  bool get isFull => totalStudents >= maxStudents;

  double get enrollmentPercentage =>
      maxStudents > 0 ? (totalStudents / maxStudents) * 100 : 0;

  
  int get completedSessionsCount =>
      sessions.where((s) => s.status == SessionStatus.completed).length;

  
  int get canceledSessionsCount =>
      sessions.where((s) => s.status == SessionStatus.canceled).length;

  
  int get remainingSessionsCount =>
      sessions.where((s) => s.status == SessionStatus.notCompleted).length;

  
  double get completionPercentage =>
      sessions.isNotEmpty ? (completedSessionsCount / sessions.length) * 100 : 0;

  
  String get sessionStatsText => '$completedSessionsCount/${sessions.length} buổi';

  factory AdminClass.fromJson(Map<String, dynamic> json) {
    return AdminClass(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      courseName: json['courseName'] ?? '',
      status: ClassStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => ClassStatus.upcoming,
      ),
      schedule: json['schedule'] ?? '',
      timeRange: json['timeRange'] ?? '',
      room: json['room'] ?? '',
      teacherName: json['teacherName'] ?? '',
      teacherId: json['teacherId'],
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      totalStudents: json['totalStudents'] ?? 0,
      maxStudents: json['maxStudents'] ?? 0,
      imageUrl: json['imageUrl'],
      tuitionFee: (json['tuitionFee'] ?? 0).toDouble(),
    );
  }
}
