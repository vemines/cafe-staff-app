import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '../../../core/usecase/params.dart';
import '../../entities/user_entity.dart';
import '../../usecases/user/create_user_usecase.dart';
import '../../usecases/user/delete_user_usecase.dart';
import '../../usecases/user/get_all_user_usecase.dart';
import '../../usecases/user/get_user_by_id_usecase.dart';
import '../../usecases/user/update_user_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetAllUserUseCase getAllUsersUseCase;
  final GetUserByIdUseCase getUserByIdUseCase;
  final CreateUserUseCase createUserUseCase;
  final UpdateUserUseCase updateUserUseCase;
  final DeleteUserUseCase deleteUserUseCase;

  UserCubit({
    required this.getAllUsersUseCase,
    required this.getUserByIdUseCase,
    required this.createUserUseCase,
    required this.updateUserUseCase,
    required this.deleteUserUseCase,
  }) : super(UserInitial());

  Future<void> getAllUsers() async {
    final result = await getAllUsersUseCase(NoParams());
    result.fold(
      (failure) => emit(UserError(failure: failure)),
      (users) => emit(UserLoaded(users: users)),
    );
  }

  Future<void> createUser({
    required String username,
    required String fullname,
    required String role,
    required String password,
    required String email,
    required String phoneNumber,
    required bool isActive,
  }) async {
    final result = await createUserUseCase(
      CreateUserParams(
        username: username,
        fullname: fullname,
        role: role,
        password: password,
        email: email,
        phoneNumber: phoneNumber,
        isActive: isActive,
      ),
    );
    result.fold((failure) => emit(UserError(failure: failure)), (user) {
      List<UserEntity> users = (state as UserLoaded).users;
      emit(UserLoaded(users: [...users, user]));
    });
  }

  Future<void> updateUser({
    required String id,
    String? username,
    String? fullname,
    String? role,
    String? password,
    String? email,
    String? phoneNumber,
    bool? isActive,
  }) async {
    final result = await updateUserUseCase(
      UpdateUserParams(
        id: id,
        username: username,
        fullname: fullname,
        role: role,
        password: password,
        email: email,
        phoneNumber: phoneNumber,
        isActive: isActive,
      ),
    );
    result.fold((failure) => emit(UserError(failure: failure)), (user) {
      List<UserEntity> users =
          (state as UserLoaded).users.map((u) => u.id == user.id ? user : u).toList();
      emit(UserLoaded(users: users));
    });
  }

  Future<void> deleteUser({required String id}) async {
    final result = await deleteUserUseCase(DeleteUserParams(id: id));
    result.fold((failure) => emit(UserError(failure: failure)), (_) {
      List<UserEntity> users = (state as UserLoaded).users.where((u) => u.id != id).toList();
      emit(UserLoaded(users: users));
    });
  }
}
