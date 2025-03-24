import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '/core/usecase/params.dart';
import '../../usecases/menu/get_complete_menu_usecase.dart';

part 'complete_menu_state.dart';

class CompleteMenuCubit extends Cubit<CompleteMenuState> {
  final GetCompleteMenuUseCase getCompleteMenuUseCase;

  CompleteMenuCubit({required this.getCompleteMenuUseCase}) : super(CompleteMenuInitial());

  Future<void> getCompleteMenu() async {
    emit(CompleteMenuLoading());
    final result = await getCompleteMenuUseCase(NoParams());
    result.fold(
      (failure) => emit(CompleteMenuError(failure: failure)),
      (response) => emit(CompleteMenuLoaded(response: response)),
    );
  }
}
