import 'package:dartz/dartz.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/aggregated_statistics_entity.dart';
import '../../repositories/statistics_repository.dart';

class GetAllAggregatedStatisticsUseCase
    implements UseCase<List<AggregatedStatisticsEntity>, NoParams> {
  final StatisticsRepository repository;

  GetAllAggregatedStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, List<AggregatedStatisticsEntity>>> call(NoParams params) async {
    return await repository.getAllAggregatedStatistics(params);
  }
}
