import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../repositories/order_repository.dart';

class ApproveMergeRequestParams extends Equatable {
  final String mergeRequestId;

  const ApproveMergeRequestParams({required this.mergeRequestId});

  @override
  List<Object> get props => [mergeRequestId];
}

class ApproveMergeRequestUseCase implements UseCase<Unit, ApproveMergeRequestParams> {
  final OrderRepository repository;

  ApproveMergeRequestUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(ApproveMergeRequestParams params) async {
    return await repository.approveMergeRequest(params);
  }
}
