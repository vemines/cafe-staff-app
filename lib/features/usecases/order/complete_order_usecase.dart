import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class CompleteOrderParams extends Equatable {
  final String orderId;
  final String paymentMethod;

  const CompleteOrderParams({required this.orderId, required this.paymentMethod});

  @override
  List<Object?> get props => [orderId, paymentMethod];
}

class CompleteOrderUseCase implements UseCase<OrderEntity, CompleteOrderParams> {
  final OrderRepository repository;

  CompleteOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CompleteOrderParams params) async {
    return await repository.completeOrder(params);
  }
}
