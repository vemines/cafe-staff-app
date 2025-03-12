import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrderByTableIdParams extends Equatable {
  final String tableId;

  const GetOrderByTableIdParams({required this.tableId});

  @override
  List<Object?> get props => [tableId];
}

class GetOrdersByTableId implements UseCase<List<OrderEntity>, GetOrderByTableIdParams> {
  final OrderRepository repository;

  GetOrdersByTableId(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(GetOrderByTableIdParams params) async {
    return await repository.getOrdersByTableId(params);
  }
}
