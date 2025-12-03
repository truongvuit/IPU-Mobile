import 'package:flutter_bloc/flutter_bloc.dart';

import 'admin_event.dart';
import 'admin_state.dart';

import '../../domain/repositories/admin_repository.dart';
import '../../domain/entities/admin_profile.dart';
import '../../domain/entities/admin_dashboard_stats.dart';
import '../../domain/entities/admin_activity.dart';

class AdminBloc extends Bloc<AdminEvent, AdminState> {
  final AdminRepository _repository;

  AdminRepository get adminRepository => _repository;

  AdminBloc({required AdminRepository repository}) 
      : _repository = repository,
        super(const AdminInitial()) {
    on<LoadAdminDashboard>(_onLoadAdminDashboard);
    on<RefreshAdminDashboard>(_onRefreshAdminDashboard);
    on<LoadAdminProfile>(_onLoadAdminProfile);
    on<UpdateAdminProfile>(_onUpdateAdminProfile);

    on<LoadClassList>(_onLoadClassList);
    on<LoadClassDetail>(_onLoadClassDetail);
    on<UpdateClass>(_onUpdateClass);

    on<LoadStudentList>(_onLoadStudentList);
    on<LoadClassStudentList>(_onLoadClassStudentList);
    on<LoadStudentDetail>(_onLoadStudentDetail);
    on<UpdateStudent>(_onUpdateStudent);

    on<LoadTeacherList>(_onLoadTeacherList);
    on<LoadTeacherDetail>(_onLoadTeacherDetail);
    on<LoadClassFeedbacks>(_onLoadClassFeedbacks);
  }

  Future<void> _onLoadAdminDashboard(
    LoadAdminDashboard event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      AdminProfile profile;
      try {
        profile = await _repository.getAdminProfile('1');
      } catch (_) {
        profile = const AdminProfile(
          id: '1',
          fullName: 'Admin',
          email: '',
          role: 'ADMIN',
        );
      }

      AdminDashboardStats stats;
      try {
        stats = await _repository.getDashboardStats();
      } catch (_) {
        stats = const AdminDashboardStats(
          ongoingClasses: 0,
          todayRegistrations: 0,
          activeStudents: 0,
          monthlyRevenue: 0.0,
          totalTeachers: 0,
          totalCourses: 0,
        );
      }

      List<AdminActivity> activities;
      try {
        activities = await _repository.getRecentActivities();
      } catch (_) {
        activities = [];
      }

      emit(
        AdminDashboardLoaded(
          profile: profile,
          stats: stats,
          recentActivities: activities,
        ),
      );
    } catch (e) {
      emit(
        AdminDashboardLoaded(
          profile: const AdminProfile(
            id: '1',
            fullName: 'Admin',
            email: '',
            role: 'ADMIN',
          ),
          stats: const AdminDashboardStats(
            ongoingClasses: 0,
            todayRegistrations: 0,
            activeStudents: 0,
            monthlyRevenue: 0.0,
            totalTeachers: 0,
            totalCourses: 0,
          ),
          recentActivities: [],
        ),
      );
    }
  }

  Future<void> _onRefreshAdminDashboard(
    RefreshAdminDashboard event,
    Emitter<AdminState> emit,
  ) async {
    try {
      AdminProfile profile;
      try {
        profile = await _repository.getAdminProfile('1');
      } catch (_) {
        profile = const AdminProfile(
          id: '1',
          fullName: 'Admin',
          email: '',
          role: 'ADMIN',
        );
      }

      AdminDashboardStats stats;
      try {
        stats = await _repository.getDashboardStats();
      } catch (_) {
        stats = const AdminDashboardStats(
          ongoingClasses: 0,
          todayRegistrations: 0,
          activeStudents: 0,
          monthlyRevenue: 0.0,
          totalTeachers: 0,
          totalCourses: 0,
        );
      }

      List<AdminActivity> activities;
      try {
        activities = await _repository.getRecentActivities();
      } catch (_) {
        activities = [];
      }

      emit(
        AdminDashboardLoaded(
          profile: profile,
          stats: stats,
          recentActivities: activities,
        ),
      );
    } catch (e) {
      emit(AdminError('Không thể tải thông tin admin: ${e.toString()}'));
    }
  }

  Future<void> _onLoadAdminProfile(
    LoadAdminProfile event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final profile = await _repository.getAdminProfile('1');
      emit(AdminProfileLoaded(profile));
    } catch (e) {
      emit(AdminError('Không thể tải thông tin admin: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateAdminProfile(
    UpdateAdminProfile event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminProfileUpdating());

    try {
      final updatedProfile = await _repository.updateAdminProfile(
        userId: '1',
        fullName: event.fullName,
        phoneNumber: event.phoneNumber ?? '',
        avatarUrl: event.avatarUrl,
      );

      emit(AdminProfileUpdated(updatedProfile));
    } catch (e) {
      emit(AdminError('Không thể cập nhật thông tin: ${e.toString()}'));
    }
  }

  Future<void> _onLoadClassList(
    LoadClassList event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final classes = await _repository.getClasses(
        statusFilter: event.statusFilter,
      );

      emit(
        ClassListLoaded(classes: classes, appliedFilter: event.statusFilter),
      );
    } catch (e) {
      emit(AdminError('Không thể tải danh sách lớp học: ${e.toString()}'));
    }
  }

  Future<void> _onLoadClassDetail(
    LoadClassDetail event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final classInfo = await _repository.getClassById(event.classId);
      final students = await _repository.getClassStudents(event.classId);

      emit(ClassDetailLoaded(classInfo: classInfo, students: students));
    } catch (e) {
      emit(AdminError('Không thể tải chi tiết lớp học: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateClass(
    UpdateClass event,
    Emitter<AdminState> emit,
  ) async {
    emit(const ClassUpdating());

    try {
      final updates = event.updates;
      final updatedClass = await _repository.updateClass(
        classId: event.classId,
        name: updates['name'] as String? ?? '',
        schedule: updates['schedule'] as String? ?? '',
        timeRange: updates['timeRange'] as String? ?? '',
        room: updates['room'] as String? ?? '',
      );

      emit(ClassUpdated(updatedClass));
    } catch (e) {
      emit(AdminError('Không thể cập nhật lớp học: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStudentList(
    LoadStudentList event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final students = await _repository.getStudents(
        searchQuery: event.searchQuery,
      );

      emit(
        StudentListLoaded(students: students, searchQuery: event.searchQuery),
      );
    } catch (e) {
      emit(AdminError('Không thể tải danh sách học viên: ${e.toString()}'));
    }
  }

  Future<void> _onLoadClassStudentList(
    LoadClassStudentList event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final classInfo = await _repository.getClassById(event.classId);
      final students = await _repository.getClassStudents(event.classId);

      emit(
        ClassStudentListLoaded(
          classId: event.classId,
          className: classInfo.name,
          students: students,
        ),
      );
    } catch (e) {
      emit(AdminError('Không thể tải danh sách học viên: ${e.toString()}'));
    }
  }

  Future<void> _onLoadStudentDetail(
    LoadStudentDetail event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final student = await _repository.getStudentById(event.studentId);
      final enrolledClasses = await _repository.getStudentEnrolledClasses(
        event.studentId,
      );

      emit(
        StudentDetailLoaded(student: student, enrolledClasses: enrolledClasses),
      );
    } catch (e) {
      emit(AdminError('Không thể tải thông tin học viên: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateStudent(
    UpdateStudent event,
    Emitter<AdminState> emit,
  ) async {
    emit(const StudentUpdating());

    try {
      final updates = event.updates;
      final updatedStudent = await _repository.updateStudent(
        studentId: event.studentId,
        fullName: updates['fullName'] as String? ?? '',
        phoneNumber: updates['phoneNumber'] as String? ?? '',
        email: updates['email'] as String?,
        address: updates['address'] as String?,
        occupation: updates['occupation'] as String?,
        educationLevel: updates['educationLevel'] as String?,
        dateOfBirth: updates['dateOfBirth'] != null 
            ? DateTime.tryParse(updates['dateOfBirth'] as String)
            : null,
        password: updates['password'] as String?,
      );

      emit(StudentUpdated(updatedStudent));
    } catch (e) {
      emit(AdminError('Không thể cập nhật học viên: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTeacherList(
    LoadTeacherList event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final teachers = await _repository.getTeachers(
        searchQuery: event.searchQuery,
      );

      emit(
        TeacherListLoaded(teachers: teachers, searchQuery: event.searchQuery),
      );
    } catch (e) {
      emit(AdminError('Không thể tải danh sách giảng viên: ${e.toString()}'));
    }
  }

  Future<void> _onLoadTeacherDetail(
    LoadTeacherDetail event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final teacher = await _repository.getTeacherById(event.teacherId);

      emit(TeacherDetailLoaded(teacher: teacher));
    } catch (e) {
      emit(AdminError('Không thể tải thông tin giảng viên: ${e.toString()}'));
    }
  }

  Future<void> _onLoadClassFeedbacks(
    LoadClassFeedbacks event,
    Emitter<AdminState> emit,
  ) async {
    emit(const AdminLoading());

    try {
      final feedbacks = await _repository.getClassFeedbacks(event.classId);
      emit(ClassFeedbacksLoaded(classId: event.classId, feedbacks: feedbacks));
    } catch (e) {
      emit(AdminError('Không thể tải phản hồi lớp học: ${e.toString()}'));
    }
  }
}
