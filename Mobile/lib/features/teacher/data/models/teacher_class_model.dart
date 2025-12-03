import '../../domain/entities/teacher_class.dart';

class TeacherClassModel extends TeacherClass {
  const TeacherClassModel({
    required super.id,
    required super.code,
    required super.name,
    required super.courseType,
    required super.totalStudents,
    required super.schedule,
    required super.startTime,
    required super.endTime,
    required super.room,
    required super.startDate,
    super.endDate,
    super.status,
    super.imageUrl,
    super.completionPercentage,
  });

  factory TeacherClassModel.fromJson(Map<String, dynamic> json) {
    return TeacherClassModel(
      id: json['classId']?.toString() ?? json['maLop']?.toString() ?? '',
      code:
          json['classCode'] ??
          json['classId']?.toString() ??
          json['maLop']?.toString() ??
          '',
      name: json['className'] ?? json['tenLop'] ?? '',
      courseType:
          json['courseType'] ??
          json['courseName'] ??
          json['loaiKhoaHoc'] ??
          'General',
      
      totalStudents:
          json['currentEnrollment'] ??
          json['totalStudents'] ??
          json['soHocVien'] ??
          0,
      
      schedule:
          json['schedulePattern'] ?? json['schedule'] ?? json['lich'] ?? '',
      
      startTime: _parseTime(json['startTime']),
      endTime: _parseTime(json['endTime']),
      room: json['roomName'] ?? json['tenPhong'] ?? '',
      startDate: json['startDate'] != null
          ? DateTime.parse(json['startDate'])
          : DateTime.now(),
      endDate: json['endDate'] != null ? DateTime.parse(json['endDate']) : null,
      status: json['status'] ?? json['trangThai'] ?? 'ongoing',
      imageUrl: json['imageUrl'] ?? json['hinhAnh'],
      completionPercentage: (json['completionPercentage'] ?? 0).toDouble(),
    );
  }

  
  static DateTime _parseTime(dynamic time) {
    if (time == null) return DateTime(2024, 1, 1, 8, 0);
    if (time is String) {
      
      final parts = time.split(':');
      if (parts.length >= 2) {
        return DateTime(
          2024,
          1,
          1,
          int.tryParse(parts[0]) ?? 8,
          int.tryParse(parts[1]) ?? 0,
          parts.length > 2 ? (int.tryParse(parts[2]) ?? 0) : 0,
        );
      }
      
      try {
        return DateTime.parse(time);
      } catch (_) {
        return DateTime(2024, 1, 1, 8, 0);
      }
    }
    return DateTime(2024, 1, 1, 8, 0);
  }

  
  Map<String, dynamic> toJson() {
    return {
      'classId': id,
      'classCode': code,
      'className': name,
      'courseType': courseType,
      'totalStudents': totalStudents,
      'schedule': schedule,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'roomName': room,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'status': status,
      'imageUrl': imageUrl,
      'completionPercentage': completionPercentage,
    };
  }

  factory TeacherClassModel.fromEntity(TeacherClass teacherClass) {
    return TeacherClassModel(
      id: teacherClass.id,
      code: teacherClass.code,
      name: teacherClass.name,
      courseType: teacherClass.courseType,
      totalStudents: teacherClass.totalStudents,
      schedule: teacherClass.schedule,
      startTime: teacherClass.startTime,
      endTime: teacherClass.endTime,
      room: teacherClass.room,
      startDate: teacherClass.startDate,
      endDate: teacherClass.endDate,
      status: teacherClass.status,
      imageUrl: teacherClass.imageUrl,
      completionPercentage: teacherClass.completionPercentage,
    );
  }

  @override
  TeacherClassModel copyWith({
    String? id,
    String? code,
    String? name,
    String? courseType,
    int? totalStudents,
    String? schedule,
    DateTime? startTime,
    DateTime? endTime,
    String? room,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    String? imageUrl,
    double? completionPercentage,
  }) {
    return TeacherClassModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      courseType: courseType ?? this.courseType,
      totalStudents: totalStudents ?? this.totalStudents,
      schedule: schedule ?? this.schedule,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      room: room ?? this.room,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      completionPercentage: completionPercentage ?? this.completionPercentage,
    );
  }
}
