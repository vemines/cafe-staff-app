// lib/features/data/datasources/remote/table_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/area_table_model.dart';
import '../models/area_with_table_model.dart';
import '../models/table_model.dart';

abstract class TableRemoteDataSource {
  Future<List<AreaTableModel>> getAllAreas();
  Future<AreaTableModel> createArea({required String name});
  Future<AreaTableModel> updateArea({required String id, required String name});
  Future<void> deleteArea({required String id});

  Future<List<TableModel>> getAllTables({required int page, required int limit, String? areaId});
  Future<TableModel> createTable({
    required String tableName,
    required String status,
    required String areaId,
  });
  Future<TableModel> updateTable({
    required String id,
    required String tableName,
    required String status,
    required String areaId,
  });
  Future<void> deleteTable({required String id});
  Future<List<AreaWithTablesModel>> getAreasWithTables();
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  final Dio dio;

  TableRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AreaTableModel>> getAllAreas() async {
    try {
      final response = await dio.get(ApiEndpoints.areaTables);
      return (response.data as List).map((item) => AreaTableModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAllAreas()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<AreaWithTablesModel>> getAreasWithTables() async {
    try {
      final response = await dio.get(ApiEndpoints.areasWithTables);
      return (response.data as List).map((item) => AreaWithTablesModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'getAreasWithTables()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<AreaTableModel> createArea({required String name}) async {
    try {
      final response = await dio.post(ApiEndpoints.areaTables, data: {'name': name});
      return AreaTableModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'createArea({required String name})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<AreaTableModel> updateArea({required String id, required String name}) async {
    try {
      final response = await dio.patch(ApiEndpoints.singleAreaTable(id), data: {'name': name});
      return AreaTableModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'updateArea({required String id, required String name})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteArea({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleAreaTable(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'deleteArea({required String id})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<TableModel>> getAllTables({
    required int page,
    required int limit,
    String? areaId,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.tables,
        queryParameters: {'page': page, 'limit': limit, 'areaId': areaId},
      );
      return (response.data as List).map((item) => TableModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'getAllTables({required int page, required int limit, String? areaId})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<TableModel> createTable({
    required String tableName,
    required String status,
    required String areaId,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.tables,
        data: {'tableName': tableName, 'status': status, 'areaId': areaId},
      );
      return TableModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'createTable({required String tableName, required String status, required String areaId})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<TableModel> updateTable({
    required String id,
    required String tableName,
    required String status,
    required String areaId,
  }) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.singleTable(id),
        data: {'tableName': tableName, 'status': status, 'areaId': areaId},
      );
      return TableModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'updateTable({required String id, required String tableName, required String status, required String areaId})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteTable({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleTable(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'deleteTable({required String id})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
