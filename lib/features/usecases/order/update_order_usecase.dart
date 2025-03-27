import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../entities/order_item_entity.dart';
import '../../repositories/order_repository.dart';

class UpdateOrderParams extends Equatable {
  final String orderId;
  final List<OrderItemEntity> orderItems;

  const UpdateOrderParams({required this.orderId, required this.orderItems});

  @override
  List<Object?> get props => [orderId, orderItems];
}

class UpdateOrderUseCase implements UseCase<OrderEntity, UpdateOrderParams> {
  final OrderRepository repository;

  UpdateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(UpdateOrderParams params) async {
    return await repository.updateOrder(params);
  }
}
