import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/category_entity.dart';
import '../../repositories/menu_repository.dart';

class CreateCategoryParams extends Equatable {
  final String name;

  const CreateCategoryParams({required this.name});

  @override
  List<Object?> get props => [name];
}

class CreateCategoryUseCase implements UseCase<CategoryEntity, CreateCategoryParams> {
  final MenuRepository repository;

  CreateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(CreateCategoryParams params) async {
    return await repository.createCategory(params);
  }
}
