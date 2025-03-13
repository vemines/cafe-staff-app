import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/params.dart';
import '../../entities/feedback_entity.dart';
import '../../usecases/feedback/create_feedback_usecase.dart';
import '../../usecases/feedback/get_all_feedback_usecase.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final CreateFeedbackUseCase createFeedbackUseCase;
  final GetAllFeedbackUseCase getAllFeedbackUseCase;

  FeedbackCubit({required this.createFeedbackUseCase, required this.getAllFeedbackUseCase})
    : super(FeedbackInitial());

  Future<void> createFeedback(CreateFeedbackParams params) async {
    emit(FeedbackLoading());
    final result = await createFeedbackUseCase(params);
    result.fold(
      (failure) => emit(FeedbackError(failure: failure)),
      (feedback) => emit(FeedbackCreated(feedback: feedback)),
    );
  }

  Future<void> getAllFeedback(PaginationParams params) async {
    emit(FeedbackLoading());
    final result = await getAllFeedbackUseCase(params);
    result.fold(
      (failure) => emit(FeedbackError(failure: failure)),
      (feedbacks) => emit(FeedbackLoaded(feedbacks: feedbacks)),
    );
  }
}
