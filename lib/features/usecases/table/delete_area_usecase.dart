import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../repositories/table_repository.dart';

class DeleteAreaParams extends Equatable {
  final String id;

  const DeleteAreaParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteAreaUseCase implements UseCase<Unit, DeleteAreaParams> {
  final TableRepository repository;

  DeleteAreaUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteAreaParams params) async {
    return await repository.deleteArea(params);
  }
}
