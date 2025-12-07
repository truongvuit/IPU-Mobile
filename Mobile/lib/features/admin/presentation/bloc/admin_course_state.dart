import 'package:equatable/equatable.dart';

import '../../domain/entities/course_detail.dart';

abstract class AdminCourseState extends Equatable {
  const AdminCourseState();

  @override
  List<Object?> get props => [];
}

class AdminCourseInitial extends AdminCourseState {}

class AdminCourseLoading extends AdminCourseState {}

class AdminCourseLoaded extends AdminCourseState {
  final List<CourseDetail> courses;

  const AdminCourseLoaded(this.courses);

  @override
  List<Object> get props => [courses];
}

class AdminCourseDetailLoaded extends AdminCourseState {
  final CourseDetail course;

  const AdminCourseDetailLoaded(this.course);

  @override
  List<Object> get props => [course];
}

class AdminCourseSuccess extends AdminCourseState {
  final String message;

  const AdminCourseSuccess(this.message);

  @override
  List<Object> get props => [message];
}

class AdminCourseStatusToggled extends AdminCourseState {
  const AdminCourseStatusToggled();
}

class AdminCourseError extends AdminCourseState {
  final String message;

  const AdminCourseError(this.message);

  @override
  List<Object> get props => [message];
}
