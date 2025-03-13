import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/usecase/usecase.dart';
import '../datasources/table_remote_data_source.dart';
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
  final TableRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  TableRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<AreaTableEntity>>> getAllAreas(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAreas = await remoteDataSource.getAllAreas();
        return Right(remoteAreas);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, AreaTableEntity>> createArea(CreateAreaParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteArea = await remoteDataSource.createArea(name: params.name);
        return Right(remoteArea);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, AreaTableEntity>> updateArea(UpdateAreaParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteArea = await remoteDataSource.updateArea(id: params.id, name: params.name);
        return Right(remoteArea);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteArea(DeleteAreaParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteArea(id: params.id);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<TableEntity>>> getAllTables(GetAllTablesParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTables = await remoteDataSource.getAllTables(
          page: params.page,
          limit: params.limit,
          areaId: params.areaId,
        );
        return Right(remoteTables);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, TableEntity>> createTable(CreateTableParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTable = await remoteDataSource.createTable(
          tableName: params.tableName,
          status: params.status,
          areaId: params.areaId,
        );
        return Right(remoteTable);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, TableEntity>> updateTable(UpdateTableParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteTable = await remoteDataSource.updateTable(
          id: params.id,
          tableName: params.tableName,
          status: params.status,
          areaId: params.areaId,
        );
        return Right(remoteTable);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteTable(DeleteTableParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteTable(id: params.id);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<AreaWithTablesEntity>>> getAreasWithTables(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteAreasWithTables = await remoteDataSource.getAreasWithTables();
        return Right(remoteAreasWithTables);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
