import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/category_entity.dart';
import '../../repositories/menu_repository.dart';

class GetAllCategoryUseCase implements UseCase<List<CategoryEntity>, NoParams> {
  final MenuRepository repository;

  GetAllCategoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<CategoryEntity>>> call(NoParams params) async {
    return await repository.getAllCategories(params);
  }
}
