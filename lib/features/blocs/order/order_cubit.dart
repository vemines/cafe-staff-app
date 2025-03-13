import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/order_entity.dart';
import '../../usecases/order/create_order_usecase.dart';
import '../../usecases/order/get_order_by_id_usecase.dart';
import '../../usecases/order/get_orders_usecase.dart';
import '../../usecases/order/update_order_usecase.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final GetOrdersUseCase getOrdersUseCase;
  final GetOrderByIdUseCase getOrderByIdUseCase;
  final UpdateOrderUseCase updateOrderUseCase;

  OrderCubit({
    required this.createOrderUseCase,
    required this.getOrdersUseCase,
    required this.getOrderByIdUseCase,
    required this.updateOrderUseCase,
  }) : super(OrderInitial());

  Future<void> createOrder(CreateOrderParams params) async {
    emit(OrderLoading());
    final result = await createOrderUseCase(params);
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (order) => emit(OrderCreated(order: order)),
    );
  }

  Future<void> getOrderById(GetOrderByIdParams params) async {
    emit(OrderLoading());
    final result = await getOrderByIdUseCase(params);
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (order) => emit(OrderLoaded(orders: [order])), // Wrap single order in a list
    );
  }

  Future<void> getOrders(GetOrdersParams params) async {
    emit(OrderLoading());
    final result = await getOrdersUseCase(params);
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (orders) => emit(OrderLoaded(orders: orders)),
    );
  }

  Future<void> updateOrder(UpdateOrderParams params) async {
    emit(OrderLoading());
    final result = await updateOrderUseCase(params);
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (order) => emit(OrderUpdated(order: order)),
    );
  }
}
