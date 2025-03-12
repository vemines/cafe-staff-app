import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/feedback_entity.dart';
import '../usecases/feedback/create_feedback_usecase.dart';

abstract class FeedbackRepository {
  Future<Either<Failure, FeedbackEntity>> createFeedback(CreateFeedbackParams params);
  Future<Either<Failure, List<FeedbackEntity>>> getAllFeedback(PaginationParams params);
  Future<Either<Failure, FeedbackEntity>> getFeedbackById(String id);
}

class FeedbackRepositoryImpl implements FeedbackRepository {
  @override
  Future<Either<Failure, FeedbackEntity>> createFeedback(CreateFeedbackParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<FeedbackEntity>>> getAllFeedback(PaginationParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, FeedbackEntity>> getFeedbackById(String id) {
    throw UnimplementedError();
  }
}
