import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

class GetAllMenuItemsUseCase implements UseCase<List<MenuItemEntity>, NoParams> {
  final MenuRepository repository;

  GetAllMenuItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(NoParams params) async {
    return await repository.getAllMenuItems(params);
  }
}
