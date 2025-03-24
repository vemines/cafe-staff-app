import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../models/payment_model.dart';

abstract class PaymentRemoteDataSource {
  Future<List<PaymentModel>> getAllPayments();
  Future<PaymentModel> createPayment({required String name});
  Future<PaymentModel> updatePayment({
    required String id,
    required String name,
    required bool isActive,
  });
  Future<void> deletePayment({required String id});
}

class PaymentRemoteDataSourceImpl implements PaymentRemoteDataSource {
  final Dio dio;

  PaymentRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<PaymentModel>> getAllPayments() async {
    try {
      final response = await dio.get(ApiEndpoints.payments);
      return (response.data as List).map((item) => PaymentModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'PaymentRemoteDataSource.getAllPayments');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<PaymentModel> createPayment({required String name}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.payments,
        data: {PaymentApiMap.name: name, PaymentApiMap.isActive: false},
      );
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'PaymentRemoteDataSource.createPayment');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<PaymentModel> updatePayment({required String id, String? name, bool? isActive}) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData[PaymentApiMap.name] = name;
      if (isActive != null) updateData[PaymentApiMap.isActive] = isActive;
      final response = await dio.patch(ApiEndpoints.singlePayment(id), data: updateData);
      return PaymentModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'PaymentRemoteDataSource.updatePayment');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deletePayment({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singlePayment(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'PaymentRemoteDataSource.deletePayment');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
