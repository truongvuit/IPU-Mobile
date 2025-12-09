import 'package:equatable/equatable.dart';

abstract class StudentCheckoutEvent extends Equatable {
  const StudentCheckoutEvent();

  @override
  List<Object?> get props => [];
}

class LoadCartPreview extends StudentCheckoutEvent {
  final List<int> classIds;

  const LoadCartPreview({required this.classIds});

  @override
  List<Object?> get props => [classIds];
}

class CreateOrder extends StudentCheckoutEvent {
  final List<int> classIds;
  final int studentId;
  final int paymentMethodId;

  const CreateOrder({
    required this.classIds,
    required this.studentId,
    this.paymentMethodId = 2, // Default to VNPay (ID=2)
  });

  @override
  List<Object?> get props => [classIds, studentId, paymentMethodId];
}

class ResetCheckout extends StudentCheckoutEvent {
  const ResetCheckout();
}
