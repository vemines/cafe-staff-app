import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../entities/user_entity.dart';
import '../usecases/user/create_user_usecase.dart';
import '../usecases/user/delete_user_usecase.dart';
import '../usecases/user/get_all_users_usecase.dart';
import '../usecases/user/get_user_by_id_usecase.dart';
import '../usecases/user/update_user_usecase.dart';

abstract class UserRepository {
  Future<Either<Failure, List<UserEntity>>> getAllUsers(GetAllUsersParams params);
  Future<Either<Failure, UserEntity>> getUserById(GetUserByIdParams params);
  Future<Either<Failure, UserEntity>> createUser(CreateUserParams params);
  Future<Either<Failure, UserEntity>> updateUser(UpdateUserParams params);
  Future<Either<Failure, Unit>> deleteUser(DeleteUserParams params);
}

class UserRepositoryImpl implements UserRepository {
  @override
  Future<Either<Failure, List<UserEntity>>> getAllUsers(GetAllUsersParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> getUserById(GetUserByIdParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> createUser(CreateUserParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, UserEntity>> updateUser(UpdateUserParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteUser(DeleteUserParams params) {
    throw UnimplementedError();
  }
}
