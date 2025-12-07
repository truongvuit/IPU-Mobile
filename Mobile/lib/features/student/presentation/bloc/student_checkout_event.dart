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

  const CreateOrder({
    required this.classIds,
  });

  @override
  List<Object?> get props => [classIds];
}


class ResetCheckout extends StudentCheckoutEvent {
  const ResetCheckout();
}
