import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/order_history_entity.dart';
import '../../usecases/order_history/get_all_order_history_usecase.dart';
import '../../usecases/order_history/get_order_history_by_id_usecase.dart';

part 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final GetAllOrderHistoryUseCase getAllOrderHistoryUseCase;
  final GetOrderHistoryByIdUseCase getOrderHistoryByIdUseCase;

  OrderHistoryCubit({
    required this.getAllOrderHistoryUseCase,
    required this.getOrderHistoryByIdUseCase,
  }) : super(OrderHistoryInitial());

  Future<void> getAllOrderHistory(GetAllOrderHistoryParams params) async {
    emit(OrderHistoryLoading());
    final result = await getAllOrderHistoryUseCase(params);
    result.fold(
      (failure) => emit(OrderHistoryError(failure: failure)),
      (orderHistory) => emit(OrderHistoryLoaded(orderHistory: orderHistory)),
    );
  }

  Future<void> getOrderHistoryById(GetOrderHistoryByIdParams params) async {
    emit(OrderHistoryLoading());
    final result = await getOrderHistoryByIdUseCase(params);
    result.fold(
      (failure) => emit(OrderHistoryError(failure: failure)),
      (order) => emit(OrderHistoryLoaded(orderHistory: [order])),
    );
  }
}
