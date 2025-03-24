import 'package:dartz/dartz.dart';

import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/core/network/network_info.dart';
import '../datasources/auth_local_data_source.dart';
import '../datasources/auth_remote_data_source.dart';
import '../entities/user_entity.dart';
import '../usecases/auth/login_usecase.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(LoginParams params);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, UserEntity>> getLoggedUser();
}

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final NetworkInfo networkInfo;

  AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.networkInfo,
  });

  @override
  Future<Either<Failure, UserEntity>> login(LoginParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteUser = await remoteDataSource.login(
          username: params.username,
          password: params.password,
        );
        await localDataSource.saveUser(remoteUser);
        return Right(remoteUser);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> logout() async {
    try {
      await localDataSource.clearUser();
      return const Right(unit);
    } catch (e) {
      return Left(AppFailure(message: "Failed to clear user data."));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getLoggedUser() async {
    final user = await localDataSource.getUser();
    if (user == null) return Left(UnauthenticatedFailure());

    return Right(user);
  }
}
