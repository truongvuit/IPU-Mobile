import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/delete_course.dart';
import '../../domain/usecases/get_course_by_id.dart';
import '../../domain/usecases/get_courses.dart';
import '../../domain/usecases/toggle_course_status.dart';
import '../../domain/usecases/update_course.dart';
import 'admin_course_event.dart';
import 'admin_course_state.dart';

class AdminCourseBloc extends Bloc<AdminCourseEvent, AdminCourseState> {
  final GetCourses getCourses;
  final GetCourseById getCourseById;
  final UpdateCourse updateCourse;
  final DeleteCourse deleteCourse;
  final ToggleCourseStatus toggleCourseStatus;

  AdminCourseBloc({
    required this.getCourses,
    required this.getCourseById,
    required this.updateCourse,
    required this.deleteCourse,
    required this.toggleCourseStatus,
  }) : super(AdminCourseInitial()) {
    on<LoadCourses>(_onLoadCourses);
    on<LoadCourseDetail>(_onLoadCourseDetail);
    on<UpdateCourseEvent>(_onUpdateCourse);
    on<ToggleCourseStatusEvent>(_onToggleCourseStatus);
    on<DeleteCourseEvent>(_onDeleteCourse);
  }

  Future<void> _onLoadCourses(
    LoadCourses event,
    Emitter<AdminCourseState> emit,
  ) async {
    emit(AdminCourseLoading());

    final result = await getCourses(
      GetCoursesParams(
        search: event.search,
        categoryId: event.categoryId,
        isActive: event.isActive,
      ),
    );

    result.fold(
      (failure) => emit(AdminCourseError(failure.message)),
      (courses) => emit(AdminCourseLoaded(courses)),
    );
  }

  Future<void> _onLoadCourseDetail(
    LoadCourseDetail event,
    Emitter<AdminCourseState> emit,
  ) async {
    emit(AdminCourseLoading());

    final result = await getCourseById(event.id);

    result.fold(
      (failure) => emit(AdminCourseError(failure.message)),
      (course) => emit(AdminCourseDetailLoaded(course)),
    );
  }

  Future<void> _onUpdateCourse(
    UpdateCourseEvent event,
    Emitter<AdminCourseState> emit,
  ) async {
    emit(AdminCourseLoading());

    final result = await updateCourse(
      UpdateCourseParams(id: event.id, request: event.request),
    );

    result.fold(
      (failure) => emit(AdminCourseError(failure.message)),
      (course) =>
          emit(const AdminCourseSuccess('Cập nhật khóa học thành công')),
    );
  }

  Future<void> _onToggleCourseStatus(
    ToggleCourseStatusEvent event,
    Emitter<AdminCourseState> emit,
  ) async {
    final result = await toggleCourseStatus(event.id);

    result.fold(
      (failure) => emit(AdminCourseError(failure.message)),
      (_) => emit(const AdminCourseStatusToggled()),
    );
  }

  Future<void> _onDeleteCourse(
    DeleteCourseEvent event,
    Emitter<AdminCourseState> emit,
  ) async {
    emit(AdminCourseLoading());

    final result = await deleteCourse(event.id);

    result.fold(
      (failure) => emit(AdminCourseError(failure.message)),
      (_) => emit(const AdminCourseSuccess('Xóa khóa học thành công')),
    );
  }
}
