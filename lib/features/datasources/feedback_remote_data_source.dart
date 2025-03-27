import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../models/feedback_model.dart';

abstract class FeedbackRemoteDataSource {
  Future<FeedbackModel> createFeedback({required int rating, required String comment});
  Future<Map<String, dynamic>> getAllFeedback({
    int? rating,
    DateTime? startDate,
    DateTime? endDate,
    required int page,
    required int limit,
  });
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final Dio dio;

  FeedbackRemoteDataSourceImpl({required this.dio});

  @override
  Future<FeedbackModel> createFeedback({required int rating, required String comment}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.feedbacks,
        data: {FeedbackApiMap.rating: rating, FeedbackApiMap.comment: comment},
      );
      return FeedbackModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'FeedbackRemoteDataSource.createFeedback');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'FeedbackRemoteDataSource.createFeedback',
      );
    }
  }

  @override
  Future<Map<String, dynamic>> getAllFeedback({
    int? rating,
    DateTime? startDate,
    DateTime? endDate,
    required int page,
    required int limit,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.feedbacks,
        queryParameters: {
          if (rating != null) FeedbackApiMap.rating: rating,
          if (startDate != null) FeedbackApiMap.startDate: startDate.toIso8601String(),
          if (endDate != null) FeedbackApiMap.endDate: endDate.toIso8601String(),
          'page': page,
          'limit': limit,
        },
      );
      final data =
          (response.data['data'] as List).map((item) => FeedbackModel.fromJson(item)).toList();
      final hasMore = response.data['hasMore'] as bool;
      return {'data': data, 'hasMore': hasMore};
    } on DioException catch (e, s) {
      handleDioException(e, s, 'FeedbackRemoteDataSource.getAllFeedback');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'FeedbackRemoteDataSource.getAllFeedback',
      );
    }
  }
}
