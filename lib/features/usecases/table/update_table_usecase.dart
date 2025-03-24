import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/table_entity.dart';
import '../../repositories/table_repository.dart';

class UpdateTableParams extends Equatable {
  final String id;
  final String name;
  final String status;
  final String areaId;

  const UpdateTableParams({
    required this.id,
    required this.name,
    required this.status,
    required this.areaId,
  });

  @override
  List<Object?> get props => [id, name, status, areaId];
}

class UpdateTableUseCase implements UseCase<TableEntity, UpdateTableParams> {
  final TableRepository repository;

  UpdateTableUseCase(this.repository);

  @override
  Future<Either<Failure, TableEntity>> call(UpdateTableParams params) async {
    return await repository.updateTable(params);
  }
}
