import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/area_table_entity.dart';
import '../../repositories/table_repository.dart';

class GetAllAreasUseCase implements UseCase<List<AreaTableEntity>, NoParams> {
  final TableRepository repository;

  GetAllAreasUseCase(this.repository);

  @override
  Future<Either<Failure, List<AreaTableEntity>>> call(NoParams params) async {
    return await repository.getAllAreas(params);
  }
}
