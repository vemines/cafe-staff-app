import '../../core/usecase/params.dart';
import 'package:dartz/dartz.dart';

import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/core/network/network_info.dart';
import '../datasources/user_remote_data_source.dart';
import '../entities/user_entity.dart';
import '../usecases/user/create_user_usecase.dart';
import '../usecases/user/delete_user_usecase.dart';
import '../usecases/user/get_user_by_id_usecase.dart';
import '../usecases/user/update_user_usecase.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUsers(NoParams params);
  Future<Either<Failure, UserEntity>> getUserById(GetUserByIdParams params);
  Future<Either<Failure, UserEntity>> createUser(CreateUserParams params);
  Future<Either<Failure, UserEntity>> updateUser(UpdateUserParams params);
  Future<Either<Failure, Unit>> deleteUser(DeleteUserParams params);
}

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  UserRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUsers = await remoteDataSource.getAllUsers();
        return Right(remoteUsers);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(GetUserByIdParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.getUserById(userId: params.userId);
        return Right(remoteUser);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(CreateUserParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.createUser(
          username: params.username,
          fullname: params.fullname,
          role: params.role,
          password: params.password,
          email: params.email,
          phoneNumber: params.phoneNumber,
          isActive: params.isActive,
        );
        return Right(remoteUser);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UpdateUserParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.updateUser(
          id: params.id,
          username: params.username,
          fullname: params.fullname,
          role: params.role,
          password: params.password,
          email: params.email,
          phoneNumber: params.phoneNumber,
          isActive: params.isActive,
        );
        return Right(remoteUser);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(DeleteUserParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteUser(id: params.id);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
