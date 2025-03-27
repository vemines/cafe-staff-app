import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../entities/order_item_entity.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required String tableId,
    required List<OrderItemEntity> orderItems,
  });

  Future<OrderModel> updateOrder({
    required String id,
    String? paymentMethod,
    String? status,
    List<OrderItemEntity>? orderItems,
  });
  Future<void> mergeOrders({
    required String sourceTableId,
    required String targetTableId,
    required Map<String, int> splitItemIds,
  });
  Future<void> splitOrder({
    required String sourceTableId,
    required String targetTableId,
    required Map<String, int> splitItemIds,
  });
  Future<void> approveMerge({required String tableId});
  Future<void> rejectMergeRequest({required String tableId});
}

class OrderRemoteDataSourceImpl implements OrderRemoteDataSource {
  final Dio dio;

  OrderRemoteDataSourceImpl({required this.dio});

  @override
  Future<OrderModel> createOrder({
    required String tableId,
    required List<OrderItemEntity> orderItems,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.orders,
        data: {
          OrderApiMap.tableId: tableId,
          OrderApiMap.orderItems:
              orderItems
                  .map(
                    (item) => {
                      OrderItemApiMap.id: item.menuItem.id,
                      OrderItemApiMap.quantity: item.quantity,
                    },
                  )
                  .toList(),
        },
      );
      return OrderModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'OrderRemoteDataSource.createOrder');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'OrderRemoteDataSource.createOrder',
      );
    }
  }

  @override
  Future<OrderModel> updateOrder({
    required String id,
    String? paymentMethod,
    String? status,
    List<OrderItemEntity>? orderItems,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (paymentMethod != null) updateData[OrderApiMap.paymentMethod] = paymentMethod;
      if (status != null) updateData[OrderApiMap.status] = status;
      if (orderItems != null) {
        updateData[OrderApiMap.orderItems] =
            orderItems
                .map(
                  (item) => {
                    OrderItemApiMap.menuItem: item.menuItem.id,
                    OrderItemApiMap.quantity: item.quantity,
                  },
                )
                .toList();
      }
      final response = await dio.patch(ApiEndpoints.singleOrder(id), data: updateData);
      return OrderModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'OrderRemoteDataSource.updateOrder');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'OrderRemoteDataSource.updateOrder',
      );
    }
  }

  @override
  Future<void> mergeOrders({
    required String sourceTableId,
    required String targetTableId,
    required Map<String, int> splitItemIds,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.mergeOrder,
        data: {
          'sourceTableId': sourceTableId,
          'targetTableId': targetTableId,
          'splitItemIds': splitItemIds,
        },
      );
    } on DioException catch (e, s) {
      handleDioException(e, s, 'OrderRemoteDataSource.mergeOrders');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'OrderRemoteDataSource.mergeOrders',
      );
    }
  }

  @override
  Future<void> splitOrder({
    required String sourceTableId,
    required String targetTableId,
    required Map<String, int> splitItemIds,
  }) async {
    try {
      await dio.post(
        ApiEndpoints.splitOrder,
        data: {
          'sourceTableId': sourceTableId,
          'targetTableId': targetTableId,
          'splitItemIds': splitItemIds,
        },
      );
    } on DioException catch (e, s) {
      handleDioException(e, s, 'OrderRemoteDataSource.splitOrder');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'OrderRemoteDataSource.splitOrder',
      );
    }
  }

  @override
  Future<void> approveMerge({required String tableId}) async {
    try {
      await dio.post(ApiEndpoints.approveMergeOrder, data: {'tableId': tableId});
    } on DioException catch (e, s) {
      handleDioException(e, s, "OrderRemoteDataSource.approveMerge");
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'OrderRemoteDataSource.approveMerge',
      );
    }
  }

  @override
  Future<void> rejectMergeRequest({required String tableId}) async {
    try {
      await dio.post(ApiEndpoints.rejectMergeOrder, data: {'tableId': tableId});
    } on DioException catch (e, s) {
      handleDioException(e, s, "OrderRemoteDataSource.rejectMergeRequest");
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'OrderRemoteDataSource.rejectMergeRequest',
      );
    }
  }
}
