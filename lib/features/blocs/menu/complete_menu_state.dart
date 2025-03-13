part of 'complete_menu_cubit.dart';

abstract class CompleteMenuState extends Equatable {
  const CompleteMenuState();

  @override
  List<Object> get props => [];
}

class CompleteMenuInitial extends CompleteMenuState {}

class CompleteMenuLoading extends CompleteMenuState {}

class CompleteMenuLoaded extends CompleteMenuState {
  final GetCompleteMenuResponse response;

  const CompleteMenuLoaded({required this.response});

  @override
  List<Object> get props => [response];
}

class CompleteMenuError extends CompleteMenuState {
  final Failure failure;

  const CompleteMenuError({required this.failure});

  @override
  List<Object> get props => [failure];
}
