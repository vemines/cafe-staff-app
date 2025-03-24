import 'package:dartz/dartz.dart';

import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/core/network/network_info.dart';
import '../datasources/feedback_remote_data_source.dart';
import '../entities/feedback_entity.dart';
import '../usecases/feedback/create_feedback_usecase.dart';
import '../usecases/feedback/get_all_feedback_usecase.dart';

abstract class FeedbackRepository {
  Future<Either<Failure, FeedbackEntity>> createFeedback(CreateFeedbackParams params);
  Future<Either<Failure, Map<String, dynamic>>> getAllFeedback(GetAllFeedbackParams params);
}

class FeedbackRepositoryImpl implements FeedbackRepository {
  final FeedbackRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  FeedbackRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, FeedbackEntity>> createFeedback(CreateFeedbackParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeedback = await remoteDataSource.createFeedback(
          rating: params.rating,
          comment: params.comment,
        );
        return Right(remoteFeedback);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllFeedback(GetAllFeedbackParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeedbacks = await remoteDataSource.getAllFeedback(
          rating: params.rating,
          startDate: params.startDate,
          endDate: params.endDate,
          page: params.page,
          limit: params.limit,
        );
        final feedbacks =
            (remoteFeedbacks['data'] as List).map((item) => item as FeedbackEntity).toList();
        return Right({'data': feedbacks, 'hasMore': remoteFeedbacks['hasMore']});
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
