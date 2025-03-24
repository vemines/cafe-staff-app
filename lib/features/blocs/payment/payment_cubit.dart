import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '/core/usecase/params.dart';
import '../../entities/payment_entity.dart';
import '../../usecases/payments/create_payment_usecased.dart';
import '../../usecases/payments/delete_payment_usecase.dart';
import '../../usecases/payments/get_all_payments_usecase.dart';
import '../../usecases/payments/update_payment_usecase.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final GetAllPaymentUseCase getAllPaymentsUseCase;
  final CreatePaymentUseCase createPaymentUseCase;
  final UpdatePaymentUseCase updatePaymentUseCase;
  final DeletePaymentUseCase deletePaymentUseCase;

  PaymentCubit({
    required this.getAllPaymentsUseCase,
    required this.createPaymentUseCase,
    required this.updatePaymentUseCase,
    required this.deletePaymentUseCase,
  }) : super(PaymentInitial());

  Future<void> getAllPayments() async {
    final result = await getAllPaymentsUseCase(NoParams());
    result.fold(
      (failure) => emit(PaymentError(failure: failure)),
      (payments) => emit(PaymentLoaded(payments: payments)),
    );
  }

  Future<void> createPayment({required String name}) async {
    final result = await createPaymentUseCase(CreatePaymentParams(name: name));
    result.fold((failure) => emit(PaymentError(failure: failure)), (payment) {
      List<PaymentEntity> payments = [];
      if (state is PaymentLoaded) {
        payments = (state as PaymentLoaded).payments;
      }

      emit(PaymentLoaded(payments: [...payments, payment]));
    });
  }

  Future<void> updatePayment({
    required String id,
    required String name,
    required bool isActive,
  }) async {
    final result = await updatePaymentUseCase(
      UpdatePaymentParams(id: id, name: name, isActive: isActive),
    );
    result.fold((failure) => emit(PaymentError(failure: failure)), (payment) {
      List<PaymentEntity> payments = [];
      if (state is PaymentLoaded) {
        payments = (state as PaymentLoaded).payments;
      }
      payments = payments.map((p) => p.id == payment.id ? payment : p).toList();

      emit(PaymentLoaded(payments: payments));
    });
  }

  Future<void> deletePayment({required String id}) async {
    final result = await deletePaymentUseCase(DeletePaymentParams(id: id));
    result.fold((failure) => emit(PaymentError(failure: failure)), (_) {
      List<PaymentEntity> payments = [];
      if (state is PaymentLoaded) {
        payments = (state as PaymentLoaded).payments;
      }
      payments = payments.where((p) => p.id != id).toList();
      emit(PaymentLoaded(payments: payments));
    });
  }
}
