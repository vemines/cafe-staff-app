part of 'payment_cubit.dart';

@immutable
sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

final class PaymentInitial extends PaymentState {}

final class PaymentLoading extends PaymentState {}

final class PaymentLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  const PaymentLoaded({required this.payments});
  @override
  List<Object> get props => [payments];
}

final class PaymentCreated extends PaymentState {
  final PaymentEntity payment;
  const PaymentCreated({required this.payment});
  @override
  List<Object> get props => [payment];
}

final class PaymentUpdated extends PaymentState {
  final PaymentEntity payment;
  const PaymentUpdated({required this.payment});
  @override
  List<Object> get props => [payment];
}

final class PaymentDeleted extends PaymentState {}

final class PaymentError extends PaymentState {
  final Failure failure;

  const PaymentError({required this.failure});

  @override
  List<Object> get props => [failure];
}
