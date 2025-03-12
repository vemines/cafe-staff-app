import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../entities/order_item_entity.dart';
import '../../repositories/order_repository.dart';

class CreateOrderParams extends Equatable {
  final String tableId;
  final List<OrderItemEntity> orderItems;

  const CreateOrderParams({required this.tableId, required this.orderItems});

  @override
  List<Object?> get props => [tableId, orderItems];
}

class CreateOrderUseCase implements UseCase<OrderEntity, CreateOrderParams> {
  final OrderRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(CreateOrderParams params) async {
    return await repository.createOrder(params);
  }
}
