import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '../../entities/feedback_entity.dart';
import '../../usecases/feedback/create_feedback_usecase.dart';
import '../../usecases/feedback/get_all_feedback_usecase.dart';

part 'feedback_state.dart';

class FeedbackCubit extends Cubit<FeedbackState> {
  final CreateFeedbackUseCase createFeedbackUseCase;
  final GetAllFeedbackUseCase getAllFeedbackUseCase;

  bool _hasMore = true;
  bool isLoadMore = false;
  int _currentPage = 1;
  final int _limit = 40;

  FeedbackCubit({required this.createFeedbackUseCase, required this.getAllFeedbackUseCase})
    : super(FeedbackInitial());

  Future<void> createFeedback(CreateFeedbackParams params) async {
    emit(FeedbackLoading());
    final result = await createFeedbackUseCase(params);
    result.fold((failure) => emit(FeedbackError(failure: failure)), (feedback) => {});
  }

  Future<void> getAllFeedback({
    int? rating,
    DateTime? startDate,
    DateTime? endDate,
    bool isLoadMore = false,
  }) async {
    if (!_hasMore && isLoadMore) return;

    if (isLoadMore) {
      isLoadMore = true;
      _currentPage++;
    } else {
      isLoadMore = false;
      _currentPage = 1;
      _hasMore = true;
    }
    final result = await getAllFeedbackUseCase(
      GetAllFeedbackParams(
        rating: rating,
        startDate: startDate,
        endDate: endDate,
        page: _currentPage,
        limit: _limit,
      ),
    );
    result.fold(
      (failure) {
        isLoadMore = false;
        emit(FeedbackError(failure: failure));
      },
      (response) {
        isLoadMore = false;
        final List<FeedbackEntity> newList = List.from(state.feedbacks);
        newList.addAll(response.data);
        _hasMore = response.hasMore;
        emit(FeedbackLoaded(feedbacks: newList, hasMore: _hasMore));
      },
    );
  }

  Future<void> clearFilters() async {
    _hasMore = true;
    isLoadMore = false;
    _currentPage = 1;
    getAllFeedback();
  }
}
