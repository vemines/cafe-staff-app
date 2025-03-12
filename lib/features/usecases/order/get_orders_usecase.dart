import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order_entity.dart';
import '../../repositories/order_repository.dart';

class GetOrdersParams extends PaginationParams {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? tableId;

  const GetOrdersParams({
    required super.page,
    required super.limit,
    super.order,
    this.startDate,
    this.endDate,
    this.tableId,
  });

  @override
  List<Object?> get props => [...super.props, startDate, endDate, tableId];
}

class GetOrdersUseCase implements UseCase<List<OrderEntity>, GetOrdersParams> {
  final OrderRepository repository;

  GetOrdersUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderEntity>>> call(GetOrdersParams params) async {
    return await repository.getOrders(params);
  }
}
