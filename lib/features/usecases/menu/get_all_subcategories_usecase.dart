import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/sub_category_entity.dart';
import '../../repositories/menu_repository.dart';

class GetAllSubCategoriesParams extends PaginationParams {
  final String? categoryId;
  const GetAllSubCategoriesParams({
    required super.page,
    required super.limit,
    super.order,
    this.categoryId,
  });

  @override
  List<Object?> get props => [...super.props, categoryId];
}

class GetAllSubCategoriesUseCase
    implements UseCase<List<SubCategoryEntity>, GetAllSubCategoriesParams> {
  final MenuRepository repository;

  GetAllSubCategoriesUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubCategoryEntity>>> call(GetAllSubCategoriesParams params) async {
    return await repository.getAllSubCategories(params);
  }
}
