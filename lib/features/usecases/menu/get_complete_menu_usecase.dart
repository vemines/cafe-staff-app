import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/category_entity.dart';
import '../../entities/menu_item_entity.dart';
import '../../entities/sub_category_entity.dart';
import '../../repositories/menu_repository.dart';

class GetCompleteMenuResponse extends Equatable {
  final List<CategoryEntity> categories;
  final List<SubcategoryEntity> subCategories;
  final List<MenuItemEntity> menuItems;

  const GetCompleteMenuResponse({
    required this.categories,
    required this.subCategories,
    required this.menuItems,
  });

  @override
  List<Object?> get props => [categories, subCategories, menuItems];
}

class GetCompleteMenuUseCase implements UseCase<GetCompleteMenuResponse, NoParams> {
  final MenuRepository repository;

  GetCompleteMenuUseCase(this.repository);

  @override
  Future<Either<Failure, GetCompleteMenuResponse>> call(NoParams params) async {
    return await repository.getCompleteMenu(params);
  }
}
