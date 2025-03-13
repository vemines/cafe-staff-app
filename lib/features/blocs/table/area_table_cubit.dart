import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../core/errors/failures.dart';
import '../../entities/area_table_entity.dart';
import '../../usecases/table/create_area_usecase.dart';
import '../../usecases/table/delete_area_usecase.dart';
import '../../usecases/table/get_all_areas_usecase.dart';
import '../../usecases/table/update_area_usecase.dart';

part 'area_table_state.dart';

class AreaCubit extends Cubit<AreaTableState> {
  final GetAllAreasUseCase getAllAreasUseCase;
  final CreateAreaUseCase createAreaUseCase;
  final UpdateAreaUseCase updateAreaUseCase;
  final DeleteAreaUseCase deleteAreaUseCase;

  AreaCubit({
    required this.getAllAreasUseCase,
    required this.createAreaUseCase,
    required this.updateAreaUseCase,
    required this.deleteAreaUseCase,
  }) : super(AreaTableInitial());

  Future<void> getAllAreas() async {
    emit(AreaTableLoading());
    final result = await getAllAreasUseCase(NoParams());
    result.fold(
      (failure) => emit(AreaTableError(failure: failure)),
      (areaTables) => emit(AreaTableLoaded(areaTables: areaTables)),
    );
  }

  Future<void> createArea(CreateAreaParams params) async {
    emit(AreaTableLoading());
    final result = await createAreaUseCase(params);
    result.fold(
      (failure) => emit(AreaTableError(failure: failure)),
      (areaTable) => emit(AreaTableCreated(areaTable: areaTable)),
    );
  }

  Future<void> updateArea(UpdateAreaParams params) async {
    emit(AreaTableLoading());
    final result = await updateAreaUseCase(params);
    result.fold(
      (failure) => emit(AreaTableError(failure: failure)),
      (areaTable) => emit(AreaTableUpdated(areaTable: areaTable)),
    );
  }

  Future<void> deleteArea(DeleteAreaParams params) async {
    emit(AreaTableLoading());
    final result = await deleteAreaUseCase(params);
    result.fold(
      (failure) => emit(AreaTableError(failure: failure)),
      (_) => emit(AreaTableDeleted()),
    );
  }
}
