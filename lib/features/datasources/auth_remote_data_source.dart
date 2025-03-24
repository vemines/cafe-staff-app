import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<UserModel> login({required String username, required String password});
  Future<UserModel> register({
    required String username,
    required String fullname,
    required String role,
    required String password,
    required String email,
    required String phoneNumber,
    required bool isActive,
  });
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio dio;

  AuthRemoteDataSourceImpl({required this.dio});

  @override
  Future<UserModel> login({required String username, required String password}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.login,
        data: {UserApiMap.username: username, UserApiMap.password: password},
      );
      final user = UserModel.fromJson(response.data['user']);

      dio.options.headers = {'userid': user.id, 'Content-Type': 'application/json'};

      return user;
    } on DioException catch (e, s) {
      handleDioException(e, s, 'AuthRemoteDataSource.login');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<UserModel> register({
    required String username,
    required String fullname,
    required String role,
    required String password,
    required String email,
    required String phoneNumber,
    required bool isActive,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.users,
        data: {
          UserApiMap.username: username,
          UserApiMap.fullname: fullname,
          UserApiMap.role: role,
          UserApiMap.password: password,
          UserApiMap.email: email,
          UserApiMap.phoneNumber: phoneNumber,
          isActive: isActive,
        },
      );
      // Assuming the user is directly in response.data
      final user = UserModel.fromJson(response.data);
      return user;
    } on DioException catch (e, s) {
      handleDioException(e, s, 'AuthRemoteDataSource.register');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
