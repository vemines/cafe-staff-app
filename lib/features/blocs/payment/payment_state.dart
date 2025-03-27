part of 'payment_cubit.dart';

@immutable
sealed class PaymentState extends Equatable {
  const PaymentState();

  @override
  List<Object> get props => [];
}

final class PaymentInitial extends PaymentState {}

final class PaymentLoaded extends PaymentState {
  final List<PaymentEntity> payments;
  const PaymentLoaded({required this.payments});
  @override
  List<Object> get props => [payments];
}

final class PaymentError extends PaymentState {
  final Failure failure;

  const PaymentError({required this.failure});

  @override
  List<Object> get props => [failure];
}
