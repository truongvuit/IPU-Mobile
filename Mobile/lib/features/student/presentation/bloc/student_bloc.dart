import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student_class.dart';
import '../../domain/entities/schedule.dart';
import '../constants/student_messages.dart';
import 'student_event.dart';
import 'student_state.dart';


class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository repository;

  StudentBloc({required this.repository}) : super(const StudentInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
    on<LoadAllCourses>(_onLoadAllCourses);
    on<SearchCourses>(_onSearchCourses);
    on<LoadCourseDetail>(_onLoadCourseDetail);
    on<LoadMyClasses>(_onLoadMyClasses);
    on<LoadClassDetail>(_onLoadClassDetail);
    on<LoadSchedule>(_onLoadSchedule);
    on<LoadWeekSchedule>(_onLoadWeekSchedule);
    on<LoadMyGrades>(_onLoadMyGrades);
    on<LoadGradesByCourse>(_onLoadGradesByCourse);
    on<LoadProfile>(_onLoadProfile);
    on<UpdateProfile>(_onUpdateProfile);
    on<EnrollCourse>(_onEnrollCourse);
    on<SubmitRating>(_onSubmitRating);
    on<LoadReviewHistory>(_onLoadReviewHistory);
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'Đang tải dashboard...'));

    try {
      // Load classes, profile, và schedule hôm nay song song
      final classesResultFuture = repository.getUpcomingClasses();
      final profileResultFuture = repository.getProfile();
      final todayScheduleFuture = repository.getScheduleByDate(DateTime.now());
      
      final classesResult = await classesResultFuture;
      final profileResult = await profileResultFuture;
      final todayScheduleResult = await todayScheduleFuture;

      
      if (classesResult.isLeft()) {
        emit(StudentError(classesResult.fold(
          (failure) => failure.message,
          (_) => 'Unknown error',
        )));
        return;
      }

      // Filter lịch học hôm nay
      final today = DateTime.now();
      final todaySchedules = todayScheduleResult.fold(
        (_) => <Schedule>[],
        (schedules) => schedules.where((s) =>
          s.startTime.year == today.year &&
          s.startTime.month == today.month &&
          s.startTime.day == today.day
        ).toList(),
      );

      emit(DashboardLoaded(
        upcomingClasses: classesResult.fold((_) => <StudentClass>[], (classes) => classes),
        profile: profileResult.fold((_) => null, (profile) => profile),
        todaySchedules: todaySchedules,
      ));
    } catch (e) {
      emit(StudentError('${StudentMessages.errorLoadDashboard}: $e'));
    }
  }

  Future<void> _onLoadAllCourses(
    LoadAllCourses event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'Đang tải khóa học...'));

    try {
      final result = await repository.getAllCourses();

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (courses) => emit(CoursesLoaded(courses)),
      );
    } catch (e) {
      emit(StudentError('${StudentMessages.errorLoadCourses}: $e'));
    }
  }

  Future<void> _onSearchCourses(
    SearchCourses event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'Đang tìm kiếm...'));

    try {
      final result = await repository.searchCourses(event.query);

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (courses) => emit(CoursesLoaded(courses)),
      );
    } catch (e) {
      emit(StudentError('${StudentMessages.errorSearchCourses}: $e'));
    }
  }

  Future<void> _onLoadCourseDetail(
    LoadCourseDetail event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getCourseById(event.courseId);

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (course) => emit(CourseDetailLoaded(course)),
      );
    } catch (e) {
      emit(StudentError('Không thể tải chi tiết khóa học: $e'));
    }
  }

  Future<void> _onLoadMyClasses(
    LoadMyClasses event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getMyClasses();

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (classes) => emit(ClassesLoaded(classes)),
      );
    } catch (e) {
      emit(StudentError('Không thể tải danh sách lớp học: $e'));
    }
  }

  Future<void> _onLoadClassDetail(
    LoadClassDetail event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getClassById(event.classId);

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (studentClass) => emit(ClassDetailLoaded(studentClass)),
      );
    } catch (e) {
      emit(StudentError('Không thể tải chi tiết lớp học: $e'));
    }
  }

  Future<void> _onLoadSchedule(
    LoadSchedule event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getScheduleByDate(event.date);

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (schedules) => emit(ScheduleLoaded(
          schedules: schedules,
          selectedDate: event.date,
        )),
      );
    } catch (e) {
      emit(StudentError('Không thể tải lịch học: $e'));
    }
  }

  Future<void> _onLoadWeekSchedule(
    LoadWeekSchedule event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getWeekSchedule(event.startDate);

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (schedules) => emit(WeekScheduleLoaded(
          schedules: schedules,
          startDate: event.startDate,
        )),
      );
    } catch (e) {
      emit(StudentError('Không thể tải lịch tuần: $e'));
    }
  }

  Future<void> _onLoadMyGrades(
    LoadMyGrades event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getMyGrades();

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (grades) => emit(GradesLoaded(grades)),
      );
    } catch (e) {
      emit(StudentError('Không thể tải điểm số: $e'));
    }
  }

  Future<void> _onLoadGradesByCourse(
    LoadGradesByCourse event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getGradesByCourse(event.courseId);

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (grades) => emit(CourseGradesLoaded(
          grades: grades,
          courseId: event.courseId,
        )),
      );
    } catch (e) {
      emit(StudentError('Không thể tải điểm khóa học: $e'));
    }
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getProfile();

      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (profile) => emit(ProfileLoaded(profile)),
      );
    } catch (e) {
      emit(StudentError('Không thể tải hồ sơ: $e'));
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      
      final currentProfileResult = await repository.getProfile();
      
      await currentProfileResult.fold(
        (failure) async => emit(StudentError(failure.message)),
        (currentProfile) async {
          String? newAvatarUrl = currentProfile.avatarUrl;

          
          if (event.avatarPath != null) {
             final uploadResult = await repository.uploadAvatar(event.avatarPath!);
             final uploadSuccess = uploadResult.fold(
               (failure) {
                  emit(StudentError('Lỗi tải ảnh lên: ${failure.message}'));
                  return false;
               },
               (url) {
                 newAvatarUrl = url;
                 return true;
               }
             );
             if (!uploadSuccess) return;
          }

          
          final updatedProfile = currentProfile.copyWith(
            fullName: event.fullName,
            phoneNumber: () => event.phoneNumber,
            address: () => event.address,
            avatarUrl: () => newAvatarUrl,
          );
          
          final result = await repository.updateProfile(updatedProfile);
          result.fold(
            (failure) => emit(StudentError(failure.message)),
            (profile) => emit(ProfileUpdated(profile)),
          );
        },
      );
    } catch (e) {
      emit(StudentError('Không thể cập nhật hồ sơ: $e'));
    }
  }

  Future<void> _onEnrollCourse(
    EnrollCourse event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.enrollCourse(event.courseId);
      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (_) => emit(const CourseEnrolled()),
      );
    } catch (e) {
      emit(StudentError('Không thể đăng ký khóa học: $e'));
    }
  }

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.submitRating(
        classId: event.classId,
        overallRating: event.overallRating,
        teacherRating: event.teacherRating,
        facilityRating: event.facilityRating,
        comment: event.comment,
      );
      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (_) => emit(const RatingSubmitted()),
      );
    } catch (e) {
      emit(StudentError('Không thể gửi đánh giá: $e'));
    }
  }

  Future<void> _onLoadReviewHistory(
    LoadReviewHistory event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading());

    try {
      final result = await repository.getReviewHistory();
      result.fold(
        (failure) => emit(StudentError(failure.message)),
        (reviews) => emit(ReviewHistoryLoaded(reviews)),
      );
    } catch (e) {
      emit(StudentError('Không thể tải lịch sử đánh giá: $e'));
    }
  }
}
