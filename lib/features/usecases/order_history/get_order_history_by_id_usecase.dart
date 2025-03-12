import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/usecase.dart';
import '../../entities/order_history_entity.dart';
import '../../repositories/order_history_repository.dart';

class GetOrderHistoryByIdParams extends Equatable {
  final String id;

  const GetOrderHistoryByIdParams({required this.id});
  @override
  List<Object?> get props => [id];
}

class GetOrderHistoryByIdUseCase implements UseCase<OrderHistoryEntity, GetOrderHistoryByIdParams> {
  final OrderHistoryRepository repository;

  GetOrderHistoryByIdUseCase(this.repository);

  @override
  Future<Either<Failure, OrderHistoryEntity>> call(GetOrderHistoryByIdParams params) async {
    return await repository.getOrderHistoryById(params);
  }
}
