import 'dart:io';

import '../../domain/entities/admin_profile.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/admin_activity.dart';
import '../../domain/entities/admin_class.dart';
import '../../domain/entities/admin_student.dart';
import '../../domain/entities/admin_teacher.dart';
import '../../domain/entities/class_student.dart';
import '../../domain/entities/class_session.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/entities/admin_feedback.dart';
import '../../domain/entities/cart_preview.dart';

class SessionAttendanceInfo {
  final int sessionId;
  final List<StudentAttendanceEntry> entries;

  const SessionAttendanceInfo({required this.sessionId, required this.entries});
}

class StudentAttendanceEntry {
  final int studentId;
  final String studentName;
  final bool isAbsent;
  final String? note;

  const StudentAttendanceEntry({
    required this.studentId,
    required this.studentName,
    required this.isAbsent,
    this.note,
  });

  factory StudentAttendanceEntry.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceEntry(
      studentId: json['studentId'] ?? 0,
      studentName: json['studentName'] ?? '',
      isAbsent: json['absent'] ?? false,
      note: json['note'],
    );
  }
}

abstract class AdminApiDataSource {
  Future<AdminProfile> getAdminProfile(String userId);
  Future<AdminProfile> updateAdminProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    String? avatarUrl,
  });
  Future<AdminDashboardStats> getDashboardStats();
  Future<List<AdminActivity>> getRecentActivities({int limit = 10});
  Future<List<AdminClass>> getClasses({ClassStatus? statusFilter});
  Future<AdminClass> getClassById(String classId);
  Future<AdminClass> updateClass({
    required String classId,
    required String name,
    required String schedule,
    required String timeRange,
    required String room,
    String? startDate,
    int? maxStudents,
  });
  Future<List<ClassStudent>> getClassStudents(String classId);
  Future<List<AdminStudent>> getStudents({String? searchQuery});
  Future<AdminStudent> getStudentById(String studentId);
  Future<List<AdminClass>> getStudentEnrolledClasses(String studentId);
  Future<AdminStudent> updateStudent(AdminStudent student);
  Future<List<AdminTeacher>> getTeachers({String? searchQuery});
  Future<AdminTeacher> getTeacherById(String teacherId);
  Future<void> createTeacher({
    required String name,
    required String phoneNumber,
    String? email,
    DateTime? dateOfBirth,
    String? imageUrl,
  });

  Future<AdminTeacher> updateTeacher({
    required String teacherId,
    required String name,
    required String phoneNumber,
    String? email,
    DateTime? dateOfBirth,
    String? imageUrl,
  });

  Future<List<Promotion>> getActivePromotions();
  Future<List<Promotion>> getPromotionsByCourse(String courseId);
  Future<Promotion> validatePromotionCode(String code);

  Future<Map<String, dynamic>> registerCourses({
    required int studentId,
    required List<int> classIds,
    required int paymentMethodId,
    String? notes,
  });

  Future<Map<String, dynamic>> createStudent({
    required String name,
    required String phoneNumber,
    String? email,
  });

  Future<Map<String, dynamic>?> searchStudentByPhone(String phoneNumber);

  Future<List<Map<String, dynamic>>> getDegreeTypes();

  Future<List<Map<String, dynamic>>> getCategories();

  Future<List<Map<String, dynamic>>> getRooms();

  Future<List<AdminFeedback>> getClassFeedbacks(String classId);

  Future<ClassSession> updateSession({
    required int sessionId,
    required String status,
    String? note,
  });

  Future<SessionAttendanceInfo> getSessionAttendance(int sessionId);

  Future<CartPreview> previewCart(List<String> classIds, {String? studentId});

  Future<String?> uploadFile(File file);

  /// Xác nhận thanh toán tiền mặt - đánh dấu hóa đơn đã thanh toán và gửi email
  Future<void> confirmCashPayment(int invoiceId);
}
