import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/area_table_entity.dart';
import '../entities/area_with_table_entity.dart';
import '../entities/table_entity.dart';
import '../usecases/table/create_area_usecase.dart';
import '../usecases/table/create_table_usecase.dart';
import '../usecases/table/delete_area_usecase.dart';
import '../usecases/table/delete_table_usecase.dart';
import '../usecases/table/get_all_tables_usecase.dart';
import '../usecases/table/update_area_usecase.dart';
import '../usecases/table/update_table_usecase.dart';

abstract class TableRepository {
  Future<Either<Failure, List<AreaTableEntity>>> getAllAreas(NoParams params);
  Future<Either<Failure, AreaTableEntity>> createArea(CreateAreaParams params);
  Future<Either<Failure, AreaTableEntity>> updateArea(UpdateAreaParams params);
  Future<Either<Failure, Unit>> deleteArea(DeleteAreaParams params);

  Future<Either<Failure, List<TableEntity>>> getAllTables(GetAllTablesParams params);
  Future<Either<Failure, TableEntity>> createTable(CreateTableParams params);
  Future<Either<Failure, TableEntity>> updateTable(UpdateTableParams params);
  Future<Either<Failure, Unit>> deleteTable(DeleteTableParams params);

  Future<Either<Failure, List<AreaWithTablesEntity>>> getAreasWithTables(NoParams params);
}

class TableRepositoryImpl implements TableRepository {
  @override
  Future<Either<Failure, List<AreaTableEntity>>> getAllAreas(NoParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AreaTableEntity>> createArea(CreateAreaParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, AreaTableEntity>> updateArea(UpdateAreaParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteArea(DeleteAreaParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<TableEntity>>> getAllTables(GetAllTablesParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TableEntity>> createTable(CreateTableParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, TableEntity>> updateTable(UpdateTableParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteTable(DeleteTableParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<AreaWithTablesEntity>>> getAreasWithTables(NoParams params) {
    throw UnimplementedError();
  }
}
