import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

class UpdateMenuItemParams extends Equatable {
  final String id;
  final String name;
  final String subCategoryId;
  final double price;
  final bool isAvailable;

  const UpdateMenuItemParams({
    required this.id,
    required this.name,
    required this.subCategoryId,
    required this.price,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [id, name, subCategoryId, price, isAvailable];
}

class UpdateMenuItemUseCase implements UseCase<MenuItemEntity, UpdateMenuItemParams> {
  final MenuRepository repository;

  UpdateMenuItemUseCase(this.repository);

  @override
  Future<Either<Failure, MenuItemEntity>> call(UpdateMenuItemParams params) async {
    return await repository.updateMenuItem(params);
  }
}
