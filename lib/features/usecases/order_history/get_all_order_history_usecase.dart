import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/order_history_entity.dart';
import '../../repositories/order_history_repository.dart';

class GetAllOrderHistoryParams extends PaginationParams {
  final DateTime? startDate;
  final DateTime? endDate;

  const GetAllOrderHistoryParams({
    required super.page,
    required super.limit,
    super.order,
    this.startDate,
    this.endDate,
  });
  @override
  List<Object?> get props => [...super.props, startDate, endDate];
}

class GetAllOrderHistoryUseCase
    implements UseCase<List<OrderHistoryEntity>, GetAllOrderHistoryParams> {
  final OrderHistoryRepository repository;

  GetAllOrderHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<OrderHistoryEntity>>> call(GetAllOrderHistoryParams params) async {
    return await repository.getAllOrderHistory(params);
  }
}
