part of 'area_with_tables_cubit.dart';

abstract class AreaWithTablesState extends Equatable {
  const AreaWithTablesState();

  @override
  List<Object> get props => [];
}

class AreaWithTablesInitial extends AreaWithTablesState {}

class AreaWithTablesLoading extends AreaWithTablesState {}

class AreaWithTablesLoaded extends AreaWithTablesState {
  final List<AreaWithTablesEntity> areasWithTables;

  const AreaWithTablesLoaded({required this.areasWithTables});

  @override
  List<Object> get props => [areasWithTables];
}

class AreaWithTablesError extends AreaWithTablesState {
  final Failure failure;

  const AreaWithTablesError({required this.failure});

  @override
  List<Object> get props => [failure];
}
