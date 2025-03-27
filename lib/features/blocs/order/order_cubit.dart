import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '../../entities/order_item_entity.dart';
import '../../usecases/order/approve_merge_request_usecase.dart';
import '../../usecases/order/complete_order_usecase.dart';
import '../../usecases/order/create_merge_request_usecase.dart';
import '../../usecases/order/create_order_usecase.dart';
import '../../usecases/order/reject_merge_request_usecase.dart';
import '../../usecases/order/serve_order_usecase.dart';
import '../../usecases/order/split_order_usecase.dart';
import '../../usecases/order/update_order_usecase.dart';

part 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final CreateOrderUseCase createOrderUseCase;
  final UpdateOrderUseCase updateOrderUseCase;
  final ServeOrderUseCase serveOrderUseCase;
  final CompleteOrderUseCase completeOrderUseCase;
  final CreateMergeRequestUseCase createMergeRequestUseCase;
  final ApproveMergeRequestUseCase approveMergeRequestUseCase;
  final SplitOrderUseCase splitOrderUseCase;
  final RejectMergeRequestUseCase rejectMergeRequestUseCase;

  OrderCubit({
    required this.createOrderUseCase,
    required this.updateOrderUseCase,
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
    final result = await createOrderUseCase(
      CreateOrderParams(tableId: tableId, orderItems: orderItems),
    );
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }

  Future<void> updateOrder({
    required String orderId,
    required List<OrderItemEntity> orderItems,
  }) async {
    final result = await updateOrderUseCase(
      UpdateOrderParams(orderId: orderId, orderItems: orderItems),
    );
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }

  Future<void> serveOrder({required String orderId}) async {
    final result = await serveOrderUseCase(ServeOrderParams(orderId: orderId));
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }

  Future<void> completeOrder({required String orderId, required String paymentMethod}) async {
    final result = await completeOrderUseCase(
      CompleteOrderParams(orderId: orderId, paymentMethod: paymentMethod),
    );
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }

  Future<void> createMergeRequest({
    required String sourceTableId,
    required String targetTableId,
    required Map<String, int> splitItemIds,
  }) async {
    final result = await createMergeRequestUseCase(
      CreateMergeRequestParams(
        sourceTableId: sourceTableId,
        targetTableId: targetTableId,
        splitItemIds: splitItemIds,
      ),
    );
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }

  Future<void> approveMergeRequest({required String tableId}) async {
    final result = await approveMergeRequestUseCase(ApproveMergeRequestParams(tableId: tableId));
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }

  Future<void> splitOrder({
    required String sourceTableId,
    required String targetTableId,
    required Map<String, int> splitItemIds,
  }) async {
    final result = await splitOrderUseCase(
      SplitOrderParams(
        sourceTableId: sourceTableId,
        targetTableId: targetTableId,
        splitItemIds: splitItemIds,
      ),
    );
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }

  Future<void> rejectMergeRequest({required String tableId}) async {
    final result = await rejectMergeRequestUseCase(RejectMergeRequestParams(tableId: tableId));
    result.fold((failure) => emit(OrderError(failure: failure)), (_) {});
  }
}
