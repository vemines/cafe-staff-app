import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/user_entity.dart';
import '../../usecases/user/create_user_usecase.dart';
import '../../usecases/user/delete_user_usecase.dart';
import '../../usecases/user/get_all_users_usecase.dart';
import '../../usecases/user/get_user_by_id_usecase.dart';
import '../../usecases/user/update_user_usecase.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final GetAllUsersUseCase getAllUsersUseCase;
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

  Future<void> getAllUsers(GetAllUsersParams params) async {
    emit(UserLoading());
    final result = await getAllUsersUseCase(params);
    result.fold(
      (failure) => emit(UserError(failure: failure)),
      (users) => emit(UserLoaded(users: users)),
    );
  }

  Future<void> getUserById(GetUserByIdParams params) async {
    emit(UserLoading());
    final result = await getUserByIdUseCase(params);
    result.fold(
      (failure) => emit(UserError(failure: failure)),
      (user) => emit(UserLoaded(users: [user])), // Wrap single user
    );
  }

  Future<void> createUser(CreateUserParams params) async {
    emit(UserLoading());
    final result = await createUserUseCase(params);
    result.fold(
      (failure) => emit(UserError(failure: failure)),
      (user) => emit(UserCreated(user: user)),
    );
  }

  Future<void> updateUser(UpdateUserParams params) async {
    emit(UserLoading());
    final result = await updateUserUseCase(params);
    result.fold(
      (failure) => emit(UserError(failure: failure)),
      (user) => emit(UserUpdated(user: user)),
    );
  }

  Future<void> deleteUser(DeleteUserParams params) async {
    emit(UserLoading());
    final result = await deleteUserUseCase(params);
    result.fold((failure) => emit(UserError(failure: failure)), (_) => emit(UserDeleted()));
  }
}
