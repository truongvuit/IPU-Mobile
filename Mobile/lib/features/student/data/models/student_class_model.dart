import '../../domain/entities/student_class.dart';

class StudentClassModel extends StudentClass {
  const StudentClassModel({
    required super.id,
    required super.courseId,
    required super.courseName,
    required super.imageUrl,
    required super.teacherName,
    required super.room,
    required super.startTime,
    required super.endTime,
    required super.status,
    super.isOnline,
    required super.currentStudents,
    super.schedule,
    super.meetingUrl,
    super.teacherEmail,
    super.teacherSpecialization,
    super.teacherCertificates,
    super.courseType,
    super.level,
    super.duration,
    super.maxStudents,
    super.students = const [],
    super.attendanceRate = 0.0,
    super.progress = 0.0,
    super.schedulePattern,
    super.dailyStartTime,
    super.dailyEndTime,
  });

  factory StudentClassModel.fromJson(Map<String, dynamic> json) {
    List<DateTime> scheduleList = [];
    if (json['schedule'] is List) {
      scheduleList = (json['schedule'] as List)
          .map((e) => DateTime.parse(e.toString()))
          .toList();
    }

    List<ClassStudent> studentList = [];
    if (json['students'] is List) {
      studentList = (json['students'] as List)
          .map(
            (s) => ClassStudent(
              name: s['fullName'] ?? s['name'] ?? '',
              code: s['studentId']?.toString() ?? s['code'] ?? '',
              avatarUrl: s['avatar'] ?? s['avatarUrl'],
            ),
          )
          .toList();
    }

    return StudentClassModel(
      id: json['classId']?.toString() ?? json['maLop']?.toString() ?? '',
      courseId:
          json['courseId']?.toString() ?? json['maKhoaHoc']?.toString() ?? '',
      courseName: json['courseName'] ?? json['tenKhoaHoc'] ?? '',
      imageUrl: json['imageUrl'] ?? json['hinhAnh'] ?? '',
      teacherName:
          json['instructorName'] ??
          json['lecturerName'] ??
          json['tenGiangVien'] ??
          '',
      room: json['roomName'] ?? json['tenPhong'] ?? '',
      startTime: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endTime: json['endDate'] != null
          ? DateTime.parse(json['endDate'])
          : DateTime.now().add(const Duration(days: 90)),
      status: json['status'] ?? json['trangThai'] ?? 'ongoing',
      isOnline: json['isOnline'] ?? false,
      currentStudents:
          json['currentEnrollment'] ??
          json['currentStudents'] ??
          json['soHocVienHienTai'] ??
          0,
      schedule: scheduleList,
      teacherEmail:
          json['instructorEmail'] ??
          json['lecturerEmail'] ??
          json['emailGiangVien'],
      teacherSpecialization: json['teacherSpecialization'],
      teacherCertificates: json['teacherCertificates'],
      courseType: json['courseType'],
      level: json['level'],
      duration: json['duration'],
      maxStudents: json['maxCapacity'] ?? json['maxStudents'],
      students: studentList,
      attendanceRate: (json['attendanceRate'] ?? 0.0).toDouble(),
      progress: (json['progress'] ?? 0.0).toDouble(),
      schedulePattern: json['schedulePattern'],
      dailyStartTime: json['startTime'],
      dailyEndTime: json['endTime'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': id,
      'courseId': courseId,
      'courseName': courseName,
      'imageUrl': imageUrl,
      'lecturerName': teacherName,
      'roomName': room,
      'startDate': startTime.toIso8601String(),
      'endDate': endTime.toIso8601String(),
      'status': status,
      'isOnline': isOnline,
      'currentStudents': currentStudents,
      'schedule': schedule.map((e) => e.toIso8601String()).toList(),
      'instructorEmail': teacherEmail,
      'teacherSpecialization': teacherSpecialization,
      'teacherCertificates': teacherCertificates,
      'courseType': courseType,
      'level': level,
      'duration': duration,
      'maxStudents': maxStudents,
      'students': students
          .map(
            (s) => {'name': s.name, 'code': s.code, 'avatarUrl': s.avatarUrl},
          )
          .toList(),
      'attendanceRate': attendanceRate,
      'progress': progress,
      'schedulePattern': schedulePattern,
      'startTime': dailyStartTime,
      'endTime': dailyEndTime,
    };
  }

  factory StudentClassModel.fromEntity(StudentClass studentClass) {
    return StudentClassModel(
      id: studentClass.id,
      courseId: studentClass.courseId,
      courseName: studentClass.courseName,
      imageUrl: studentClass.imageUrl,
      teacherName: studentClass.teacherName,
      room: studentClass.room,
      startTime: studentClass.startTime,
      endTime: studentClass.endTime,
      status: studentClass.status,
      isOnline: studentClass.isOnline,
      currentStudents: studentClass.currentStudents,
      schedule: studentClass.schedule,
      meetingUrl: studentClass.meetingUrl,
      teacherEmail: studentClass.teacherEmail,
      teacherSpecialization: studentClass.teacherSpecialization,
      teacherCertificates: studentClass.teacherCertificates,
      courseType: studentClass.courseType,
      level: studentClass.level,
      duration: studentClass.duration,
      maxStudents: studentClass.maxStudents,
      students: studentClass.students,
      attendanceRate: studentClass.attendanceRate,
      progress: studentClass.progress,
      schedulePattern: studentClass.schedulePattern,
      dailyStartTime: studentClass.dailyStartTime,
      dailyEndTime: studentClass.dailyEndTime,
    );
  }

  @override
  StudentClassModel copyWith({
    String? id,
    String? courseId,
    String? courseName,
    String? imageUrl,
    String? teacherName,
    String? room,
    DateTime? startTime,
    DateTime? endTime,
    String? status,
    bool? isOnline,
    int? currentStudents,
    List<DateTime>? schedule,
    String? meetingUrl,
    String? teacherEmail,
    String? teacherSpecialization,
    String? teacherCertificates,
    String? courseType,
    String? level,
    String? duration,
    int? maxStudents,
    List<ClassStudent>? students,
    double? attendanceRate,
    double? progress,
    String? schedulePattern,
    String? dailyStartTime,
    String? dailyEndTime,
  }) {
    return StudentClassModel(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      courseName: courseName ?? this.courseName,
      imageUrl: imageUrl ?? this.imageUrl,
      teacherName: teacherName ?? this.teacherName,
      room: room ?? this.room,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      currentStudents: currentStudents ?? this.currentStudents,
      schedule: schedule ?? this.schedule,
      meetingUrl: meetingUrl ?? this.meetingUrl,
      teacherEmail: teacherEmail ?? this.teacherEmail,
      teacherSpecialization:
          teacherSpecialization ?? this.teacherSpecialization,
      teacherCertificates: teacherCertificates ?? this.teacherCertificates,
      courseType: courseType ?? this.courseType,
      level: level ?? this.level,
      duration: duration ?? this.duration,
      maxStudents: maxStudents ?? this.maxStudents,
      students: students ?? this.students,
      attendanceRate: attendanceRate ?? this.attendanceRate,
      progress: progress ?? this.progress,
      schedulePattern: schedulePattern ?? this.schedulePattern,
      dailyStartTime: dailyStartTime ?? this.dailyStartTime,
      dailyEndTime: dailyEndTime ?? this.dailyEndTime,
    );
  }
}
