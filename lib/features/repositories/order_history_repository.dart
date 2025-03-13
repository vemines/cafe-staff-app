import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../datasources/order_history_remote_data_source.dart';
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
  final OrderHistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderHistoryRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<OrderHistoryEntity>>> getAllOrderHistory(
    GetAllOrderHistoryParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrderHistory = await remoteDataSource.getAllOrderHistory(
          page: params.page,
          limit: params.limit,
          startDate: params.startDate,
          endDate: params.endDate,
        );
        return Right(remoteOrderHistory);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, OrderHistoryEntity>> getOrderHistoryById(
    GetOrderHistoryByIdParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrderHistory = await remoteDataSource.getOrderHistoryById(id: params.id);
        return Right(remoteOrderHistory);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
