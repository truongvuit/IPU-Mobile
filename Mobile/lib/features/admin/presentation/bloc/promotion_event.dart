import 'package:equatable/equatable.dart';
import '../../domain/entities/promotion.dart';

abstract class PromotionEvent extends Equatable {
  const PromotionEvent();

  @override
  List<Object> get props => [];
}

class LoadPromotions extends PromotionEvent {}

class CreatePromotion extends PromotionEvent {
  final Promotion promotion;

  const CreatePromotion(this.promotion);

  @override
  List<Object> get props => [promotion];
}

class UpdatePromotion extends PromotionEvent {
  final Promotion promotion;

  const UpdatePromotion(this.promotion);

  @override
  List<Object> get props => [promotion];
}

class DeletePromotion extends PromotionEvent {
  final String id;

  const DeletePromotion(this.id);

  @override
  List<Object> get props => [id];
}
