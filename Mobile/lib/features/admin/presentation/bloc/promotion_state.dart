import 'package:equatable/equatable.dart';
import '../../domain/entities/promotion.dart';

abstract class PromotionState extends Equatable {
  const PromotionState();

  @override
  List<Object> get props => [];
}

class PromotionInitial extends PromotionState {}

class PromotionLoading extends PromotionState {}

class PromotionLoaded extends PromotionState {
  final List<Promotion> promotions;

  const PromotionLoaded(this.promotions);

  @override
  List<Object> get props => [promotions];
}

class PromotionError extends PromotionState {
  final String message;

  const PromotionError(this.message);

  @override
  List<Object> get props => [message];
}

class PromotionOperationSuccess extends PromotionState {
  final String message;

  const PromotionOperationSuccess(this.message);

  @override
  List<Object> get props => [message];
}
