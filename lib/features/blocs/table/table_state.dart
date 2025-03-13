part of 'table_cubit.dart';

abstract class TableState extends Equatable {
  const TableState();

  @override
  List<Object> get props => [];
}

class TableInitial extends TableState {}

class TableLoading extends TableState {}

class TableLoaded extends TableState {
  final List<TableEntity> tables;

  const TableLoaded({required this.tables});

  @override
  List<Object> get props => [tables];
}

class TableCreated extends TableState {
  final TableEntity table;

  const TableCreated({required this.table});

  @override
  List<Object> get props => [table];
}

class TableUpdated extends TableState {
  final TableEntity table;

  const TableUpdated({required this.table});

  @override
  List<Object> get props => [table];
}

class TableDeleted extends TableState {}

class TableError extends TableState {
  final Failure failure;

  const TableError({required this.failure});

  @override
  List<Object> get props => [failure];
}
