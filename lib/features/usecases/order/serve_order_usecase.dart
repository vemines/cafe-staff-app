import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class ServeOrderParams extends Equatable {
  final String orderId;

  const ServeOrderParams({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class ServeOrderUseCase implements UseCase<OrderEntity, ServeOrderParams> {
  final OrderRepository repository;

  ServeOrderUseCase(this.repository);

  @override
  Future<Either<Failure, OrderEntity>> call(ServeOrderParams params) async {
    return await repository.serveOrder(params);
  }
}
