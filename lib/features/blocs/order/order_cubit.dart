import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '../../entities/order_entity.dart';
import '../../entities/order_item_entity.dart';
import '../../usecases/order/approve_merge_request_usecase.dart';
import '../../usecases/order/complete_order_usecase.dart';
import '../../usecases/order/create_merge_request_usecase.dart';
import '../../usecases/order/create_order_usecase.dart';
import '../../usecases/order/reject_merge_request_usecase.dart';
import '../../usecases/order/serve_order_usecase.dart';
import '../../usecases/order/split_order_usecase.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  // final GetOrdersUseCase getOrdersUseCase;
  final ServeOrderUseCase serveOrderUseCase;
  final CompleteOrderUseCase completeOrderUseCase;
  final CreateMergeRequestUseCase createMergeRequestUseCase;
  final ApproveMergeRequestUseCase approveMergeRequestUseCase;
  final SplitOrderUseCase splitOrderUseCase;
  final RejectMergeRequestUseCase rejectMergeRequestUseCase;

  OrderCubit({
    required this.createOrderUseCase,
    // required this.getOrdersUseCase,
    required this.serveOrderUseCase,
    required this.completeOrderUseCase,
    required this.createMergeRequestUseCase,
    required this.approveMergeRequestUseCase,
    required this.splitOrderUseCase,
    required this.rejectMergeRequestUseCase,
  }) : super(OrderInitial());

  Future<void> createOrder({
    required String tableId,
    required List<OrderItemEntity> orderItems,
  }) async {
    emit(OrderLoading());
    final result = await createOrderUseCase(
      CreateOrderParams(tableId: tableId, orderItems: orderItems),
    );
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (order) => emit(OrderCreated(order: order)),
    );
  }

  Future<void> serveOrder({required String orderId}) async {
    emit(OrderLoading());
    final result = await serveOrderUseCase(ServeOrderParams(orderId: orderId));
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (order) => emit(OrderUpdated(order: order)),
    );
  }

  Future<void> completeOrder({required String orderId, required String paymentMethod}) async {
    emit(OrderLoading());
    final result = await completeOrderUseCase(
      CompleteOrderParams(orderId: orderId, paymentMethod: paymentMethod),
    );
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (order) => emit(OrderUpdated(order: order)),
    );
  }

  Future<void> createMergeRequest({
    required String sourceTableId,
    required String targetTableId,
    required List<String> splitItemIds,
  }) async {
    emit(OrderLoading());
    final result = await createMergeRequestUseCase(
      CreateMergeRequestParams(
        sourceTableId: sourceTableId,
        targetTableId: targetTableId,
        splitItemIds: splitItemIds,
      ),
    );
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (_) => emit(MergeRequestCreated()),
    );
  }

  Future<void> approveMergeRequest({required String mergeRequestId}) async {
    emit(OrderLoading());
    final result = await approveMergeRequestUseCase(
      ApproveMergeRequestParams(mergeRequestId: mergeRequestId),
    );
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (_) => emit(MergeRequestApproved()),
    );
  }

  Future<void> splitOrder({
    required String sourceTableId,
    required String targetTableId,
    required List<String> splitItemIds,
  }) async {
    emit(OrderLoading());
    final result = await splitOrderUseCase(
      SplitOrderParams(
        sourceTableId: sourceTableId,
        targetTableId: targetTableId,
        splitItemIds: splitItemIds,
      ),
    );
    result.fold((failure) => emit(OrderError(failure: failure)), (_) => emit(OrderSplitted()));
  }

  Future<void> rejectMergeRequest({required String mergeRequestId}) async {
    emit(OrderLoading());
    final result = await rejectMergeRequestUseCase(
      RejectMergeRequestParams(mergeRequestId: mergeRequestId),
    );
    result.fold(
      (failure) => emit(OrderError(failure: failure)),
      (_) => emit(MergeRequestRejected()),
    );
  }
}
