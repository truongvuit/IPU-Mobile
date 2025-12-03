import '../../domain/entities/admin_class.dart';

class AdminClassModel extends AdminClass {
  const AdminClassModel({
    required super.id,
    required super.name,
    required super.courseName,
    required super.status,
    required super.schedule,
    required super.timeRange,
    required super.room,
    required super.teacherName,
    super.teacherId,
    required super.startDate,
    super.endDate,
    required super.totalStudents,
    required super.maxStudents,
    super.imageUrl,
    super.tuitionFee,
  });

  factory AdminClassModel.fromJson(Map<String, dynamic> json) {
    final startTime = json['startTime']?.toString() ?? '';
    final endTime = json['endTime']?.toString() ?? '';
    final timeRange = startTime.isNotEmpty && endTime.isNotEmpty
        ? '$startTime - $endTime'
        : (json['timeRange'] as String? ?? '');

    return AdminClassModel(
      id: (json['classId'] ?? json['id'] ?? json['malop'] ?? '').toString(),

      name:
          json['className'] as String? ??
          json['name'] as String? ??
          json['tenlop'] as String? ??
          '',

      courseName:
          json['courseName'] as String? ?? json['tenkhoahoc'] as String? ?? '',

      status: _parseStatus(
        json['status'] as String? ?? json['trangthai'] as String?,
      ),

      schedule:
          json['schedulePattern'] as String? ??
          json['schedule'] as String? ??
          json['lich'] as String? ??
          '',

      timeRange: timeRange,

      room:
          json['roomName'] as String? ??
          json['room'] as String? ??
          json['tenphong'] as String? ??
          '',

      teacherName:
          json['instructorName'] as String? ??
          json['teacherName'] as String? ??
          json['tengiangvien'] as String? ??
          '',

      teacherId:
          json['lecturerId']?.toString() ??
          json['teacherId']?.toString() ??
          json['magiangvien']?.toString(),

      startDate: _parseDate(json['startDate'] ?? json['ngaybatdau']),

      endDate: _parseDateNullable(json['endDate'] ?? json['ngayketthuc']),

      totalStudents:
          json['currentEnrollment'] as int? ??
          json['totalStudents'] as int? ??
          json['sohocvien'] as int? ??
          0,

      maxStudents:
          json['maxCapacity'] as int? ??
          json['maxStudents'] as int? ??
          json['succhua'] as int? ??
          30,

      imageUrl: json['imageUrl'] as String? ?? json['hinhanh'] as String?,

      tuitionFee: (json['tuitionFee'] ?? json['hocphi'] ?? 0).toDouble(),
    );
  }

  static ClassStatus _parseStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'inprogress':
      case 'in_progress':
      case 'ongoing':
      case 'active':
      case 'đang diễn ra':
        return ClassStatus.ongoing;
      case 'upcoming':
      case 'draft':
      case 'sắp tới':
        return ClassStatus.upcoming;
      case 'completed':
      case 'closed':
      case 'finished':
      case 'đã kết thúc':
        return ClassStatus.completed;
      default:
        return ClassStatus.ongoing;
    }
  }

  static DateTime _parseDate(dynamic date) {
    if (date == null) return DateTime.now();
    if (date is DateTime) return date;
    if (date is String) {
      return DateTime.tryParse(date) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static DateTime? _parseDateNullable(dynamic date) {
    if (date == null) return null;
    if (date is DateTime) return date;
    if (date is String) {
      return DateTime.tryParse(date);
    }
    return null;
  }

  Map<String, dynamic> toJson() {
    return {
      'classId': id,
      'className': name,
      'courseName': courseName,
      'status': status.name,
      'schedulePattern': schedule,
      'timeRange': timeRange,
      'roomName': room,
      'instructorName': teacherName,
      'lecturerId': teacherId,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate?.toIso8601String(),
      'currentEnrollment': totalStudents,
      'maxCapacity': maxStudents,
      'imageUrl': imageUrl,
      'tuitionFee': tuitionFee,
    };
  }

  factory AdminClassModel.fromEntity(AdminClass entity) {
    return AdminClassModel(
      id: entity.id,
      name: entity.name,
      courseName: entity.courseName,
      status: entity.status,
      schedule: entity.schedule,
      timeRange: entity.timeRange,
      room: entity.room,
      teacherName: entity.teacherName,
      teacherId: entity.teacherId,
      startDate: entity.startDate,
      endDate: entity.endDate,
      totalStudents: entity.totalStudents,
      maxStudents: entity.maxStudents,
      imageUrl: entity.imageUrl,
      tuitionFee: entity.tuitionFee,
    );
  }

  AdminClass toEntity() {
    return AdminClass(
      id: id,
      name: name,
      courseName: courseName,
      status: status,
      schedule: schedule,
      timeRange: timeRange,
      room: room,
      teacherName: teacherName,
      teacherId: teacherId,
      startDate: startDate,
      endDate: endDate,
      totalStudents: totalStudents,
      maxStudents: maxStudents,
      imageUrl: imageUrl,
      tuitionFee: tuitionFee,
    );
  }
}
