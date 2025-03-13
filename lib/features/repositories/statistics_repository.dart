import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/usecase/usecase.dart';
import '../datasources/statistics_remote_data_source.dart';
import '../entities/aggregated_statistics_entity.dart';
import '../entities/statistics_entity.dart';
import '../usecases/statistics/get_yearly_statistics_usecase.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, List<StatisticsEntity>>> getAllStatistics(NoParams params);
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getAllAggregatedStatistics(
    NoParams params,
  );
  Future<Either<Failure, StatisticsEntity>> getTodayStatistics(NoParams params);
  Future<Either<Failure, List<StatisticsEntity>>> getThisWeekStatistics(NoParams params);
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getYearlyStatistics(
    GetYearlyStatisticsParams params,
  );
}

class StatisticsRepositoryImpl implements StatisticsRepository {
  final StatisticsRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  StatisticsRepositoryImpl({required this.remoteDataSource, required this.networkInfo});
  @override
  Future<Either<Failure, List<StatisticsEntity>>> getAllStatistics(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteStatistics = await remoteDataSource.getAllStatistics();
        return Right(remoteStatistics);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getAllAggregatedStatistics(
    NoParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAggregatedStatistics = await remoteDataSource.getAllAggregatedStatistics();
        return Right(remoteAggregatedStatistics);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getTodayStatistics(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteStatistics = await remoteDataSource.getTodayStatistics();
        return Right(remoteStatistics);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<StatisticsEntity>>> getThisWeekStatistics(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteStatistics = await remoteDataSource.getThisWeekStatistics();
        return Right(remoteStatistics);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getYearlyStatistics(
    GetYearlyStatisticsParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteYearlyStatistics = await remoteDataSource.getYearlyStatistics();
        return Right(remoteYearlyStatistics);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
