import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/table_entity.dart';
import '../../usecases/table/create_table_usecase.dart';
import '../../usecases/table/delete_table_usecase.dart';
import '../../usecases/table/get_all_table_usecase.dart';
import '../../usecases/table/update_table_usecase.dart';

part 'table_state.dart';

class TableCubit extends Cubit<TableState> {
  final CreateTableUseCase createTableUseCase;
  final UpdateTableUseCase updateTableUseCase;
  final DeleteTableUseCase deleteTableUseCase;
  final GetAllTableUseCase getAllTablesUseCase;

  List<TableEntity> _allTables = [];
  String? _selectedAreaId;

  TableCubit({
    required this.createTableUseCase,
    required this.updateTableUseCase,
    required this.deleteTableUseCase,
    required this.getAllTablesUseCase,
  }) : super(TableInitial());

  Future<void> getAllTables() async {
    final result = await getAllTablesUseCase(NoParams());
    result.fold(
      (failure) {
        emit(TableError(failure: failure));
      },
      (tables) {
        _allTables = tables;
        filterTablesByArea(_selectedAreaId);
      },
    );
  }

  Future<void> filterTablesByArea(String? areaId) async {
    _selectedAreaId = areaId;

    if (areaId == null || areaId.isEmpty) {
      emit(TableLoaded(tables: _allTables));
    } else {
      final filteredList = _allTables.where((table) => table.areaId == areaId).toList();
      emit(TableLoaded(tables: filteredList));
    }
  }

  Future<void> createTable({
    required String tableName,
    required String status,
    required String areaId,
  }) async {
    final result = await createTableUseCase(
      CreateTableParams(tableName: tableName, status: status, areaId: areaId),
    );
    result.fold((failure) => emit(TableError(failure: failure)), (table) async {
      _allTables.add(table);
      filterTablesByArea(_selectedAreaId);
    });
  }

  Future<void> updateTable({
    required String id,
    required String tableName,
    required String status,
    required String areaId,
  }) async {
    final result = await updateTableUseCase(
      UpdateTableParams(id: id, name: tableName, status: status, areaId: areaId),
    );
    result.fold((failure) => emit(TableError(failure: failure)), (table) async {
      _allTables = _allTables.map((t) => t.id == table.id ? table : t).toList();
      filterTablesByArea(_selectedAreaId);
    });
  }

  Future<void> deleteTable({required String id}) async {
    final result = await deleteTableUseCase(DeleteTableParams(id: id));
    result.fold((failure) => emit(TableError(failure: failure)), (_) async {
      _allTables.removeWhere((item) => item.id == id);
      filterTablesByArea(_selectedAreaId);
    });
  }
}
