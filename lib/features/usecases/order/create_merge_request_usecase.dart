import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../repositories/order_repository.dart';

class CreateMergeRequestParams extends Equatable {
  final String sourceTableId;
  final String targetTableId;
  final List<String> splitItemIds;

  const CreateMergeRequestParams({
    required this.sourceTableId,
    required this.targetTableId,
    required this.splitItemIds,
  });

  @override
  List<Object?> get props => [sourceTableId, targetTableId, splitItemIds];
}

class CreateMergeRequestUseCase implements UseCase<Unit, CreateMergeRequestParams> {
  final OrderRepository repository;

  CreateMergeRequestUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(CreateMergeRequestParams params) async {
    return await repository.createMergeRequest(params);
  }
}
