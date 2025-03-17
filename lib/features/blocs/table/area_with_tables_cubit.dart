// features/blocs/table/area_with_tables_cubit.dart
import 'package:cafe_staff_app/core/constants/enum.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/params.dart';
import '../../../core/services/socket_service.dart';
import '../../entities/area_with_table_entity.dart';
import '../../usecases/table/get_areas_with_tables_usecase.dart';

part 'area_with_tables_state.dart';

class AreaWithTablesCubit extends Cubit<AreaWithTablesState> {
  final GetAreasWithTablesUseCase getAreasWithTablesUseCase;
  final SocketService socketService;

  AreaWithTablesCubit({required this.getAreasWithTablesUseCase, required this.socketService})
    : super(AreaWithTablesInitial()) {
    _initSocketListeners(); // Listen for socket events
  }

  Future<void> getAreasWithTables() async {
    emit(AreaWithTablesLoading());
    final result = await getAreasWithTablesUseCase(NoParams());
    result.fold(
      (failure) => emit(AreaWithTablesError(failure: failure)),
      (areasWithTables) => emit(AreaWithTablesLoaded(areasWithTables: areasWithTables)),
    );
  }

  void _initSocketListeners() {
    socketService.socket.on('table_status_updated', (data) {
      _updateTableStatus(data['tableId'], data['status']);
    });
    socketService.socket.on('merge_request_approved', (data) {
      //Refesh data
      getAreasWithTables();
    });

    socketService.socket.on('merge_request_rejected', (data) {
      getAreasWithTables();
    });
    socketService.socket.on('order_created', (data) => getAreasWithTables());
    socketService.socket.on('order_updated', (data) => getAreasWithTables());
    socketService.socket.on('order_completed', (data) => getAreasWithTables());
    socketService.socket.on('merge_request_created', (data) {
      // data is mergeRequest model.
      _updateTableStatus(data['targetTableId'], 'merge-request');
    });
    // Add new event, order splitted
    socketService.socket.on('order_splitted', (data) => getAreasWithTables());
  }

  void _updateTableStatus(String tableId, String newStatus) {
    if (state is AreaWithTablesLoaded) {
      final currentState = state as AreaWithTablesLoaded;
      final updatedAreasWithTables =
          currentState.areasWithTables.map((area) {
            final updatedTables =
                area.tables.map((table) {
                  if (table.id == tableId) {
                    return table.copyWith(status: newStatus.toTableStatus());
                  }
                  return table;
                }).toList();
            return area.copyWith(tables: updatedTables);
          }).toList();

      emit(AreaWithTablesLoaded(areasWithTables: updatedAreasWithTables));
    }
  }
}
