import '../../domain/entities/attendance.dart';


class AttendanceRecordModel extends AttendanceRecord {
  const AttendanceRecordModel({
    required super.id,
    required super.studentId,
    required super.classId,
    required super.date,
    required super.status,
    super.note,
    required super.createdAt,
    super.studentName,
    super.studentCode,
    super.studentAvatar,
  });

  
  
  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    return AttendanceRecordModel(
      id: json['attendanceId']?.toString() ?? json['id']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? json['maHocVien']?.toString() ?? '',
      classId: json['classId']?.toString() ?? json['maLop']?.toString() ?? '',
      date: json['date'] != null 
          ? DateTime.parse(json['date']) 
          : json['ngayHoc'] != null
              ? DateTime.parse(json['ngayHoc'])
              : DateTime.now(),
      status: _mapStatus(json['status'] ?? json['vang']),
      note: json['note'] ?? json['ghiChu'],
      createdAt: json['createdAt'] != null 
          ? DateTime.parse(json['createdAt']) 
          : DateTime.now(),
      studentName: json['studentName'] ?? json['tenHocVien'],
      studentCode: json['studentCode'] ?? json['maHocVien'],
      studentAvatar: json['studentAvatar'] ?? json['anhDaiDien'],
    );
  }

  
  static String _mapStatus(dynamic status) {
    if (status is bool) {
      return status ? 'absent' : 'present';
    }
    if (status is int) {
      return status == 1 ? 'absent' : 'present';
    }
    final statusStr = status.toString().toLowerCase();
    if (statusStr == 'present' || statusStr == 'có mặt') return 'present';
    if (statusStr == 'absent' || statusStr == 'vắng') return 'absent';
    if (statusStr == 'late' || statusStr == 'muộn') return 'late';
    if (statusStr == 'excused' || statusStr == 'có phép') return 'excused';
    return 'present';
  }

  
  Map<String, dynamic> toJson() {
    return {
      'attendanceId': id,
      'studentId': studentId,
      'classId': classId,
      'date': date.toIso8601String(),
      'status': status,
      'note': note,
      'createdAt': createdAt.toIso8601String(),
      'studentName': studentName,
      'studentCode': studentCode,
      'studentAvatar': studentAvatar,
    };
  }

  factory AttendanceRecordModel.fromEntity(AttendanceRecord record) {
    return AttendanceRecordModel(
      id: record.id,
      studentId: record.studentId,
      classId: record.classId,
      date: record.date,
      status: record.status,
      note: record.note,
      createdAt: record.createdAt,
      studentName: record.studentName,
      studentCode: record.studentCode,
      studentAvatar: record.studentAvatar,
    );
  }

  @override
  AttendanceRecordModel copyWith({
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
    return AttendanceRecordModel(
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
