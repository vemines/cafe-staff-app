import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/aggregated_statistics_entity.dart';
import '../entities/statistics_entity.dart';
import '../usecases/statistics/get_yearly_statistics_usecase.dart';

abstract class StatisticsRepository {
  Future<Either<Failure, List<StatisticsEntity>>> getAllStatistics(NoParams params);
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getAllAggregatedStatistics(
    NoParams params,
  );
  Future<Either<Failure, StatisticsEntity>> getTodayStatistics(NoParams params);
  Future<Either<Failure, StatisticsEntity>> getThisWeekStatistics(NoParams params);
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getYearlyStatistics(
    GetYearlyStatisticsParams params,
  );
}

class StatisticsRepositoryImpl implements StatisticsRepository {
  @override
  Future<Either<Failure, List<StatisticsEntity>>> getAllStatistics(NoParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getAllAggregatedStatistics(
    NoParams params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getTodayStatistics(NoParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, StatisticsEntity>> getThisWeekStatistics(NoParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> getYearlyStatistics(
    GetYearlyStatisticsParams params,
  ) {
    throw UnimplementedError();
  }
}
