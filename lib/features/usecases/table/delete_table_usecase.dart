import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../repositories/table_repository.dart';

class DeleteTableParams extends Equatable {
  final String id;

  const DeleteTableParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeleteTableUseCase implements UseCase<Unit, DeleteTableParams> {
  final TableRepository repository;

  DeleteTableUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteTableParams params) async {
    return await repository.deleteTable(params);
  }
}
