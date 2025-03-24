import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/sub_category_entity.dart';
import '../../repositories/menu_repository.dart';

class GetAllSubCategoryUseCase implements UseCase<List<SubcategoryEntity>, NoParams> {
  final MenuRepository repository;

  GetAllSubCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<SubcategoryEntity>>> call(NoParams params) async {
    return await repository.getAllSubCategories(params);
  }
}
