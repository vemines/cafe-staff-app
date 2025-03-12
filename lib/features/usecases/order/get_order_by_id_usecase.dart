import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrderByIdParams extends Equatable {
  final String orderId;
  const GetOrderByIdParams({required this.orderId});
  @override
  List<Object?> get props => [orderId];
}

class GetOrderByIdUseCase implements UseCase<OrderEntity, GetOrderByIdParams> {
  final OrderRepository repository;

  GetOrderByIdUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(GetOrderByIdParams params) async {
    return await repository.getOrderById(params);
  }
}
