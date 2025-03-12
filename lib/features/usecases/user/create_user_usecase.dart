import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class CreateUserParams extends Equatable {
  final String username;
  final String fullname;
  final String role;
  final String password;
  final String email;
  final String phoneNumber;
  final bool isActive;

  const CreateUserParams({
    required this.username,
    required this.fullname,
    required this.role,
    required this.password,
    required this.email,
    required this.phoneNumber,
    required this.isActive,
  });

  @override
  List<Object?> get props => [username, fullname, role, password, email, phoneNumber, isActive];
}

class CreateUserUseCase implements UseCase<UserEntity, CreateUserParams> {
  final UserRepository repository;

  CreateUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(CreateUserParams params) async {
    return await repository.createUser(params);
  }
}
