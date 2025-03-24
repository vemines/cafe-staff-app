import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../repositories/payment_repository.dart';

class DeletePaymentParams extends Equatable {
  final String id;

  const DeletePaymentParams({required this.id});

  @override
  List<Object?> get props => [id];
}

class DeletePaymentUseCase implements UseCase<Unit, DeletePaymentParams> {
  final PaymentRepository repository;

  DeletePaymentUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeletePaymentParams params) async {
    return await repository.deletePayment(params);
  }
}
