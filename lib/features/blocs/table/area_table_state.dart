part of 'area_table_cubit.dart';

abstract class AreaTableState extends Equatable {
  const AreaTableState();

  @override
  List<Object> get props => [];
}

class AreaTableInitial extends AreaTableState {}

class AreaTableLoading extends AreaTableState {}

class AreaTableLoaded extends AreaTableState {
  final List<AreaTableEntity> areaTables;

  const AreaTableLoaded({required this.areaTables});

  @override
  List<Object> get props => [areaTables];
}

class AreaTableCreated extends AreaTableState {
  final AreaTableEntity areaTable;

  const AreaTableCreated({required this.areaTable});

  @override
  List<Object> get props => [areaTable];
}

class AreaTableUpdated extends AreaTableState {
  final AreaTableEntity areaTable;

  const AreaTableUpdated({required this.areaTable});

  @override
  List<Object> get props => [areaTable];
}

class AreaTableDeleted extends AreaTableState {}

class AreaTableError extends AreaTableState {
  final Failure failure;

  const AreaTableError({required this.failure});

  @override
  List<Object> get props => [failure];
}
