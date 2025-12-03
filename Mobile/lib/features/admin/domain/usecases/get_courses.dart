import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/course_detail.dart';
import '../repositories/admin_course_repository.dart';

class GetCourses implements UseCase<List<CourseDetail>, GetCoursesParams> {
  final AdminCourseRepository repository;

  GetCourses({required this.repository});

  @override
  Future<Either<Failure, List<CourseDetail>>> call(
    GetCoursesParams params,
  ) async {
    return await repository.getCourses(
      search: params.search,
      categoryId: params.categoryId,
      isActive: params.isActive,
    );
  }
}

class GetCoursesParams extends Equatable {
  final String? search;
  final String? categoryId;
  final bool? isActive;

  const GetCoursesParams({this.search, this.categoryId, this.isActive});

  @override
  List<Object?> get props => [search, categoryId, isActive];
}
