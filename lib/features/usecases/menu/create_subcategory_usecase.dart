import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/sub_category_entity.dart';
import '../../repositories/menu_repository.dart';

class CreateSubCategoryParams extends Equatable {
  final String name;
  final String categoryId;

  const CreateSubCategoryParams({required this.name, required this.categoryId});

  @override
  List<Object?> get props => [name, categoryId];
}

class CreateSubCategoryUseCase implements UseCase<SubcategoryEntity, CreateSubCategoryParams> {
  final MenuRepository repository;

  CreateSubCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, SubcategoryEntity>> call(CreateSubCategoryParams params) async {
    return await repository.createSubCategory(params);
  }
}
