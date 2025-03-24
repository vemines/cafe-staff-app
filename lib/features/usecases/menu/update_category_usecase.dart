import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/category_entity.dart';
import '../../repositories/menu_repository.dart';

// ignore: must_be_immutable
class UpdateCategoryParams extends Equatable {
  final String id;
  String? name;
  bool? isActive;

  UpdateCategoryParams({required this.id, this.name, this.isActive});

  @override
  List<Object?> get props => [id, name, isActive];
}

class UpdateCategoryUseCase implements UseCase<CategoryEntity, UpdateCategoryParams> {
  final MenuRepository repository;

  UpdateCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, CategoryEntity>> call(UpdateCategoryParams params) async {
    return await repository.updateCategory(params);
  }
}
