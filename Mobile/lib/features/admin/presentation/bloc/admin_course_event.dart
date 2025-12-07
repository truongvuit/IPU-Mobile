import 'package:equatable/equatable.dart';

import '../../data/models/course_detail_model.dart';

abstract class AdminCourseEvent extends Equatable {
  const AdminCourseEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourses extends AdminCourseEvent {
  final String? search;
  final String? categoryId;
  final bool? isActive;

  const LoadCourses({this.search, this.categoryId, this.isActive});

  @override
  List<Object?> get props => [search, categoryId, isActive];
}

class LoadCourseDetail extends AdminCourseEvent {
  final String id;

  const LoadCourseDetail(this.id);

  @override
  List<Object> get props => [id];
}

class UpdateCourseEvent extends AdminCourseEvent {
  final String id;
  final UpdateCourseRequest request;

  const UpdateCourseEvent({required this.id, required this.request});

  @override
  List<Object> get props => [id, request];
}

class ToggleCourseStatusEvent extends AdminCourseEvent {
  final String id;

  const ToggleCourseStatusEvent(this.id);

  @override
  List<Object> get props => [id];
}

class DeleteCourseEvent extends AdminCourseEvent {
  final String id;

  const DeleteCourseEvent(this.id);

  @override
  List<Object> get props => [id];
}
