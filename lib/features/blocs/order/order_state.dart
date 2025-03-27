part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderError extends OrderState {
  final Failure failure;

  const OrderError({required this.failure});

  @override
  List<Object> get props => [failure];
}
