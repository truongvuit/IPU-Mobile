import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/promotion_repository.dart';
import 'promotion_event.dart';
import 'promotion_state.dart';

class PromotionBloc extends Bloc<PromotionEvent, PromotionState> {
  final PromotionRepository repository;

  PromotionBloc({required this.repository}) : super(PromotionInitial()) {
    on<LoadPromotions>(_onLoadPromotions);
    on<CreatePromotion>(_onCreatePromotion);
    on<UpdatePromotion>(_onUpdatePromotion);
    on<DeletePromotion>(_onDeletePromotion);
  }

  Future<void> _onLoadPromotions(
    LoadPromotions event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());
    final result = await repository.getPromotions();
    result.fold(
      (failure) => emit(PromotionError(failure.message)),
      (promotions) => emit(PromotionLoaded(promotions)),
    );
  }

  Future<void> _onCreatePromotion(
    CreatePromotion event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());
    final result = await repository.createPromotion(event.promotion);
    result.fold((failure) => emit(PromotionError(failure.message)), (_) {
      emit(const PromotionOperationSuccess('Tạo khuyến mãi thành công'));
      add(LoadPromotions());
    });
  }

  Future<void> _onUpdatePromotion(
    UpdatePromotion event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());
    final result = await repository.updatePromotion(event.promotion);
    result.fold((failure) => emit(PromotionError(failure.message)), (_) {
      emit(const PromotionOperationSuccess('Cập nhật khuyến mãi thành công'));
      add(LoadPromotions());
    });
  }

  Future<void> _onDeletePromotion(
    DeletePromotion event,
    Emitter<PromotionState> emit,
  ) async {
    emit(PromotionLoading());
    final result = await repository.deletePromotion(event.id);
    result.fold((failure) => emit(PromotionError(failure.message)), (_) {
      emit(const PromotionOperationSuccess('Xóa khuyến mãi thành công'));
      add(LoadPromotions());
    });
  }
}
