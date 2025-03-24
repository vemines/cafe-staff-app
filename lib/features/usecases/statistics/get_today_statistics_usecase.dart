import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/statistics_entity.dart';
import '../../repositories/statistics_repository.dart';

class GetTodayStatisticsUseCase implements UseCase<StatisticsEntity, NoParams> {
  final StatisticsRepository repository;

  GetTodayStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, StatisticsEntity>> call(NoParams params) async {
    return await repository.getTodayStatistics(params);
  }
}
