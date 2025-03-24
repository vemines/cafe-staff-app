import 'package:dartz/dartz.dart';

import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/core/network/network_info.dart';
import '../datasources/order_remote_data_source.dart';
import '../entities/order_entity.dart';
import '../usecases/order/approve_merge_request_usecase.dart';
import '../usecases/order/complete_order_usecase.dart';
import '../usecases/order/create_merge_request_usecase.dart';
import '../usecases/order/create_order_usecase.dart';
import '../usecases/order/reject_merge_request_usecase.dart';
import '../usecases/order/serve_order_usecase.dart';
import '../usecases/order/split_order_usecase.dart';

abstract class OrderRepository {
  Future<Either<Failure, OrderEntity>> createOrder(CreateOrderParams params);
  Future<Either<Failure, Unit>> createMergeRequest(CreateMergeRequestParams params);
  Future<Either<Failure, Unit>> approveMergeRequest(ApproveMergeRequestParams params);
  Future<Either<Failure, Unit>> rejectMergeRequest(RejectMergeRequestParams params);
  Future<Either<Failure, Unit>> splitOrder(SplitOrderParams params);
  Future<Either<Failure, OrderEntity>> serveOrder(ServeOrderParams params);
  Future<Either<Failure, OrderEntity>> completeOrder(CompleteOrderParams params);
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
  Future<Either<Failure, Unit>> createMergeRequest(CreateMergeRequestParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.mergeOrders(
          sourceTableId: params.sourceTableId,
          targetTableId: params.targetTableId,
          splitItemIds: params.splitItemIds,
        );
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> approveMergeRequest(ApproveMergeRequestParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.approveMerge(mergeRequestId: params.mergeRequestId);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> splitOrder(SplitOrderParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.splitOrder(
          sourceTableId: params.sourceTableId,
          targetTableId: params.targetTableId,
          splitItemIds: params.splitItemIds,
        );
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> rejectMergeRequest(RejectMergeRequestParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.rejectMergeRequest(mergeRequestId: params.mergeRequestId);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, OrderEntity>> serveOrder(ServeOrderParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrder = await remoteDataSource.updateOrder(
          id: params.orderId,
          status: 'served',
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
  Future<Either<Failure, OrderEntity>> completeOrder(CompleteOrderParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrder = await remoteDataSource.updateOrder(
          id: params.orderId,
          status: 'completed',
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
