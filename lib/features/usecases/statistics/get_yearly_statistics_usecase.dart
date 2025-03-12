import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/aggregated_statistics_entity.dart';
import '../../repositories/statistics_repository.dart';

class GetYearlyStatisticsParams extends Equatable {
  const GetYearlyStatisticsParams();
  @override
  List<Object?> get props => [];
}

class GetYearlyStatisticsUseCase
    implements UseCase<List<AggregatedStatisticsEntity>, GetYearlyStatisticsParams> {
  final StatisticsRepository repository;

  GetYearlyStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> call(
    GetYearlyStatisticsParams params,
  ) async {
    return await repository.getYearlyStatistics(params);
  }
}
