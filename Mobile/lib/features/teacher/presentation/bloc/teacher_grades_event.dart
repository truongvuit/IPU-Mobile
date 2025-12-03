import 'package:equatable/equatable.dart';

abstract class TeacherGradesEvent extends Equatable {
  const TeacherGradesEvent();

  @override
  List<Object> get props => [];
}

class LoadClassGrades extends TeacherGradesEvent {
  final String classId;

  const LoadClassGrades(this.classId);

  @override
  List<Object> get props => [classId];
}
