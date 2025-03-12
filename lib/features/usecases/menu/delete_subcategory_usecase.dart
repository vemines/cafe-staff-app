import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/menu_repository.dart';

class DeleteSubCategoryParams extends Equatable {
  final String id;

  const DeleteSubCategoryParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteSubCategoryUseCase implements UseCase<Unit, DeleteSubCategoryParams> {
  final MenuRepository repository;

  DeleteSubCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteSubCategoryParams params) async {
    return await repository.deleteSubCategory(params);
  }
}
