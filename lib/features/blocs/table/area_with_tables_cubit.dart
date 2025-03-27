import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '/app/flavor.dart';
import '/core/errors/failures.dart';
import '/core/usecase/params.dart';
import '/injection_container.dart';
import '../../entities/area_with_table_entity.dart';
import '../../usecases/table/get_areas_with_tables_usecase.dart';

part 'area_with_tables_state.dart';

class AreaWithTablesCubit extends Cubit<AreaWithTablesState> {
  final GetAreasWithTablesUseCase getAreasWithTablesUseCase;
  late final io.Socket socket;

  AreaWithTablesCubit({required this.getAreasWithTablesUseCase}) : super(AreaWithTablesInitial()) {
    _initSocket();
    getAreasWithTables();
  }

  Future<void> getAreasWithTables() async {
    emit(AreaWithTablesLoading());
    final result = await getAreasWithTablesUseCase(NoParams());
    result.fold(
      (failure) => emit(AreaWithTablesError(failure: failure)),
      (areasWithTables) => emit(AreaWithTablesLoaded(areasWithTables: areasWithTables)),
    );
  }

  void _initSocket() {
    socket = io.io(
      FlavorService.instance.config.baseUrl,
      io.OptionBuilder()
          .setTransports(['websocket'])
          .setExtraHeaders(_getHeaders())
          .enableAutoConnect()
          .build(),
    );

    socket.on('order_updated', (_) => getAreasWithTables());
  }

  Map<String, dynamic> _getHeaders() {
    final dio = sl<Dio>();
    return dio.options.headers;
  }

  @override
  Future<void> close() {
    socket.disconnect();
    socket.dispose();
    return super.close();
  }
}
