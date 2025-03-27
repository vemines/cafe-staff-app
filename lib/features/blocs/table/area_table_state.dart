part of 'area_table_cubit.dart';

abstract class AreaState extends Equatable {
  const AreaState();

  @override
  List<Object> get props => [];
}

class AreaInitial extends AreaState {}

class AreaLoaded extends AreaState {
  final List<AreaEntity> areas;

  const AreaLoaded({required this.areas});

  @override
  List<Object> get props => [areas];
}

class AreaError extends AreaState {
  final Failure failure;

  const AreaError({required this.failure});

  @override
  List<Object> get props => [failure];
}
