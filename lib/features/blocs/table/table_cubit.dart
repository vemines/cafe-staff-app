import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../entities/table_entity.dart';
import '../../usecases/table/create_table_usecase.dart';
import '../../usecases/table/delete_table_usecase.dart';
import '../../usecases/table/get_all_tables_usecase.dart';
import '../../usecases/table/update_table_usecase.dart';

part 'table_state.dart';

class TableCubit extends Cubit<TableState> {
  final GetAllTablesUseCase getAllTablesUseCase;
  final CreateTableUseCase createTableUseCase;
  final UpdateTableUseCase updateTableUseCase;
  final DeleteTableUseCase deleteTableUseCase;

  TableCubit({
    required this.getAllTablesUseCase,
    required this.createTableUseCase,
    required this.updateTableUseCase,
    required this.deleteTableUseCase,
  }) : super(TableInitial());

  Future<void> getAllTables(GetAllTablesParams params) async {
    emit(TableLoading());
    final result = await getAllTablesUseCase(params);
    result.fold(
      (failure) => emit(TableError(failure: failure)),
      (tables) => emit(TableLoaded(tables: tables)),
    );
  }

  Future<void> createTable(CreateTableParams params) async {
    emit(TableLoading());
    final result = await createTableUseCase(params);
    result.fold(
      (failure) => emit(TableError(failure: failure)),
      (table) => emit(TableCreated(table: table)),
    );
  }

  Future<void> updateTable(UpdateTableParams params) async {
    emit(TableLoading());
    final result = await updateTableUseCase(params);
    result.fold(
      (failure) => emit(TableError(failure: failure)),
      (table) => emit(TableUpdated(table: table)),
    );
  }

  Future<void> deleteTable(DeleteTableParams params) async {
    emit(TableLoading());
    final result = await deleteTableUseCase(params);
    result.fold((failure) => emit(TableError(failure: failure)), (_) => emit(TableDeleted()));
  }
}
