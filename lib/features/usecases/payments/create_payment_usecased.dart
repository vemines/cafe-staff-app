import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/payment_entity.dart';
import '../../repositories/payment_repository.dart';

class CreatePaymentParams extends Equatable {
  final String name;

  const CreatePaymentParams({required this.name});

  @override
  List<Object?> get props => [name];
}

class CreatePaymentUseCase implements UseCase<PaymentEntity, CreatePaymentParams> {
  final PaymentRepository repository;

  CreatePaymentUseCase(this.repository);
  @override
  Future<Either<Failure, PaymentEntity>> call(CreatePaymentParams params) async {
    return await repository.createPayment(params);
  }
}
