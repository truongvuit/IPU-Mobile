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
import '../../domain/repositories/admin_repository.dart';
import '../datasources/admin_api_datasource.dart';

class AdminRepositoryImpl implements AdminRepository {
  final AdminApiDataSource dataSource;

  AdminRepositoryImpl({required this.dataSource});

  @override
  Future<AdminProfile> getAdminProfile(String userId) {
    return dataSource.getAdminProfile(userId);
  }

  @override
  Future<AdminProfile> updateAdminProfile({
    required String userId,
    required String fullName,
    required String phoneNumber,
    String? avatarUrl,
  }) {
    return dataSource.updateAdminProfile(
      userId: userId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      avatarUrl: avatarUrl,
    );
  }

  @override
  Future<AdminDashboardStats> getDashboardStats() {
    return dataSource.getDashboardStats();
  }

  @override
  Future<List<AdminActivity>> getRecentActivities({int limit = 10}) {
    return dataSource.getRecentActivities(limit: limit);
  }

  @override
  Future<List<AdminClass>> getClasses({ClassStatus? statusFilter}) {
    return dataSource.getClasses(statusFilter: statusFilter);
  }

  @override
  Future<AdminClass> getClassById(String classId) {
    return dataSource.getClassById(classId);
  }

  @override
  Future<AdminClass> updateClass({
    required String classId,
    required String name,
    required String schedule,
    required String timeRange,
    required String room,
  }) {
    return dataSource.updateClass(
      classId: classId,
      name: name,
      schedule: schedule,
      timeRange: timeRange,
      room: room,
    );
  }

  @override
  Future<List<ClassStudent>> getClassStudents(String classId) {
    return dataSource.getClassStudents(classId);
  }

  @override
  Future<List<AdminStudent>> getStudents({String? searchQuery}) {
    return dataSource.getStudents(searchQuery: searchQuery);
  }

  @override
  Future<AdminStudent> getStudentById(String studentId) {
    return dataSource.getStudentById(studentId);
  }

  @override
  Future<List<AdminClass>> getStudentEnrolledClasses(String studentId) {
    return dataSource.getStudentEnrolledClasses(studentId);
  }

  @override
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
  }) {
    return dataSource.updateStudent(
      studentId: studentId,
      fullName: fullName,
      phoneNumber: phoneNumber,
      email: email,
      address: address,
      occupation: occupation,
      educationLevel: educationLevel,
      dateOfBirth: dateOfBirth,
      password: password,
    );
  }

  @override
  Future<List<AdminTeacher>> getTeachers({String? searchQuery}) {
    return dataSource.getTeachers(searchQuery: searchQuery);
  }

  @override
  Future<AdminTeacher> getTeacherById(String teacherId) {
    return dataSource.getTeacherById(teacherId);
  }

  @override
  Future<void> createTeacher({
    required String name,
    required String phoneNumber,
    String? email,
    DateTime? dateOfBirth,
    String? imageUrl,
  }) {
    return dataSource.createTeacher(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      dateOfBirth: dateOfBirth,
      imageUrl: imageUrl,
    );
  }

  @override
  Future<List<Promotion>> getActivePromotions() {
    return dataSource.getActivePromotions();
  }

  @override
  Future<List<Promotion>> getPromotionsByCourse(String courseId) {
    return dataSource.getPromotionsByCourse(courseId);
  }

  @override
  Future<Promotion> validatePromotionCode(String code) {
    return dataSource.validatePromotionCode(code);
  }

  @override
  Future<Map<String, dynamic>> registerCourses({
    required int studentId,
    required List<int> classIds,
    required int paymentMethodId,
    String? notes,
  }) {
    return dataSource.registerCourses(
      studentId: studentId,
      classIds: classIds,
      paymentMethodId: paymentMethodId,
      notes: notes,
    );
  }

  @override
  Future<Map<String, dynamic>> createStudent({
    required String name,
    required String phoneNumber,
    String? email,
  }) {
    return dataSource.createStudent(
      name: name,
      phoneNumber: phoneNumber,
      email: email,
    );
  }

  @override
  Future<Map<String, dynamic>?> searchStudentByPhone(String phoneNumber) {
    return dataSource.searchStudentByPhone(phoneNumber);
  }

  @override
  Future<List<Map<String, dynamic>>> getDegreeTypes() {
    return dataSource.getDegreeTypes();
  }

  @override
  Future<List<Map<String, dynamic>>> getCategories() {
    return dataSource.getCategories();
  }

  @override
  Future<List<Map<String, dynamic>>> getRooms() {
    return dataSource.getRooms();
  }

  @override
  Future<List<AdminFeedback>> getClassFeedbacks(String classId) {
    return dataSource.getClassFeedbacks(classId);
  }

  @override
  Future<ClassSession> updateSession({
    required int sessionId,
    required String status,
    String? note,
  }) {
    return dataSource.updateSession(
      sessionId: sessionId,
      status: status,
      note: note,
    );
  }

  @override
  Future<SessionAttendanceInfo> getSessionAttendance(int sessionId) {
    return dataSource.getSessionAttendance(sessionId);
  }
}
