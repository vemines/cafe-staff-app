import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/table_entity.dart';
import '../../repositories/table_repository.dart';

class CreateTableParams extends Equatable {
  final String tableName;
  final String status;
  final String areaId;

  const CreateTableParams({required this.tableName, required this.status, required this.areaId});

  @override
  List<Object?> get props => [tableName, status, areaId];
}

class CreateTableUseCase implements UseCase<TableEntity, CreateTableParams> {
  final TableRepository repository;

  CreateTableUseCase(this.repository);

  @override
  Future<Either<Failure, TableEntity>> call(CreateTableParams params) async {
    return await repository.createTable(params);
  }
}
