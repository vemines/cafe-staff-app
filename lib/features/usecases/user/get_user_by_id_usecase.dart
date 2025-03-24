import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class GetUserByIdParams extends Equatable {
  final String userId;
  const GetUserByIdParams({required this.userId});
  @override
  List<Object?> get props => [userId];
}

class GetUserByIdUseCase implements UseCase<UserEntity, GetUserByIdParams> {
  final UserRepository repository;

  GetUserByIdUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(GetUserByIdParams params) async {
    return await repository.getUserById(params);
  }
}
