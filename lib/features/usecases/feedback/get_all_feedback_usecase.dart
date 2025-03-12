import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/feedback_entity.dart';
import '../../repositories/feedback_repository.dart';

class GetAllFeedbackUseCase implements UseCase<List<FeedbackEntity>, PaginationParams> {
  final FeedbackRepository repository;

  GetAllFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, List<FeedbackEntity>>> call(PaginationParams params) async {
    return await repository.getAllFeedback(params);
  }
}
