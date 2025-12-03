import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/promotion.dart';

abstract class PromotionRepository {
  Future<Either<Failure, List<Promotion>>> getPromotions();
  Future<Either<Failure, Promotion>> getPromotionById(String id);
  Future<Either<Failure, void>> createPromotion(Promotion promotion);
  Future<Either<Failure, void>> updatePromotion(Promotion promotion);
  Future<Either<Failure, void>> deletePromotion(String id);
}
