import 'package:dartz/dartz.dart';

import '/core/errors/exceptions.dart';
import '/core/errors/failures.dart';
import '/core/network/network_info.dart';
import '../datasources/payment_remote_data_source.dart';
import '../entities/payment_entity.dart';
import '../usecases/payments/create_payment_usecased.dart';
import '../usecases/payments/delete_payment_usecase.dart';
import '../usecases/payments/update_payment_usecase.dart';

abstract class PaymentRepository {
  Future<Either<Failure, List<PaymentEntity>>> getAllPayments();
  Future<Either<Failure, PaymentEntity>> createPayment(CreatePaymentParams params);
  Future<Either<Failure, PaymentEntity>> updatePayment(UpdatePaymentParams params);
  Future<Either<Failure, Unit>> deletePayment(DeletePaymentParams params);
}

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  PaymentRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<PaymentEntity>>> getAllPayments() async {
    if (await networkInfo.isConnected) {
      try {
        final remotePayments = await remoteDataSource.getAllPayments();
        return Right(remotePayments);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> createPayment(CreatePaymentParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePayment = await remoteDataSource.createPayment(name: params.name);
        return Right(remotePayment);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, PaymentEntity>> updatePayment(UpdatePaymentParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remotePayment = await remoteDataSource.updatePayment(
          id: params.id,
          name: params.name,
          isActive: params.isActive,
        );
        return Right(remotePayment);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deletePayment(DeletePaymentParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deletePayment(id: params.id);
        return Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
