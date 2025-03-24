import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/auth_repository.dart';

class GetLoggedUserUseCase implements UseCase<UserEntity, NoParams> {
  final AuthRepository repository;

  GetLoggedUserUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getLoggedUser();
  }
}
