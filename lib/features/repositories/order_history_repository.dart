import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/order_history_entity.dart';
import '../usecases/order_history/get_all_order_history_usecase.dart';
import '../usecases/order_history/get_order_history_by_id_usecase.dart';

abstract class OrderHistoryRepository {
  Future<Either<Failure, List<OrderHistoryEntity>>> getAllOrderHistory(
    GetAllOrderHistoryParams params,
  );
  Future<Either<Failure, OrderHistoryEntity>> getOrderHistoryById(GetOrderHistoryByIdParams params);
}

class OrderHistoryRepositoryImpl implements OrderHistoryRepository {
  @override
  Future<Either<Failure, List<OrderHistoryEntity>>> getAllOrderHistory(
    GetAllOrderHistoryParams params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, OrderHistoryEntity>> getOrderHistoryById(
    GetOrderHistoryByIdParams params,
  ) {
    throw UnimplementedError();
  }
}
