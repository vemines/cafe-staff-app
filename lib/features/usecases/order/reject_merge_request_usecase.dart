import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../repositories/order_repository.dart';

class RejectMergeRequestParams extends Equatable {
  final String tableId;

  const RejectMergeRequestParams({required this.tableId});

  @override
  List<Object> get props => [tableId];
}

class RejectMergeRequestUseCase implements UseCase<Unit, RejectMergeRequestParams> {
  final OrderRepository repository;

  RejectMergeRequestUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(RejectMergeRequestParams params) async {
    return await repository.rejectMergeRequest(params);
  }
}
