// lib/features/data/datasources/remote/order_history_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/order_history_model.dart';

abstract class OrderHistoryRemoteDataSource {
  Future<List<OrderHistoryModel>> getAllOrderHistory({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
  });
  Future<OrderHistoryModel> getOrderHistoryById({required String id});
}

class OrderHistoryRemoteDataSourceImpl implements OrderHistoryRemoteDataSource {
  final Dio dio;

  OrderHistoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<OrderHistoryModel>> getAllOrderHistory({
    required int page,
    required int limit,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.orderHistory,
        queryParameters: {
          'page': page,
          'limit': limit,
          'startDate': startDate?.toIso8601String(),
          'endDate': endDate?.toIso8601String(),
        },
      );
      return (response.data as List).map((item) => OrderHistoryModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'getAllOrderHistory({required int page, required int limit, DateTime? startDate, DateTime? endDate})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<OrderHistoryModel> getOrderHistoryById({required String id}) async {
    try {
      final response = await dio.get(ApiEndpoints.singleOrderHistory(id));
      return OrderHistoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getOrderHistoryById({required String id})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
