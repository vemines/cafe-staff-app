import 'package:dartz/dartz.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/payment_entity.dart';
import '../../repositories/payment_repository.dart';

class GetAllPaymentUseCase implements UseCase<List<PaymentEntity>, NoParams> {
  final PaymentRepository repository;

  GetAllPaymentUseCase(this.repository);

  @override
  Future<Either<Failure, List<PaymentEntity>>> call(NoParams params) async {
    return await repository.getAllPayments();
  }
}
