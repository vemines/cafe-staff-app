part of 'feedback_cubit.dart';

abstract class FeedbackState extends Equatable {
  final List<FeedbackEntity> feedbacks;
  final bool hasMore;

  const FeedbackState({this.feedbacks = const [], this.hasMore = true});

  @override
  List<Object> get props => [feedbacks, hasMore];
}

class FeedbackInitial extends FeedbackState {
  const FeedbackInitial() : super();
}

class FeedbackLoading extends FeedbackState {}

class FeedbackLoaded extends FeedbackState {
  const FeedbackLoaded({required super.feedbacks, required super.hasMore});
}

class FeedbackError extends FeedbackState {
  final Failure failure;

  const FeedbackError({required this.failure});

  @override
  List<Object> get props => [failure];
}
