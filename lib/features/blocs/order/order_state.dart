part of 'order_cubit.dart';

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object> get props => [];
}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderCreated extends OrderState {
  final OrderEntity order;

  const OrderCreated({required this.order});

  @override
  List<Object> get props => [order];
}

class OrderLoaded extends OrderState {
  final List<OrderEntity> orders;

  const OrderLoaded({required this.orders});

  @override
  List<Object> get props => [orders];
}

class OrderUpdated extends OrderState {
  final OrderEntity order;

  const OrderUpdated({required this.order});

  @override
  List<Object> get props => [order];
}

// Add these new states
class MergeRequestCreated extends OrderState {}

class MergeRequestApproved extends OrderState {}

class MergeRequestRejected extends OrderState {}

class OrderSplitted extends OrderState {}

class OrderError extends OrderState {
  final Failure failure;

  const OrderError({required this.failure});

  @override
  List<Object> get props => [failure];
}
