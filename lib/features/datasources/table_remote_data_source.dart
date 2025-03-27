import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../models/area_model.dart';
import '../models/area_with_table_model.dart';
import '../models/table_model.dart';

abstract class TableRemoteDataSource {
  Future<AreaModel> createArea({required String name});
  Future<AreaModel> updateArea({required String id, required String name});
  Future<void> deleteArea({required String id});
  Future<List<AreaModel>> getAllAreas();
  Future<List<TableModel>> getAllTables();
  Future<TableModel> createTable({
    required String tableName,
    required String status,
    required String areaId,
  });
  Future<TableModel> updateTable({
    required String id,
    String? name,
    String? status,
    String? areaId,
  });
  Future<void> deleteTable({required String id});
  Future<List<AreaWithTablesModel>> getAreasWithTables();
}

class TableRemoteDataSourceImpl implements TableRemoteDataSource {
  final Dio dio;

  TableRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<AreaWithTablesModel>> getAreasWithTables() async {
    try {
      final response = await dio.get(ApiEndpoints.areasWithTables);
      return (response.data as List).map((item) => AreaWithTablesModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.getAreasWithTables');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.getAreasWithTables',
      );
    }
  }

  @override
  Future<AreaModel> createArea({required String name}) async {
    try {
      final response = await dio.post(ApiEndpoints.areas, data: {AreaApiMap.name: name});
      return AreaModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.createArea');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.createArea',
      );
    }
  }

  @override
  Future<List<TableModel>> getAllTables() async {
    try {
      final response = await dio.get(ApiEndpoints.tables);
      return (response.data as List).map((item) => TableModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.getAllTables');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.getAllTables',
      );
    }
  }

  @override
  Future<List<AreaModel>> getAllAreas() async {
    try {
      final response = await dio.get(ApiEndpoints.areas);
      return (response.data as List).map((item) => AreaModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.getAllAreas');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.getAllAreas',
      );
    }
  }

  @override
  Future<AreaModel> updateArea({required String id, String? name}) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData[AreaApiMap.name] = name;

      final response = await dio.patch(ApiEndpoints.singleArea(id), data: updateData);
      return AreaModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.updateArea');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.updateArea',
      );
    }
  }

  @override
  Future<void> deleteArea({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleArea(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.deleteArea');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.deleteArea',
      );
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
        data: {TableApiMap.name: tableName, TableApiMap.status: status, TableApiMap.areaId: areaId},
      );
      return TableModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.createTable');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.createTable',
      );
    }
  }

  @override
  Future<TableModel> updateTable({
    required String id,
    String? name,
    String? status,
    String? areaId,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData[TableApiMap.name] = name;
      if (status != null) updateData[TableApiMap.status] = status;
      if (areaId != null) updateData[TableApiMap.areaId] = areaId;

      final response = await dio.patch(ApiEndpoints.singleTable(id), data: updateData);
      return TableModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.updateTable');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.updateTable',
      );
    }
  }

  @override
  Future<void> deleteTable({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleTable(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'TableRemoteDataSource.deleteTable');
    } catch (e, s) {
      throw ServerException(
        message: e.toString(),
        stackTrace: s,
        at: 'TableRemoteDataSource.deleteTable',
      );
    }
  }
}
