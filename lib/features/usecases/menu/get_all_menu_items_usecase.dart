import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/menu_item_entity.dart';
import '../../repositories/menu_repository.dart';

class GetAllMenuItemsParams extends PaginationParams {
  final String? subcategoryId;
  const GetAllMenuItemsParams({
    required super.page,
    required super.limit,
    super.order,
    this.subcategoryId,
  });
  @override
  List<Object?> get props => [...super.props, subcategoryId];
}

class GetAllMenuItemsUseCase implements UseCase<List<MenuItemEntity>, GetAllMenuItemsParams> {
  final MenuRepository repository;

  GetAllMenuItemsUseCase(this.repository);

  @override
  Future<Either<Failure, List<MenuItemEntity>>> call(GetAllMenuItemsParams params) async {
    return await repository.getAllMenuItems(params);
  }
}
