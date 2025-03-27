import 'package:dartz/dartz.dart';

import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/core/network/network_info.dart';
import '../datasources/order_history_remote_data_source.dart';
import '../usecases/order_history/get_all_order_history_usecase.dart';

abstract class OrderHistoryRepository {
  Future<Either<Failure, Map<String, dynamic>>> getAllOrderHistory(GetAllOrderHistoryParams params);
}

class OrderHistoryRepositoryImpl implements OrderHistoryRepository {
  final OrderHistoryRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  OrderHistoryRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, Map<String, dynamic>>> getAllOrderHistory(
    GetAllOrderHistoryParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteOrderHistory = await remoteDataSource.getAllOrderHistory(
          startDate: params.startDate,
          endDate: params.endDate,
          paymentMethod: params.paymentMethod,
          page: params.page,
          limit: params.limit,
        );

        return Right(remoteOrderHistory);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
