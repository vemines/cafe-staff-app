import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../core/usecase/params.dart';
import '../../entities/user_entity.dart';
import '../../usecases/auth/get_logged_user_usecase.dart';
import '../../usecases/auth/login_usecase.dart';
import '../../usecases/auth/logout_usecase.dart';

part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final LoginUseCase loginUseCase;
  final LogoutUseCase logoutUseCase;
  final GetLoggedUserUseCase getLoggedUserUseCase;

  AuthCubit({
    required this.loginUseCase,
    required this.logoutUseCase,
    required this.getLoggedUserUseCase,
  }) : super(AuthInitial());

  Future<void> login(LoginParams params) async {
    emit(AuthLoading());
    final result = await loginUseCase(params);
    result.fold(
      (failure) {
        emit(AuthError(failure: failure));
      },
      (user) {
        emit(AuthAuthenticated(user: user));
      },
    );
  }

  Future<void> logout() async {
    emit(AuthLoading());
    final result = await logoutUseCase(NoParams());
    result.fold((failure) => emit(AuthError(failure: failure)), (_) => emit(AuthUnauthenticated()));
  }

  Future<void> getLoggedInUser() async {
    final result = await getLoggedUserUseCase(NoParams());
    result.fold(
      (failure) => emit(AuthUnauthenticated()),
      (user) => emit(AuthAuthenticated(user: user)),
    );
  }
}
