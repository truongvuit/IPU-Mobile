import '../../domain/entities/admin_profile.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/admin_activity.dart';
import '../../domain/entities/admin_class.dart';
import '../../domain/entities/admin_student.dart';
import '../../domain/entities/admin_teacher.dart';
import '../../domain/entities/class_student.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/entities/admin_feedback.dart';

abstract class AdminRepository {
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
  });

  Future<List<ClassStudent>> getClassStudents(String classId);

  Future<List<AdminStudent>> getStudents({String? searchQuery});

  Future<AdminStudent> getStudentById(String studentId);

  Future<List<AdminClass>> getStudentEnrolledClasses(String studentId);

  Future<AdminStudent> updateStudent({
    required String studentId,
    required String fullName,
    required String phoneNumber,
    String? email,
    String? address,
    String? occupation,
    String? educationLevel,
    DateTime? dateOfBirth,
    String? password,
  });

  Future<List<AdminTeacher>> getTeachers({String? searchQuery});

  Future<AdminTeacher> getTeacherById(String teacherId);

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
}
