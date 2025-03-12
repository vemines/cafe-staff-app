import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class UpdateOrderParams extends Equatable {
  final String id;
  final String? orderStatus;
  final String? paymentMethod;

  const UpdateOrderParams({required this.id, this.orderStatus, this.paymentMethod});

  @override
  List<Object?> get props => [id, orderStatus, paymentMethod];
}

class UpdateOrderUseCase implements UseCase<OrderEntity, UpdateOrderParams> {
  final OrderRepository repository;

  UpdateOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(UpdateOrderParams params) async {
    return await repository.updateOrder(params);
  }
}
