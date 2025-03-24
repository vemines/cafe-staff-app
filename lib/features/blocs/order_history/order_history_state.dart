part of 'order_history_cubit.dart';

abstract class OrderHistoryState extends Equatable {
  final List<OrderHistoryEntity> orderHistory;
  final bool hasMore;
  const OrderHistoryState({this.orderHistory = const [], this.hasMore = true});

  @override
  List<Object> get props => [orderHistory, hasMore];
}

class OrderHistoryInitial extends OrderHistoryState {}

class OrderHistoryLoading extends OrderHistoryState {}

//Loading more
class OrderHistoryLoadingMore extends OrderHistoryState {
  const OrderHistoryLoadingMore({required super.orderHistory});
}

class OrderHistoryLoaded extends OrderHistoryState {
  const OrderHistoryLoaded({required super.orderHistory, required super.hasMore});
}

class OrderHistoryError extends OrderHistoryState {
  final Failure failure;

  const OrderHistoryError({required this.failure});

  @override
  List<Object> get props => [failure];
}
