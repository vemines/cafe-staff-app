import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/area_table_entity.dart';
import '../../repositories/table_repository.dart';

class CreateAreaParams extends Equatable {
  final String name;

  const CreateAreaParams({required this.name});

  @override
  List<Object?> get props => [name];
}

class CreateAreaUseCase implements UseCase<AreaTableEntity, CreateAreaParams> {
  final TableRepository repository;

  CreateAreaUseCase(this.repository);

  @override
  Future<Either<Failure, AreaTableEntity>> call(CreateAreaParams params) async {
    return await repository.createArea(params);
  }
}
