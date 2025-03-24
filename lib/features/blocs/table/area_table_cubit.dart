import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/area_entity.dart';
import '../../usecases/table/create_area_usecase.dart';
import '../../usecases/table/delete_area_usecase.dart';
import '../../usecases/table/get_all_area_usecase.dart';
import '../../usecases/table/update_area_usecase.dart';

part 'area_table_state.dart';

class AreaCubit extends Cubit<AreaState> {
  final CreateAreaUseCase createAreaUseCase;
  final UpdateAreaUseCase updateAreaUseCase;
  final DeleteAreaUseCase deleteAreaUseCase;
  final GetAllAreaUseCase getAllAreaUseCase;

  AreaCubit({
    required this.createAreaUseCase,
    required this.updateAreaUseCase,
    required this.deleteAreaUseCase,
    required this.getAllAreaUseCase,
  }) : super(AreaInitial());

  Future<void> getAllArea() async {
    final result = await getAllAreaUseCase(NoParams());
    result.fold(
      (failure) => emit(AreaError(failure: failure)),
      (areas) => emit(AreaLoaded(areas: areas)),
    );
  }

  Future<void> createArea({required String name}) async {
    final result = await createAreaUseCase(CreateAreaParams(name: name));
    result.fold((failure) => emit(AreaError(failure: failure)), (area) {
      List<AreaEntity> areas = (state as AreaLoaded).areas;
      emit(AreaLoaded(areas: [...areas, area]));
    });
  }

  Future<void> updateArea({required String id, required String name}) async {
    final result = await updateAreaUseCase(UpdateAreaParams(id: id, name: name));
    result.fold((failure) => emit(AreaError(failure: failure)), (area) {
      List<AreaEntity> areas = [];
      if (state is AreaLoaded) {
        areas = (state as AreaLoaded).areas;
      }
      areas = areas.map((a) => a.id == area.id ? area : a).toList();
      emit(AreaLoaded(areas: areas));
    });
  }

  Future<void> deleteArea({required String id}) async {
    final result = await deleteAreaUseCase(DeleteAreaParams(id: id));
    result.fold((failure) => emit(AreaError(failure: failure)), (_) {
      List<AreaEntity> areas = [];
      if (state is AreaLoaded) {
        areas = (state as AreaLoaded).areas;
      }
      areas = areas.where((a) => a.id != id).toList();
      emit(AreaLoaded(areas: areas));
    });
  }
}
