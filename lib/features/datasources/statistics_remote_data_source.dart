// lib/features/data/datasources/remote/statistics_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/aggregated_statistics_model.dart';
import '../models/statistics_model.dart';

abstract class StatisticsRemoteDataSource {
  Future<List<StatisticsModel>> getAllStatistics();
  Future<List<AggregatedStatisticsModel>> getAllAggregatedStatistics();
  Future<StatisticsModel> getTodayStatistics();
  Future<List<StatisticsModel>> getThisWeekStatistics();
  Future<List<AggregatedStatisticsModel>> getYearlyStatistics();
}

class StatisticsRemoteDataSourceImpl implements StatisticsRemoteDataSource {
  final Dio dio;

  StatisticsRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AggregatedStatisticsModel>> getAllAggregatedStatistics() async {
    try {
      final response = await dio.get(ApiEndpoints.statisticsYears);
      return (response.data as List)
          .map((item) => AggregatedStatisticsModel.fromJson(item))
          .toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAllAggregatedStatistics()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<StatisticsModel> getTodayStatistics() async {
    try {
      final response = await dio.get(ApiEndpoints.todayStatistics);
      return StatisticsModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getTodayStatistics()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<AggregatedStatisticsModel>> getYearlyStatistics() async {
    try {
      final response = await dio.get(ApiEndpoints.statisticsYears);
      return (response.data as List)
          .map((item) => AggregatedStatisticsModel.fromJson(item))
          .toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getYearlyStatistics()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<StatisticsModel>> getThisWeekStatistics() async {
    try {
      final response = await dio.get(ApiEndpoints.thisWeekStatistics);
      final List<dynamic> data = response.data;
      if (data.isNotEmpty) {
        return data.map((item) => StatisticsModel.fromJson(item)).toList();
      } else {
        throw ServerException(message: "No statistics found for this week.");
      }
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getThisWeekStatistics()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<StatisticsModel>> getAllStatistics() async {
    try {
      final response = await dio.get(ApiEndpoints.statistics);
      return (response.data as List).map((item) => StatisticsModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAllStatistics()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
