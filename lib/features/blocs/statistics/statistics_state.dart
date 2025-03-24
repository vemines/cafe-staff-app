part of 'statistics_cubit.dart';

abstract class StatisticsState extends Equatable {
  const StatisticsState();

  @override
  List<Object> get props => [];
}

class StatisticsInitial extends StatisticsState {}

class StatisticsLoading extends StatisticsState {}

class DailyStatisticsLoaded extends StatisticsState {
  final StatisticsEntity statistic;

  const DailyStatisticsLoaded({required this.statistic});

  @override
  List<Object> get props => [statistic];
}

class WeeklyStatisticsLoaded extends StatisticsState {
  final List<StatisticsEntity> statistics;

  const WeeklyStatisticsLoaded({required this.statistics});

  @override
  List<Object> get props => [statistics];
}

class AggregatedStatisticsLoaded extends StatisticsState {
  final List<AggregatedStatisticsEntity> statistics;

  const AggregatedStatisticsLoaded({required this.statistics});

  @override
  List<Object> get props => [statistics];
}

class StatisticsError extends StatisticsState {
  final Failure failure;

  const StatisticsError({required this.failure});

  @override
  List<Object> get props => [failure];
}
