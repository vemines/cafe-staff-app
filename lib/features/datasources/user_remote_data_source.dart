import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers();
  Future<UserModel> getUserById({required String userId});
  Future<UserModel> createUser({
    required String username,
    required String fullname,
    required String role,
    required String password,
    required String email,
    required String phoneNumber,
    required bool isActive,
  });
  Future<UserModel> updateUser({
    required String id,
    String? username,
    String? fullname,
    String? role,
    String? password,
    String? email,
    String? phoneNumber,
    bool? isActive,
  });
  Future<void> deleteUser({required String id});
}

class UserRemoteDataSourceImpl implements UserRemoteDataSource {
  final Dio dio;

  UserRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<UserModel>> getAllUsers() async {
    try {
      final response = await dio.get(ApiEndpoints.users);
      return (response.data as List).map((item) => UserModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'UserRemoteDataSource.getAllUsers');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<UserModel> getUserById({required String userId}) async {
    try {
      final response = await dio.get(ApiEndpoints.singleUser(userId));
      return UserModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'UserRemoteDataSource.getUserById');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  @override
  Future<UserModel> createUser({
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
          UserApiMap.isActive: isActive,
        },
      );
      final user = UserModel.fromJson(response.data);
      return user;
    } on DioException catch (e, s) {
      handleDioException(e, s, 'AuthRemoteDataSource.register');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<UserModel> updateUser({
    required String id,
    String? username,
    String? fullname,
    String? role,
    String? password,
    String? email,
    String? phoneNumber,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (username != null) updateData[UserApiMap.username] = username;
      if (fullname != null) updateData[UserApiMap.fullname] = fullname;
      if (role != null) updateData[UserApiMap.role] = role;
      if (password != null) updateData[UserApiMap.password] = password;
      if (email != null) updateData[UserApiMap.email] = email;
      if (phoneNumber != null) updateData[UserApiMap.phoneNumber] = phoneNumber;
      if (isActive != null) updateData[UserApiMap.isActive] = isActive;

      final response = await dio.patch(ApiEndpoints.singleUser(id), data: updateData);
      return UserModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'UserRemoteDataSource.updateUser');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteUser({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleUser(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'UserRemoteDataSource.deleteUser');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
