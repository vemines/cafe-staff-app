import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/sub_category_entity.dart';
import '../../repositories/menu_repository.dart';

class UpdateSubCategoryParams extends Equatable {
  final String id;
  final String? name;
  final String? categoryId;
  final List<String>? items;
  final bool? isActive;

  const UpdateSubCategoryParams({
    required this.id,
    this.name,
    this.categoryId,
    this.items,
    this.isActive,
  });
  @override
  List<Object?> get props => [id, name, categoryId, items];
}

class UpdateSubCategoryUseCase implements UseCase<SubcategoryEntity, UpdateSubCategoryParams> {
  final MenuRepository repository;

  UpdateSubCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, SubcategoryEntity>> call(UpdateSubCategoryParams params) async {
    return await repository.updateSubCategory(params);
  }
}
