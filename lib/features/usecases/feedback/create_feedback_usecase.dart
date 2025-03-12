import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/feedback_entity.dart';
import '../../repositories/feedback_repository.dart';

class CreateFeedbackParams extends Equatable {
  final int rating;
  final String comment;

  const CreateFeedbackParams({required this.rating, required this.comment});

  @override
  List<Object?> get props => [rating, comment];
}

class CreateFeedbackUseCase implements UseCase<FeedbackEntity, CreateFeedbackParams> {
  final FeedbackRepository repository;

  CreateFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackEntity>> call(CreateFeedbackParams params) async {
    return await repository.createFeedback(params);
  }
}
