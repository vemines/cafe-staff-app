import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/params.dart';
import '../../entities/area_with_table_entity.dart';
import '../../usecases/table/get_areas_with_tables_usecase.dart';

part 'area_with_tables_state.dart';

class AreaWithTablesCubit extends Cubit<AreaWithTablesState> {
  final GetAreasWithTablesUseCase getAreasWithTablesUseCase;

  AreaWithTablesCubit({required this.getAreasWithTablesUseCase}) : super(AreaWithTablesInitial());

  Future<void> getAreasWithTables() async {
    emit(AreaWithTablesLoading());
    final result = await getAreasWithTablesUseCase(NoParams());
    result.fold(
      (failure) => emit(AreaWithTablesError(failure: failure)),
      (areasWithTables) => emit(AreaWithTablesLoaded(areasWithTables: areasWithTables)),
    );
  }
}
