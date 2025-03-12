import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/area_with_table_entity.dart';
import '../../repositories/table_repository.dart';

class GetAreasWithTablesUseCase implements UseCase<List<AreaWithTablesEntity>, NoParams> {
  final TableRepository repository;

  GetAreasWithTablesUseCase(this.repository);

  @override
  Future<Either<Failure, List<AreaWithTablesEntity>>> call(NoParams params) async {
    return await repository.getAreasWithTables(params);
  }
}
