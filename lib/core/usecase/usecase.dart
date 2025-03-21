import 'package:dartz/dartz.dart';

import '../errors/failures.dart';

export 'params.dart';

abstract class UseCase<Type, Params> {
  Future<Either<Failure, Type>> call(Params params);
}
