import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class UpdateUserParams extends Equatable {
  final String id;
  final String? username;
  final String? fullname;
  final String? role;
  final String? password;
  final String? email;
  final String? phoneNumber;
  final bool? isActive;

  const UpdateUserParams({
    required this.id,
    this.username,
    this.fullname,
    this.role,
    this.password,
    this.email,
    this.phoneNumber,
    this.isActive,
  });
  @override
  List<Object?> get props => [id, username, fullname, role, password, email, phoneNumber, isActive];
}

class UpdateUserUseCase implements UseCase<UserEntity, UpdateUserParams> {
  final UserRepository repository;

  UpdateUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(UpdateUserParams params) async {
    return await repository.updateUser(params);
  }
}
