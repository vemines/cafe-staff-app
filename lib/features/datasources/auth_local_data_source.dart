import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../entities/user_entity.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<void> saveUser(UserEntity user);
  Future<UserEntity?> getUser();
  Future<void> clearUser();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage secureStorage;
  static const _userKey = 'logged_in_user';

  AuthLocalDataSourceImpl({required this.secureStorage});

  @override
  Future<void> saveUser(UserEntity user) async {
    final userModel = UserModel.fromEntity(user);
    final userJson = jsonEncode(userModel.toJson());
    await secureStorage.write(key: _userKey, value: userJson);
  }

  @override
  Future<UserEntity?> getUser() async {
    final userJson = await secureStorage.read(key: _userKey);
    if (userJson != null) return UserModel.fromJson(jsonDecode(userJson));

    return null;
  }

  @override
  Future<void> clearUser() async {
    await secureStorage.delete(key: _userKey);
  }
}
