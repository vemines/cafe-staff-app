import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/table_entity.dart';
import '../../repositories/table_repository.dart';

class GetAllTableUseCase implements UseCase<List<TableEntity>, NoParams> {
  final TableRepository repository;

  GetAllTableUseCase(this.repository);

  @override
  Future<Either<Failure, List<TableEntity>>> call(NoParams params) async {
    return await repository.getAllTables(params);
  }
}
