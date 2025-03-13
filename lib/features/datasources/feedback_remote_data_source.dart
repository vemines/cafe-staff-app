// lib/features/data/datasources/remote/feedback_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/feedback_model.dart';

abstract class FeedbackRemoteDataSource {
  Future<FeedbackModel> createFeedback({required int rating, required String comment});
  Future<List<FeedbackModel>> getAllFeedback({required int page, required int limit});
}

class FeedbackRemoteDataSourceImpl implements FeedbackRemoteDataSource {
  final Dio dio;

  FeedbackRemoteDataSourceImpl({required this.dio});

  @override
  Future<FeedbackModel> createFeedback({required int rating, required String comment}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.feedback,
        data: {'rating': rating, 'comment': comment},
      );
      return FeedbackModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'createFeedback({required int rating, required String comment})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<FeedbackModel>> getAllFeedback({required int page, required int limit}) async {
    try {
      final response = await dio.get(
        ApiEndpoints.feedback,
        queryParameters: {'page': page, 'limit': limit},
      );
      return (response.data as List).map((item) => FeedbackModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAllFeedback({required int page, required int limit})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
