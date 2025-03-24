part of 'area_table_cubit.dart';

abstract class AreaState extends Equatable {
  const AreaState();

  @override
  List<Object> get props => [];
}

class AreaInitial extends AreaState {}

class AreaLoading extends AreaState {}

class AreaLoaded extends AreaState {
  final List<AreaEntity> areas;

  const AreaLoaded({required this.areas});

  @override
  List<Object> get props => [areas];
}

class AreaCreated extends AreaState {
  final AreaEntity area;

  const AreaCreated({required this.area});

  @override
  List<Object> get props => [area];
}

class AreaUpdated extends AreaState {
  final AreaEntity area;

  const AreaUpdated({required this.area});

  @override
  List<Object> get props => [area];
}

class AreaDeleted extends AreaState {}

class AreaError extends AreaState {
  final Failure failure;

  const AreaError({required this.failure});

  @override
  List<Object> get props => [failure];
}
