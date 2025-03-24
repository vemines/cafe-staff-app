import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

class CreateMenuItemParams extends Equatable {
  final String name;
  final String subCategory;
  final double price;

  const CreateMenuItemParams({required this.name, required this.subCategory, required this.price});
  @override
  List<Object?> get props => [name, subCategory, price];
}

class CreateMenuItemUsecase implements UseCase<MenuItemEntity, CreateMenuItemParams> {
  final MenuRepository repository;

  CreateMenuItemUsecase(this.repository);

  @override
  Future<Either<Failure, MenuItemEntity>> call(CreateMenuItemParams params) async {
    return await repository.createMenuItem(params);
  }
}
