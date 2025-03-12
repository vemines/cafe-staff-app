import '../../core/constants/api_map.dart';
import '../../core/utils/parse_utils.dart';
import '../entities/user_entity.dart';

class UserModel extends UserEntity {
  const UserModel({
    required super.id,
    required super.username,
    required super.fullname,
    required super.role,
    required super.email,
    required super.phoneNumber,
    required super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json[UserApiMap.id] as String,
      username: json[UserApiMap.username] as String,
      fullname: json[UserApiMap.fullname] as String,
      role: json[UserApiMap.role] as String,
      email: json[UserApiMap.email] as String,
      phoneNumber: json[UserApiMap.phoneNumber] as String,
      isActive: json[UserApiMap.isActive] as bool,
      createdAt: dateParse(json[kCreatedAt]),
      updatedAt: dateParse(json[kUpdatedAt]),
    );
  }

  factory UserModel.fromEntity(UserEntity entity) {
    return UserModel(
      id: entity.id,
      username: entity.username,
      fullname: entity.fullname,
      role: entity.role,
      email: entity.email,
      phoneNumber: entity.phoneNumber,
      isActive: entity.isActive,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  @override
  UserModel copyWith({
    String? id,
    String? username,
    String? fullname,
    String? role,
    String? password,
    String? email,
    String? phoneNumber,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      username: username ?? this.username,
      fullname: fullname ?? this.fullname,
      role: role ?? this.role,
      email: email ?? this.email,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      UserApiMap.id: id,
      UserApiMap.username: username,
      UserApiMap.fullname: fullname,
      UserApiMap.role: role,
      UserApiMap.email: email,
      UserApiMap.phoneNumber: phoneNumber,
      UserApiMap.isActive: isActive,
      kCreatedAt: createdAt.toIso8601String(),
      kUpdatedAt: updatedAt.toIso8601String(),
    };
  }
}
