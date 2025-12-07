import 'package:equatable/equatable.dart';
import '../../domain/entities/student_cart_preview.dart';


abstract class StudentCheckoutState extends Equatable {
  const StudentCheckoutState();

  @override
  List<Object?> get props => [];
}


class StudentCheckoutInitial extends StudentCheckoutState {
  const StudentCheckoutInitial();
}


class StudentCheckoutLoading extends StudentCheckoutState {
  const StudentCheckoutLoading();
}


class StudentCheckoutPreviewLoaded extends StudentCheckoutState {
  final StudentCartPreview cartPreview;

  const StudentCheckoutPreviewLoaded({required this.cartPreview});

  @override
  List<Object?> get props => [cartPreview];
}


class StudentCheckoutCreatingOrder extends StudentCheckoutState {
  final StudentCartPreview cartPreview;

  const StudentCheckoutCreatingOrder({required this.cartPreview});

  @override
  List<Object?> get props => [cartPreview];
}


class StudentCheckoutOrderCreated extends StudentCheckoutState {
  final int invoiceId;
  final double totalAmount;
  final String paymentUrl;

  const StudentCheckoutOrderCreated({
    required this.invoiceId,
    required this.totalAmount,
    required this.paymentUrl,
  });

  @override
  List<Object?> get props => [invoiceId, totalAmount, paymentUrl];
}


class StudentCheckoutError extends StudentCheckoutState {
  final String message;
  final StudentCartPreview? cartPreview;

  const StudentCheckoutError({
    required this.message,
    this.cartPreview,
  });

  @override
  List<Object?> get props => [message, cartPreview];
}
