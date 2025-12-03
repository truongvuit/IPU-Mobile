import 'package:equatable/equatable.dart';

import '../../domain/entities/class_grade_summary.dart';

abstract class TeacherGradesState extends Equatable {
  const TeacherGradesState();

  @override
  List<Object> get props => [];
}

class TeacherGradesInitial extends TeacherGradesState {}

class TeacherGradesLoading extends TeacherGradesState {}

class TeacherGradesLoaded extends TeacherGradesState {
  final List<ClassGradeSummary> grades;

  const TeacherGradesLoaded(this.grades);

  @override
  List<Object> get props => [grades];
}

class TeacherGradesError extends TeacherGradesState {
  final String message;

  const TeacherGradesError(this.message);

  @override
  List<Object> get props => [message];
}
