import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/feedback_entity.dart';
import '../../repositories/feedback_repository.dart';

class GetAllFeedbackParams extends Equatable {
  final int? rating;
  final DateTime? startDate;
  final DateTime? endDate;
  final int page;
  final int limit;

  const GetAllFeedbackParams({
    this.rating,
    this.startDate,
    this.endDate,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [rating, startDate, endDate, page, limit];
}

class FeedbackResponse extends Equatable {
  final List<FeedbackEntity> data;
  final bool hasMore;
  const FeedbackResponse({required this.data, required this.hasMore});
  @override
  List<Object?> get props => [data, hasMore];
}

class GetAllFeedbackUseCase implements UseCase<FeedbackResponse, GetAllFeedbackParams> {
  final FeedbackRepository repository;

  GetAllFeedbackUseCase(this.repository);

  @override
  Future<Either<Failure, FeedbackResponse>> call(GetAllFeedbackParams params) async {
    try {
      final result = await repository.getAllFeedback(params);

      return result.fold((failure) => Left(failure), (data) {
        final feedbackData = (data['data'] as List).map((item) => item as FeedbackEntity).toList();

        return Right(FeedbackResponse(data: feedbackData, hasMore: data['hasMore']));
      });
    } catch (e) {
      return Left(AppFailure(message: "Unexpected error in UseCase: $e"));
    }
  }
}
