import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/area_table_entity.dart';
import '../../repositories/table_repository.dart';

class UpdateAreaParams extends Equatable {
  final String id;
  final String name;

  const UpdateAreaParams({required this.id, required this.name});

  @override
  List<Object?> get props => [id, name];
}

class UpdateAreaUseCase implements UseCase<AreaTableEntity, UpdateAreaParams> {
  final TableRepository repository;

  UpdateAreaUseCase(this.repository);

  @override
  Future<Either<Failure, AreaTableEntity>> call(UpdateAreaParams params) async {
    return await repository.updateArea(params);
  }
}
