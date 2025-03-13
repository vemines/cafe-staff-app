part of 'feedback_cubit.dart';

abstract class FeedbackState extends Equatable {
  const FeedbackState();

  @override
  List<Object> get props => [];
}

class FeedbackInitial extends FeedbackState {}

class FeedbackLoading extends FeedbackState {}

class FeedbackCreated extends FeedbackState {
  final FeedbackEntity feedback;

  const FeedbackCreated({required this.feedback});

  @override
  List<Object> get props => [feedback];
}

class FeedbackLoaded extends FeedbackState {
  final List<FeedbackEntity> feedbacks;

  const FeedbackLoaded({required this.feedbacks});

  @override
  List<Object> get props => [feedbacks];
}

class FeedbackError extends FeedbackState {
  final Failure failure;

  const FeedbackError({required this.failure});

  @override
  List<Object> get props => [failure];
}
