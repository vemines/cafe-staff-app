import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/order_remote_data_source.dart';
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
  final OrderRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, OrderEntity>> createOrder(CreateOrderParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrder = await remoteDataSource.createOrder(
          tableId: params.tableId,
          orderItems: params.orderItems,
        );
        return Right(remoteOrder);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> getOrderById(GetOrderByIdParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrder = await remoteDataSource.getOrderById(orderId: params.orderId);
        return Right(remoteOrder);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrders(GetOrdersParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrders = await remoteDataSource.getOrders(
          page: params.page,
          limit: params.limit,
          startDate: params.startDate,
          endDate: params.endDate,
          tableId: params.tableId,
        );
        return Right(remoteOrders);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<OrderEntity>>> getOrdersByTableId(
    GetOrderByTableIdParams params,
  ) async {
    // This functionality does not exist in the provided API.  Return an appropriate error.
    return const Left(ServerFailure(message: 'GetOrdersByTableId functionality not implemented.'));
  }

  @override
  Future<Either<Failure, OrderEntity>> updateOrder(UpdateOrderParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrder = await remoteDataSource.updateOrder(
          id: params.id,
          orderStatus: params.orderStatus,
          paymentMethod: params.paymentMethod,
        );
        return Right(remoteOrder);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
