import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/flavor.dart';
import 'features/blocs/auth/auth_cubit.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorService.initialize(Flavor.prod);

  await init();

  sl.registerSingletonAsync<AuthCubit>(() async {
    final authCubit = AuthCubit(
      loginUseCase: sl(),
      logoutUseCase: sl(),
      getLoggedUserUseCase: sl(),
    );
    // Listen state change of cubit
    authCubit.stream.listen((state) {
      if (state is AuthAuthenticated) {
        // Update Dio headers
        sl<Dio>().options.headers = {'userid': state.user.id, 'Content-Type': 'application/json'};
      } else if (state is AuthUnauthenticated) {
        sl<Dio>().options.headers = null;
      }
    });
    await authCubit.getLoggedInUser();
    return authCubit;
  });

  await sl.allReady();

  runApp(const App());
}
