import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../repositories/menu_repository.dart';

class DeleteCategoryParams extends Equatable {
  final String id;

  const DeleteCategoryParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteCategoryUseCase implements UseCase<Unit, DeleteCategoryParams> {
  final MenuRepository repository;

  DeleteCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteCategoryParams params) async {
    return await repository.deleteCategory(params);
  }
}
