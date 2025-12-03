import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/usecases/get_class_grades.dart';
import 'teacher_grades_event.dart';
import 'teacher_grades_state.dart';

class TeacherGradesBloc extends Bloc<TeacherGradesEvent, TeacherGradesState> {
  final GetClassGrades getClassGrades;

  TeacherGradesBloc({required this.getClassGrades})
    : super(TeacherGradesInitial()) {
    on<LoadClassGrades>(_onLoadClassGrades);
  }

  Future<void> _onLoadClassGrades(
    LoadClassGrades event,
    Emitter<TeacherGradesState> emit,
  ) async {
    emit(TeacherGradesLoading());

    final result = await getClassGrades(event.classId);

    result.fold(
      (failure) => emit(TeacherGradesError(failure.message)),
      (grades) => emit(TeacherGradesLoaded(grades)),
    );
  }
}
