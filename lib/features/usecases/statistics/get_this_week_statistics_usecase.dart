import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/statistics_entity.dart';
import '../../repositories/statistics_repository.dart';

class GetThisWeekStatisticsUseCase implements UseCase<List<StatisticsEntity>, NoParams> {
  final StatisticsRepository repository;

  GetThisWeekStatisticsUseCase(this.repository);

  @override
  Future<Either<Failure, List<StatisticsEntity>>> call(NoParams params) async {
    return await repository.getThisWeekStatistics(params);
  }
}
