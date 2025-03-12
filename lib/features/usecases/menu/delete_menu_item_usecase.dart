import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/menu_repository.dart';

class DeleteMenuItemParams extends Equatable {
  final String id;

  const DeleteMenuItemParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteMenuItemUseCase implements UseCase<Unit, DeleteMenuItemParams> {
  final MenuRepository repository;

  DeleteMenuItemUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteMenuItemParams params) async {
    return await repository.deleteMenuItem(params);
  }
}
