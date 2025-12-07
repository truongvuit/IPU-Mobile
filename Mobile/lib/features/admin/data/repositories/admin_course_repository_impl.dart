import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../domain/entities/course_detail.dart';
import '../../domain/repositories/admin_course_repository.dart';
import '../datasources/admin_course_data_source.dart';
import '../models/course_detail_model.dart';

class AdminCourseRepositoryImpl implements AdminCourseRepository {
  final AdminCourseDataSource dataSource;

  AdminCourseRepositoryImpl({required this.dataSource});

  @override
  Future<Either<Failure, List<CourseDetail>>> getCourses({
    String? search,
    String? categoryId,
    bool? isActive,
  }) async {
    try {
      final models = await dataSource.getCourses(
        search: search,
        categoryId: categoryId,
        isActive: isActive,
      );
      
      
      final entities = models.map((model) => model.toEntity()).toList();
      return Right(entities);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseDetail>> getCourseById(String id) async {
    try {
      final model = await dataSource.getCourseById(id);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, CourseDetail>> updateCourse(
    String id,
    UpdateCourseRequest request,
  ) async {
    try {
      final model = await dataSource.updateCourse(id, request);
      return Right(model.toEntity());
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> toggleCourseStatus(String id) async {
    try {
      await dataSource.toggleCourseStatus(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCourse(String id) async {
    try {
      await dataSource.deleteCourse(id);
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
