import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/teacher_repository.dart';
import '../../domain/entities/teacher_class.dart';
import '../../domain/entities/teacher_profile.dart';
import 'teacher_event.dart';
import 'teacher_state.dart';

class TeacherBloc extends Bloc<TeacherEvent, TeacherState> {
  final TeacherRepository repository;
  List<TeacherClass>? _cachedClasses;

  TeacherProfile? _cachedProfile;
  TeacherProfile? get cachedProfile => _cachedProfile;

  TeacherBloc({required this.repository}) : super(TeacherInitial()) {
    on<LoadTeacherDashboard>(_onLoadDashboard);
    on<LoadMyClasses>(_onLoadMyClasses);
    on<SearchClasses>(_onSearchClasses);
    on<FilterClasses>(_onFilterClasses);
    on<LoadClassDetail>(_onLoadClassDetail);
    on<LoadClassStudents>(_onLoadClassStudents);
    on<LoadStudentDetail>(_onLoadStudentDetail);
    on<SearchStudents>(_onSearchStudents);
    on<LoadAttendance>(_onLoadAttendance);
    on<RecordAttendance>(_onRecordAttendance);
    on<BatchRecordAttendance>(_onBatchRecordAttendance);
    on<LoadWeekSchedule>(_onLoadWeekSchedule);
    on<LoadTodaySchedule>(_onLoadTodaySchedule);
    on<LoadTeacherProfile>(_onLoadProfile);
    on<UpdateTeacherProfile>(_onUpdateProfile);
  }

  Future<void> _onLoadDashboard(
    LoadTeacherDashboard event,
    Emitter<TeacherState> emit,
  ) async {
    emit(const TeacherLoading(action: 'Đang tải dashboard...'));

    try {
      final todayScheduleResult = await repository.getTodaySchedule();
      final weekScheduleResult = await repository.getWeekSchedule(
        DateTime.now(),
      );
      final classesResult = await repository.getMyClasses();
      final profileResult = await repository.getProfile();

      if (todayScheduleResult.isLeft()) {
        final error = todayScheduleResult.fold(
          (l) => l,
          (_) => 'Unknown error',
        );
        emit(TeacherError(error));
        return;
      }

      if (classesResult.isLeft()) {
        final error = classesResult.fold((l) => l, (_) => 'Unknown error');
        emit(TeacherError(error));
        return;
      }

      if (profileResult.isLeft()) {
        final error = profileResult.fold((l) => l, (_) => 'Unknown error');
        emit(TeacherError(error));
        return;
      }

      final schedule = todayScheduleResult.getOrElse(() => []);
      final weekSchedule = weekScheduleResult.getOrElse(() => []);
      final classes = classesResult.getOrElse(() => []);
      final profile = profileResult.getOrElse(
        () => throw Exception('Profile not found'),
      );

      _cachedProfile = profile;

      final sortedClasses = [...classes];
      sortedClasses.sort((a, b) {
        int getStatusPriority(String? status) {
          switch (status?.toLowerCase()) {
            case 'ongoing':
              return 0;
            case 'upcoming':
              return 1;
            case 'completed':
              return 2;
            default:
              return 1;
          }
        }

        return getStatusPriority(
          a.status,
        ).compareTo(getStatusPriority(b.status));
      });

      emit(
        DashboardLoaded(
          todaySchedule: schedule,
          weekSchedule: weekSchedule,
          recentClasses: sortedClasses.take(3).toList(),
          profile: profile,
        ),
      );
    } catch (e) {
      emit(TeacherError('Không thể tải dashboard: ${e.toString()}'));
    }
  }

  Future<void> _onLoadMyClasses(
    LoadMyClasses event,
    Emitter<TeacherState> emit,
  ) async {
    emit(const TeacherLoading(action: 'Đang tải danh sách lớp...'));
    final result = await repository.getMyClasses();
    result.fold((error) => emit(TeacherError(error)), (classes) {
      _cachedClasses = classes;
      // Sort: current/upcoming classes first, then past/completed classes
      final sortedClasses = _sortClassesByStatus(classes);
      emit(ClassesLoaded(sortedClasses));
    });
  }

  /// Sort classes: Active/Upcoming first, then Past/Completed at the bottom
  List<TeacherClass> _sortClassesByStatus(List<TeacherClass> classes) {
    final now = DateTime.now();
    
    final activeClasses = <TeacherClass>[];
    final upcomingClasses = <TeacherClass>[];
    final pastClasses = <TeacherClass>[];
    
    for (final c in classes) {
      final isCompleted = c.status?.toLowerCase() == 'completed' || 
                          c.status?.toLowerCase() == 'hoàn thành';
      final isPast = c.endDate != null && c.endDate!.isBefore(now);
      
      if (isCompleted || isPast) {
        pastClasses.add(c);
      } else if (c.startDate.isAfter(now)) {
        upcomingClasses.add(c);
      } else {
        activeClasses.add(c);
      }
    }
    
    // Sort each group by start date
    activeClasses.sort((a, b) => a.startDate.compareTo(b.startDate));
    upcomingClasses.sort((a, b) => a.startDate.compareTo(b.startDate));
    pastClasses.sort((a, b) => (b.endDate ?? b.startDate).compareTo(a.endDate ?? a.startDate));
    
    return [...activeClasses, ...upcomingClasses, ...pastClasses];
  }

  Future<void> _onSearchClasses(
    SearchClasses event,
    Emitter<TeacherState> emit,
  ) async {
    if (_cachedClasses == null) {
      await _onLoadMyClasses(LoadMyClasses(), emit);
      if (_cachedClasses == null) return;
    }

    final filtered = _cachedClasses!
        .where(
          (c) =>
              (c.name ?? '').toLowerCase().contains(
                event.query.toLowerCase(),
              ) ||
              c.code.toLowerCase().contains(event.query.toLowerCase()),
        )
        .toList();
    emit(ClassesLoaded(_sortClassesByStatus(filtered)));
  }

  Future<void> _onFilterClasses(
    FilterClasses event,
    Emitter<TeacherState> emit,
  ) async {
    if (_cachedClasses == null) {
      await _onLoadMyClasses(LoadMyClasses(), emit);
      if (_cachedClasses == null) return;
    }

    List<TeacherClass> filtered;
    final statusLower = event.status.toLowerCase();

    if (statusLower == 'all') {
      filtered = _cachedClasses!;
    } else if (statusLower == 'ongoing') {
      filtered = _cachedClasses!.where((c) {
        final s = (c.status ?? '').toLowerCase();
        return s == 'active' ||
            s == 'ongoing' ||
            s == 'inprogress' ||
            s == 'in_progress' ||
            s == 'đang học';
      }).toList();
    } else if (statusLower == 'completed') {
      filtered = _cachedClasses!.where((c) {
        final s = c.status?.toLowerCase();
        return s == 'completed' || s == 'closed';
      }).toList();
    } else {
      filtered = _cachedClasses!
          .where((c) => c.status?.toLowerCase() == statusLower)
          .toList();
    }
    emit(ClassesLoaded(_sortClassesByStatus(filtered)));
  }

  Future<void> _onLoadClassDetail(
    LoadClassDetail event,
    Emitter<TeacherState> emit,
  ) async {
    emit(const TeacherLoading(action: 'Đang tải chi tiết lớp'));

    try {
      final classDetailResult = await repository.getClassDetail(event.classId);
      final studentsResult = await repository.getClassStudents(event.classId);

      if (classDetailResult.isLeft()) {
        final error = classDetailResult.fold((l) => l, (_) => 'Unknown error');
        emit(TeacherError(error));
        return;
      }

      if (studentsResult.isLeft()) {
        final error = studentsResult.fold((l) => l, (_) => 'Unknown error');
        emit(TeacherError(error));
        return;
      }

      final classDetail = classDetailResult.getOrElse(
        () => throw Exception('Class not found'),
      );
      final students = studentsResult.getOrElse(() => []);

      emit(ClassDetailLoaded(classDetail, students));
    } catch (e) {
      emit(TeacherError('Không thể tải chi tiết lớp: ${e.toString()}'));
    }
  }

  Future<void> _onLoadClassStudents(
    LoadClassStudents event,
    Emitter<TeacherState> emit,
  ) async {
    emit(const TeacherLoading(action: 'Đang tải danh sách học sinh...'));
    final result = await repository.getClassStudents(event.classId);
    result.fold(
      (error) => emit(TeacherError(error)),
      (students) => emit(StudentsLoaded(students)),
    );
  }

  Future<void> _onLoadStudentDetail(
    LoadStudentDetail event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await repository.getStudentDetail(event.studentId);
    result.fold(
      (error) => emit(TeacherError(error)),
      (student) => emit(StudentDetailLoaded(student, const [], const [])),
    );
  }

  Future<void> _onSearchStudents(
    SearchStudents event,
    Emitter<TeacherState> emit,
  ) async {
    emit(
      const TeacherError(
        'Chức năng tìm kiếm chưa được triển khai trong ngữ cảnh hiện tại',
      ),
    );
  }

  Future<void> _onLoadAttendance(
    LoadAttendance event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());

    final result = await repository.getAttendanceBySessionId(event.sessionId);
    result.fold(
      (error) {
        emit(TeacherError(error));
      },
      (session) {
        emit(AttendanceLoaded(session));
      },
    );
  }

  Future<void> _onRecordAttendance(
    RecordAttendance event,
    Emitter<TeacherState> emit,
  ) async {
    final result = await repository.recordAttendance(
      event.classId,
      event.studentId,
      event.status,
      event.note,
    );

    if (result.isLeft()) {
      result.fold((error) => emit(TeacherError(error)), (_) => null);
      return;
    }

    final sessionResult = await repository.getAttendanceSession(
      event.classId,
      DateTime.now(),
    );

    sessionResult.fold(
      (error) => emit(TeacherError(error)),
      (session) => emit(AttendanceRecorded(session)),
    );
  }

  Future<void> _onBatchRecordAttendance(
    BatchRecordAttendance event,
    Emitter<TeacherState> emit,
  ) async {
    emit(const TeacherLoading(action: 'Đang lưu điểm danh...'));

    final result = await repository.batchRecordAttendance(
      event.sessionId,
      event.entries,
    );

    result.fold(
      (error) => emit(TeacherError(error)),
      (_) =>
          emit(const AttendanceSubmitted('Điểm danh đã được lưu thành công')),
    );
  }

  // Note: _onSubmitAttendance, _onLoadClassScores, _onLoadStudentScores removed
  // because repository methods getClassScores, getStudentScores, submitAttendance
  // are not implemented

  Future<void> _onLoadWeekSchedule(
    LoadWeekSchedule event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await repository.getWeekSchedule(event.date);
    result.fold(
      (error) => emit(TeacherError(error)),
      (schedule) => emit(ScheduleLoaded(schedule)),
    );
  }

  Future<void> _onLoadTodaySchedule(
    LoadTodaySchedule event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await repository.getTodaySchedule();
    result.fold(
      (error) => emit(TeacherError(error)),
      (schedule) => emit(ScheduleLoaded(schedule)),
    );
  }

  Future<void> _onLoadProfile(
    LoadTeacherProfile event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await repository.getProfile();
    result.fold((error) => emit(TeacherError(error)), (profile) {
      _cachedProfile = profile;
      emit(ProfileLoaded(profile));
    });
  }

  Future<void> _onUpdateProfile(
    UpdateTeacherProfile event,
    Emitter<TeacherState> emit,
  ) async {
    emit(TeacherLoading());
    final result = await repository.updateProfile(event.profile);
    result.fold((error) => emit(TeacherError(error)), (_) {
      _cachedProfile = event.profile;
      emit(ProfileUpdated('Hồ sơ đã được cập nhật', profile: event.profile));
    });
  }
}
