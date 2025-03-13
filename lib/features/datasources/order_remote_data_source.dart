// lib/features/data/datasources/remote/order_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../entities/order_item_entity.dart';
import '../models/order_model.dart';

abstract class OrderRemoteDataSource {
  Future<OrderModel> createOrder({
    required String tableId,
    required List<OrderItemEntity> orderItems,
  });
  Future<List<OrderModel>> getOrders({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    String? tableId,
  });
  Future<OrderModel> getOrderById({required String orderId});

  Future<OrderModel> updateOrder({required String id, String? orderStatus, String? paymentMethod});
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
          'tableId': tableId,
          'orderItems':
              orderItems
                  .map(
                    (item) => {
                      'menuItemId': item.menuItemId,
                      'quantity': item.quantity,
                      'price': item.price,
                    },
                  )
                  .toList(),
        },
      );
      return OrderModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'createOrder({required String tableId, required List<OrderItemEntity> orderItems})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<OrderModel> getOrderById({required String orderId}) async {
    try {
      final response = await dio.get(ApiEndpoints.singleOrder(orderId));
      return OrderModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getOrderById({required String orderId})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<OrderModel>> getOrders({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
    String? tableId,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.orders,
        queryParameters: {
          'page': page,
          'limit': limit,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
          'tableId': tableId,
        },
      );
      return (response.data as List).map((item) => OrderModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'getOrders({required int page, required int limit, DateTime? startDate, DateTime? endDate, String? tableId})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<OrderModel> updateOrder({
    required String id,
    String? orderStatus,
    String? paymentMethod,
  }) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.singleOrder(id),
        data: {'orderStatus': orderStatus, 'paymentMethod': paymentMethod},
      );
      return OrderModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'updateOrder({required String id, String? orderStatus, String? paymentMethod})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
