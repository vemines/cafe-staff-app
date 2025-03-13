// lib/features/data/datasources/remote/auth_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login({required String username, required String password}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {'username': username, 'password': password},
      );
      final user = UserModel.fromJson(response.data['user']);

      dio.options.headers = {'userid': user.id, 'Content-Type': 'application/json'};

      return user;
    } on DioException catch (e, s) {
      handleDioException(e, s, 'login(String username, String password)');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
