import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class GetAllUserUseCase implements UseCase<List<UserEntity>, NoParams> {
  final UserRepository repository;

  GetAllUserUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(NoParams params) async {
    return await repository.getAllUsers(params);
  }
}
