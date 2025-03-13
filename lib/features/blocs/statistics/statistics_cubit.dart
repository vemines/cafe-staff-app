import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../../../core/usecase/params.dart';
import '../../entities/aggregated_statistics_entity.dart';
import '../../entities/statistics_entity.dart';
import '../../usecases/statistics/get_all_aggregated_statistics_usecase.dart';
import '../../usecases/statistics/get_all_statistics_usecase.dart';
import '../../usecases/statistics/get_this_week_statistics_usecase.dart';
import '../../usecases/statistics/get_today_statistics_usecase.dart';
import '../../usecases/statistics/get_yearly_statistics_usecase.dart';

part 'statistics_state.dart';

class StatisticsCubit extends Cubit<StatisticsState> {
  final GetAllStatisticsUseCase getAllStatisticsUseCase;
  final GetAllAggregatedStatisticsUseCase getAllAggregatedStatisticsUseCase;
  final GetTodayStatisticsUseCase getTodayStatisticsUseCase;
  final GetThisWeekStatisticsUseCase getThisWeekStatisticsUseCase;
  final GetYearlyStatisticsUseCase getYearlyStatisticsUseCase;

  StatisticsCubit({
    required this.getAllStatisticsUseCase,
    required this.getAllAggregatedStatisticsUseCase,
    required this.getTodayStatisticsUseCase,
    required this.getThisWeekStatisticsUseCase,
    required this.getYearlyStatisticsUseCase,
  }) : super(StatisticsInitial());

  Future<void> getAllStatistics() async {
    emit(StatisticsLoading());
    final result = await getAllStatisticsUseCase(NoParams());
    result.fold(
      (failure) => emit(StatisticsError(failure: failure)),
      (statistics) => emit(DailyStatisticsLoaded(statistics: statistics)),
    );
  }

  Future<void> getAllAggregatedStatistics() async {
    emit(StatisticsLoading());
    final result = await getAllAggregatedStatisticsUseCase(NoParams());
    result.fold(
      (failure) => emit(StatisticsError(failure: failure)),
      (statistics) => emit(AggregatedStatisticsLoaded(statistics: statistics)),
    );
  }

  Future<void> getTodayStatistics() async {
    emit(StatisticsLoading());
    final result = await getTodayStatisticsUseCase(NoParams());
    result.fold(
      (failure) => emit(StatisticsError(failure: failure)),
      (statistics) => emit(DailyStatisticsLoaded(statistics: [statistics])), // Single item
    );
  }

  Future<void> getThisWeekStatistics() async {
    emit(StatisticsLoading());
    final result = await getThisWeekStatisticsUseCase(NoParams());
    result.fold(
      (failure) => emit(StatisticsError(failure: failure)),
      (statistics) => emit(DailyStatisticsLoaded(statistics: statistics)),
    );
  }

  Future<void> getYearlyStatistics() async {
    emit(StatisticsLoading());
    final result = await getYearlyStatisticsUseCase(const GetYearlyStatisticsParams());
    result.fold(
      (failure) => emit(StatisticsError(failure: failure)),
      (statistics) => emit(AggregatedStatisticsLoaded(statistics: statistics)),
    );
  }
}
