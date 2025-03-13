import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/usecase/usecase.dart';
import '../datasources/feedback_remote_data_source.dart';
import '../entities/feedback_entity.dart';
import '../usecases/feedback/create_feedback_usecase.dart';

abstract class FeedbackRepository {
  Future<Either<Failure, FeedbackEntity>> createFeedback(CreateFeedbackParams params);
  Future<Either<Failure, List<FeedbackEntity>>> getAllFeedback(PaginationParams params);
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
  Future<Either<Failure, List<FeedbackEntity>>> getAllFeedback(PaginationParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteFeedbacks = await remoteDataSource.getAllFeedback(
          page: params.page,
          limit: params.limit,
        );
        return Right(remoteFeedbacks);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
