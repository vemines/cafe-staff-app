import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

// ignore: must_be_immutable
class UpdateMenuItemParams extends Equatable {
  final String id;
  String? name;
  String? subCategoryId;
  double? price;
  bool? isActive;

  UpdateMenuItemParams({
    required this.id,
    this.name,
    this.subCategoryId,
    this.price,
    this.isActive,
  });

  @override
  List<Object?> get props => [id, name, subCategoryId, price, isActive];
}

class UpdateMenuItemUseCase implements UseCase<MenuItemEntity, UpdateMenuItemParams> {
  final MenuRepository repository;

  UpdateMenuItemUseCase(this.repository);

  @override
  Future<Either<Failure, MenuItemEntity>> call(UpdateMenuItemParams params) async {
    return await repository.updateMenuItem(params);
  }
}
