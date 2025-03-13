part of 'order_history_cubit.dart';

abstract class OrderHistoryState extends Equatable {
  const OrderHistoryState();

  @override
  List<Object> get props => [];
}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

class OrderHistoryLoaded extends OrderHistoryState {
  final List<OrderHistoryEntity> orderHistory;

  const OrderHistoryLoaded({required this.orderHistory});

  @override
  List<Object> get props => [orderHistory];
}

class OrderHistoryError extends OrderHistoryState {
  final Failure failure;

  const OrderHistoryError({required this.failure});

  @override
  List<Object> get props => [failure];
}
