import 'package:dartz/dartz.dart';

import '../../../core/constants/enum.dart';
import '../../../core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/user_entity.dart';
import '../../repositories/user_repository.dart';

class GetAllUsersParams extends PaginationParams {
  final String? searchTerm;
  final String? roleFilter;

  const GetAllUsersParams({
    required super.page,
    required super.limit,
    super.order = PaginationOrder.desc,
    this.searchTerm,
    this.roleFilter,
  });

  @override
  List<Object?> get props => [...super.props, searchTerm, roleFilter];
}

class GetAllUsersUseCase implements UseCase<List<UserEntity>, GetAllUsersParams> {
  final UserRepository repository;

  GetAllUsersUseCase(this.repository);

  @override
  Future<Either<Failure, List<UserEntity>>> call(GetAllUsersParams params) async {
    return await repository.getAllUsers(params);
  }
}
