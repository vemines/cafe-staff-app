import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/order_entity.dart';
import '../usecases/order/create_order_usecase.dart';
import '../usecases/order/get_order_by_id_usecase.dart';
import '../usecases/order/get_order_by_table_id_usecase.dart';
import '../usecases/order/get_orders_usecase.dart';
import '../usecases/order/update_order_usecase.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder(CreateOrderParams params);
  Future<Either<Failure, OrderEntity>> getOrderById(GetOrderByIdParams params);
  Future<Either<Failure, List<OrderEntity>>> getOrders(GetOrdersParams params);
  Future<Either<Failure, List<OrderEntity>>> getOrdersByTableId(GetOrderByTableIdParams params);
  Future<Either<Failure, OrderEntity>> updateOrder(UpdateOrderParams params);
}

class OrderRepositoryImpl implements OrderRepository {
  @override
  Future<Either<Failure, OrderEntity>> createOrder(CreateOrderParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(GetOrderByIdParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders(GetOrdersParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrdersByTableId(GetOrderByTableIdParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrder(UpdateOrderParams params) {
    throw UnimplementedError();
  }
}
