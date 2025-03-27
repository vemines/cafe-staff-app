import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/payment_entity.dart';
import '../../repositories/payment_repository.dart';

class UpdatePaymentParams extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const UpdatePaymentParams({required this.id, required this.name, required this.isActive});

  @override
  List<Object?> get props => [id, name];
}

class UpdatePaymentUseCase implements UseCase<PaymentEntity, UpdatePaymentParams> {
  final PaymentRepository repository;

  UpdatePaymentUseCase(this.repository);
  @override
  Future<Either<Failure, PaymentEntity>> call(UpdatePaymentParams params) async {
    return await repository.updatePayment(params);
  }
}
