import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/sub_category_entity.dart';
import '../../repositories/menu_repository.dart';

class CreateSubCategoryParams extends Equatable {
  final String name;
  final String categoryId;
  final List<String> items;

  const CreateSubCategoryParams({
    required this.name,
    required this.categoryId,
    required this.items,
  });

  @override
  List<Object?> get props => [name, categoryId, items];
}

class CreateSubCategoryUseCase implements UseCase<SubCategoryEntity, CreateSubCategoryParams> {
  final MenuRepository repository;

  CreateSubCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, SubCategoryEntity>> call(CreateSubCategoryParams params) async {
    return await repository.createSubCategory(params);
  }
}
