import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/area_entity.dart';
import '../../repositories/table_repository.dart';

class GetAllAreaUseCase implements UseCase<List<AreaEntity>, NoParams> {
  final TableRepository repository;

  GetAllAreaUseCase(this.repository);

  @override
  Future<Either<Failure, List<AreaEntity>>> call(NoParams params) async {
    return await repository.getAllAreasTable(params);
  }
}
