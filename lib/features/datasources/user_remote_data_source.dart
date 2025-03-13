// lib/features/data/datasources/remote/user_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class UserRemoteDataSource {
  Future<List<UserModel>> getAllUsers({
    required int page,
    required int limit,
    String? searchTerm,
    String? roleFilter,
  });
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
  Future<List<UserModel>> getAllUsers({
    required int page,
    required int limit,
    String? searchTerm,
    String? roleFilter,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.users,
        queryParameters: {'page': page, 'limit': limit, 'search': searchTerm, 'role': roleFilter},
      );
      return (response.data as List).map((item) => UserModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'getAllUsers({required int page, required int limit, String? searchTerm, String? roleFilter})',
      );
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
      handleDioException(e, s, 'getUserById({required String userId})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

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
          'username': username,
          'fullname': fullname,
          'role': role,
          'password': password,
          'email': email,
          'phoneNumber': phoneNumber,
          'isActive': isActive,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'createUser({required String username, required String fullname, required String role, required String password, required String email, required String phoneNumber, required bool isActive})',
      );
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
      final response = await dio.patch(
        ApiEndpoints.singleUser(id),
        data: {
          'username': username,
          'fullname': fullname,
          'role': role,
          'password': password,
          // lib/features/data/datasources/remote/user_remote_data_source.dart (Continued)
          'email': email,
          'phoneNumber': phoneNumber,
          'isActive': isActive,
        },
      );
      return UserModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'updateUser({required String id, String? username, String? fullname, String? role, String? password, String? email, String? phoneNumber, bool? isActive})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteUser({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleUser(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'deleteUser({required String id})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
