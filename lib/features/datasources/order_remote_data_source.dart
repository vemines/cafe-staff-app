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

  Future<OrderModel> updateOrder({required String id, String? paymentMethod, String? status});

  Future<void> mergeOrders({
    required String sourceTableId,
    required String targetTableId,
    required List<String> splitItemIds,
  });
  Future<void> splitOrder({
    required String sourceTableId,
    required String targetTableId,
    required List<String> splitItemIds,
  });
  Future<void> approveMerge({required String mergeRequestId});
  Future<void> rejectMergeRequest({required String mergeRequestId});
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
                      OrderItemApiMap.menuItem: item.menuItem.id,
                      OrderItemApiMap.quantity: item.quantity,
                      OrderItemApiMap.price: item.price,
                    },
                  )
                  .toList(),
        },
      );
      return OrderModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'OrderRemoteDataSource.createOrder');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<OrderModel> updateOrder({
    required String id,
    String? paymentMethod,
    String? status,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (paymentMethod != null) updateData[OrderApiMap.paymentMethod] = paymentMethod;
      if (status != null) updateData[OrderApiMap.status] = status;
      final response = await dio.patch(ApiEndpoints.singleOrder(id), data: updateData);
      return OrderModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'OrderRemoteDataSource.updateOrder');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> mergeOrders({
    required String sourceTableId,
    required String targetTableId,
    required List<String> splitItemIds,
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
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> splitOrder({
    required String sourceTableId,
    required String targetTableId,
    required List<String> splitItemIds,
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
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> approveMerge({required String mergeRequestId}) async {
    try {
      await dio.post(ApiEndpoints.approveMergeOrder, data: {'mergeRequestId': mergeRequestId});
    } on DioException catch (e, s) {
      handleDioException(e, s, "OrderRemoteDataSource.approveMerge");
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> rejectMergeRequest({required String mergeRequestId}) async {
    try {
      await dio.post(ApiEndpoints.rejectMergeOrder, data: {'mergeRequestId': mergeRequestId});
    } on DioException catch (e, s) {
      handleDioException(e, s, "OrderRemoteDataSource.rejectMergeRequest");
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
