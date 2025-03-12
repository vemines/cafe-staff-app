import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/table_entity.dart';
import '../../repositories/table_repository.dart';

class GetAllTablesParams extends PaginationParams {
  final String? areaId;
  const GetAllTablesParams({required super.page, required super.limit, super.order, this.areaId});

  @override
  List<Object?> get props => [...super.props, areaId];
}

class GetAllTablesUseCase implements UseCase<List<TableEntity>, GetAllTablesParams> {
  final TableRepository repository;

  GetAllTablesUseCase(this.repository);

  @override
  Future<Either<Failure, List<TableEntity>>> call(GetAllTablesParams params) async {
    return await repository.getAllTables(params);
  }
}
