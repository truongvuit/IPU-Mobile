import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import '../../domain/repositories/student_repository.dart';
import '../../domain/entities/student_class.dart';
import '../../domain/entities/schedule.dart';
import '../../data/services/cart_service.dart';
import '../constants/student_messages.dart';
import 'student_event.dart';
import 'student_state.dart';

class StudentBloc extends Bloc<StudentEvent, StudentState> {
  final StudentRepository repository;

  
  final CartService _cartService = CartService.instance;

  StudentBloc({required this.repository}) : super(const StudentInitial()) {
    on<LoadDashboard>(_onLoadDashboard, transformer: droppable());
    on<LoadAllCourses>(_onLoadAllCourses, transformer: droppable());
    on<LoadMyClasses>(_onLoadMyClasses, transformer: droppable());

    on<LoadSchedule>(_onLoadSchedule, transformer: restartable());
    on<LoadWeekSchedule>(_onLoadWeekSchedule, transformer: restartable());
    on<LoadMyGrades>(_onLoadMyGrades, transformer: droppable());
    on<LoadProfile>(_onLoadProfile, transformer: droppable());
    on<LoadGradesByCourse>(_onLoadGradesByCourse, transformer: droppable());
    on<LoadGradesByClass>(_onLoadGradesByClass, transformer: droppable());
    on<LoadReviewHistory>(_onLoadReviewHistory, transformer: droppable());
    on<LoadClassReview>(_onLoadClassReview, transformer: droppable());

    on<SearchCourses>(_onSearchCourses, transformer: restartable());

    on<LoadCourseDetail>(_onLoadCourseDetail);
    on<LoadClassDetail>(_onLoadClassDetail);
    on<UpdateProfile>(_onUpdateProfile);
    on<SubmitRating>(_onSubmitRating);

    
    on<ResetStudentState>(_onResetStudentState);
  }

  
  void _onResetStudentState(
    ResetStudentState event,
    Emitter<StudentState> emit,
  ) {
    _cartService.clear();
    emit(const StudentInitial());
  }

  Future<void> _onLoadDashboard(
    LoadDashboard event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is DashboardLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadDashboard'));
    }

    try {
      final classesResultFuture = repository.getUpcomingClasses();
      final profileResultFuture = repository.getProfile();
      final todayScheduleFuture = repository.getScheduleByDate(DateTime.now());
      final gradesFuture = repository.getMyGrades();
      final myClassesFuture = repository.getMyClasses();

      final classesResult = await classesResultFuture;
      final profileResult = await profileResultFuture;
      final todayScheduleResult = await todayScheduleFuture;
      final gradesResult = await gradesFuture;
      final myClassesResult = await myClassesFuture;

      final profile = profileResult.fold((_) => null, (profile) => profile);

      String? profileError;
      if (profileResult.isLeft()) {
        profileError = profileResult.fold((f) => f.message, (_) => null);
      }

      if (classesResult.isLeft()) {
        final errorMsg = classesResult.fold(
          (f) => f.message,
          (_) => 'Unknown error',
        );

        if (currentState is DashboardLoaded) {
          emit(
            currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
          );
        } else {
          emit(StudentError(errorMsg));
        }
        return;
      }

      final today = DateTime.now();
      final todaySchedules = todayScheduleResult.fold(
        (_) => <Schedule>[],
        (schedules) => schedules
            .where(
              (s) =>
                  s.startTime.year == today.year &&
                  s.startTime.month == today.month &&
                  s.startTime.day == today.day,
            )
            .toList(),
      );

      
      double gpa = 0.0;
      if (gradesResult.isRight()) {
        final grades = gradesResult.getOrElse(() => []);
        if (grades.isNotEmpty) {
          final totalScore = grades.fold(
            0.0,
            (sum, grade) => sum + (grade.totalScore ?? 0.0),
          );
          gpa = totalScore / grades.length;
        }
      }

      
      int activeCoursesCount = 0;
      if (myClassesResult.isRight()) {
        final classes = myClassesResult.getOrElse(() => []);
        activeCoursesCount = classes
            .where((c) => c.status == 'InProgress')
            .length;
      }

      emit(
        DashboardLoaded(
          upcomingClasses: classesResult.fold(
            (_) => <StudentClass>[],
            (classes) => classes,
          ),
          profile: profile,
          todaySchedules: todaySchedules,
          errorMessage: profileError,
          gpa: gpa,
          activeCoursesCount: activeCoursesCount,
        ),
      );
    } catch (e) {
      final errorMsg = '${StudentMessages.errorLoadDashboard}: $e';
      if (currentState is DashboardLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadAllCourses(
    LoadAllCourses event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is CoursesLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadAllCourses'));
    }

    try {
      final result = await repository.getAllCourses();

      result.fold((failure) {
        if (currentState is CoursesLoaded) {
          emit(
            currentState.copyWith(
              isRefreshing: false,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(StudentError(failure.message));
        }
      }, (courses) => emit(CoursesLoaded(courses)));
    } catch (e) {
      final errorMsg = '${StudentMessages.errorLoadCourses}: $e';
      if (currentState is CoursesLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onSearchCourses(
    SearchCourses event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'SearchCourses'));

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
    emit(const StudentLoading(action: 'LoadCourseDetail'));

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
    final currentState = state;

    
    if (currentState is ClassesLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadMyClasses'));
    }

    try {
      final result = await repository.getMyClasses();

      result.fold(
        (failure) {
          if (currentState is ClassesLoaded) {
            emit(
              currentState.copyWith(
                isRefreshing: false,
                errorMessage: failure.message,
              ),
            );
          } else {
            emit(StudentError(failure.message));
          }
        },
        (classes) {
          emit(ClassesLoaded(classes));
        },
      );
    } catch (e) {
      final errorMsg = 'Không thể tải danh sách lớp học: $e';
      if (currentState is ClassesLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadClassDetail(
    LoadClassDetail event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'LoadClassDetail'));

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
    final currentState = state;

    
    if (currentState is ScheduleLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadSchedule'));
    }

    try {
      final result = await repository.getScheduleByDate(event.date);

      result.fold(
        (failure) {
          if (currentState is ScheduleLoaded) {
            emit(
              currentState.copyWith(
                isRefreshing: false,
                errorMessage: failure.message,
              ),
            );
          } else {
            emit(StudentError(failure.message));
          }
        },
        (schedules) {
          emit(ScheduleLoaded(schedules: schedules, selectedDate: event.date));
        },
      );
    } catch (e) {
      final errorMsg = 'Không thể tải lịch học: $e';
      if (currentState is ScheduleLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadWeekSchedule(
    LoadWeekSchedule event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is WeekScheduleLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadWeekSchedule'));
    }

    try {
      final result = await repository.getWeekSchedule(event.startDate);

      result.fold(
        (failure) {
          if (currentState is WeekScheduleLoaded) {
            emit(
              currentState.copyWith(
                isRefreshing: false,
                errorMessage: failure.message,
              ),
            );
          } else {
            emit(StudentError(failure.message));
          }
        },
        (schedules) => emit(
          WeekScheduleLoaded(schedules: schedules, startDate: event.startDate),
        ),
      );
    } catch (e) {
      final errorMsg = 'Không thể tải lịch tuần: $e';
      if (currentState is WeekScheduleLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadMyGrades(
    LoadMyGrades event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is GradesLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadMyGrades'));
    }

    try {
      final result = await repository.getMyGrades();

      result.fold((failure) {
        if (currentState is GradesLoaded) {
          emit(
            currentState.copyWith(
              isRefreshing: false,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(StudentError(failure.message));
        }
      }, (grades) => emit(GradesLoaded(grades)));
    } catch (e) {
      final errorMsg = 'Không thể tải điểm số: $e';
      if (currentState is GradesLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadGradesByCourse(
    LoadGradesByCourse event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;

    
    if (currentState is CourseGradesLoaded &&
        currentState.courseId == event.courseId) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadGradesByCourse'));
    }

    try {
      final result = await repository.getGradesByCourse(event.courseId);

      result.fold(
        (failure) {
          if (currentState is CourseGradesLoaded &&
              currentState.courseId == event.courseId) {
            emit(
              currentState.copyWith(
                isRefreshing: false,
                errorMessage: failure.message,
              ),
            );
          } else {
            emit(StudentError(failure.message));
          }
        },
        (grades) {
          emit(CourseGradesLoaded(grades: grades, courseId: event.courseId));
        },
      );
    } catch (e) {
      final errorMsg = 'Không thể tải điểm khóa học: $e';
      if (currentState is CourseGradesLoaded &&
          currentState.courseId == event.courseId) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadGradesByClass(
    LoadGradesByClass event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is ClassGradesLoaded &&
        currentState.classId == event.classId) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadGradesByClass'));
    }

    try {
      final result = await repository.getGradesByClass(event.classId);

      result.fold(
        (failure) {
          if (currentState is ClassGradesLoaded &&
              currentState.classId == event.classId) {
            emit(
              currentState.copyWith(
                isRefreshing: false,
                errorMessage: failure.message,
              ),
            );
          } else {
            emit(StudentError(failure.message));
          }
        },
        (grade) =>
            emit(ClassGradesLoaded(grade: grade, classId: event.classId)),
      );
    } catch (e) {
      final errorMsg = 'Không thể tải điểm lớp: $e';
      if (currentState is ClassGradesLoaded &&
          currentState.classId == event.classId) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<StudentState> emit,
  ) async {
    final currentState = state;
    if (currentState is ProfileLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadProfile'));
    }

    try {
      final result = await repository.getProfile();

      result.fold((failure) {
        if (currentState is ProfileLoaded) {
          emit(
            currentState.copyWith(
              isRefreshing: false,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(StudentError(failure.message));
        }
      }, (profile) => emit(ProfileLoaded(profile)));
    } catch (e) {
      final errorMsg = 'Không thể tải hồ sơ: $e';
      if (currentState is ProfileLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'UpdateProfile'));

    try {
      final currentProfileResult = await repository.getProfile();

      await currentProfileResult.fold(
        (failure) async => emit(StudentError(failure.message)),
        (currentProfile) async {
          String? newAvatarUrl = currentProfile.avatarUrl;

          if (event.avatarPath != null) {
            final uploadResult = await repository.uploadAvatar(
              event.avatarPath!,
            );
            final uploadSuccess = uploadResult.fold(
              (failure) {
                emit(StudentError('Lỗi tải ảnh lên: ${failure.message}'));
                return false;
              },
              (url) {
                newAvatarUrl = url;
                return true;
              },
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

  Future<void> _onSubmitRating(
    SubmitRating event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'SubmitRating'));

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
    final currentState = state;
    if (currentState is ReviewHistoryLoaded) {
      emit(currentState.copyWith(isRefreshing: true));
    } else {
      emit(const StudentLoading(action: 'LoadReviewHistory'));
    }

    try {
      final result = await repository.getReviewHistory();
      result.fold((failure) {
        if (currentState is ReviewHistoryLoaded) {
          emit(
            currentState.copyWith(
              isRefreshing: false,
              errorMessage: failure.message,
            ),
          );
        } else {
          emit(StudentError(failure.message));
        }
      }, (reviews) => emit(ReviewHistoryLoaded(reviews)));
    } catch (e) {
      final errorMsg = 'Không thể tải lịch sử đánh giá: $e';
      if (currentState is ReviewHistoryLoaded) {
        emit(
          currentState.copyWith(isRefreshing: false, errorMessage: errorMsg),
        );
      } else {
        emit(StudentError(errorMsg));
      }
    }
  }

  Future<void> _onLoadClassReview(
    LoadClassReview event,
    Emitter<StudentState> emit,
  ) async {
    emit(const StudentLoading(action: 'LoadClassReview'));

    try {
      final result = await repository.getClassReview(event.classId);
      result.fold(
        (failure) =>
            emit(ClassReviewLoaded(review: null, classId: event.classId)),
        (review) =>
            emit(ClassReviewLoaded(review: review, classId: event.classId)),
      );
    } catch (e) {
      emit(ClassReviewLoaded(review: null, classId: event.classId));
    }
  }

  
}
