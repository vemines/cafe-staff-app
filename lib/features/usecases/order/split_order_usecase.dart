import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../repositories/order_repository.dart';

class SplitOrderParams extends Equatable {
  final String sourceTableId;
  final String targetTableId;
  final List<String> splitItemIds;

  const SplitOrderParams({
    required this.sourceTableId,
    required this.targetTableId,
    required this.splitItemIds,
  });

  @override
  List<Object?> get props => [sourceTableId, targetTableId, splitItemIds];
}

class SplitOrderUseCase implements UseCase<Unit, SplitOrderParams> {
  final OrderRepository repository;

  SplitOrderUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(SplitOrderParams params) async {
    return await repository.splitOrder(params);
  }
}
