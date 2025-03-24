import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../models/order_history_model.dart';

abstract class OrderHistoryRemoteDataSource {
  Future<Map<String, dynamic>> getAllOrderHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
    required int limit,
    required int page,
  });
}

class OrderHistoryRemoteDataSourceImpl implements OrderHistoryRemoteDataSource {
  final Dio dio;

  OrderHistoryRemoteDataSourceImpl({required this.dio});

  @override
  Future<Map<String, dynamic>> getAllOrderHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
    required int limit,
    required int page,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.orderHistory,
        queryParameters: {
          if (startDate != null) 'startDate': startDate.toIso8601String(),
          if (endDate != null) 'endDate': endDate.toIso8601String(),
          if (paymentMethod != null) OrderHistoryApiMap.paymentMethod: paymentMethod,
          'limit': limit,
          'page': page,
        },
      );

      final data =
          (response.data['data'] as List).map((item) => OrderHistoryModel.fromJson(item)).toList();
      final hasMore = response.data['hasMore'] as bool;
      return {'data': data, 'hasMore': hasMore};
    } on DioException catch (e, s) {
      handleDioException(e, s, 'OrderHistoryRemoteDataSource.getAllOrderHistory');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
