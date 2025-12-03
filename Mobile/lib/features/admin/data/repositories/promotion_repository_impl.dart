import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/promotion.dart';
import '../../domain/repositories/promotion_repository.dart';
import '../datasources/promotion_remote_datasource.dart';
import '../models/promotion_model.dart';

class PromotionRepositoryImpl implements PromotionRepository {
  final PromotionRemoteDataSource remoteDataSource;

  PromotionRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<Promotion>>> getPromotions() async {
    try {
      final promotions = await remoteDataSource.getPromotions();
      return Right(promotions);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, Promotion>> getPromotionById(String id) async {
    try {
      final promotion = await remoteDataSource.getPromotionById(id);
      return Right(promotion);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> createPromotion(Promotion promotion) async {
    try {
      final promotionModel = PromotionModel.fromEntity(promotion);
      await remoteDataSource.createPromotion(promotionModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updatePromotion(Promotion promotion) async {
    try {
      final promotionModel = PromotionModel.fromEntity(promotion);
      await remoteDataSource.updatePromotion(promotionModel);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> deletePromotion(String id) async {
    try {
      await remoteDataSource.deletePromotion(id);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(message: e.message));
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
