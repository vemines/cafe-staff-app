import 'package:device_preview/device_preview.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/flavor.dart';
// import 'core/services/socket_service.dart';
import 'features/blocs/auth/auth_cubit.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorService.initialize(Flavor.dev);

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

        // Connect the SocketService *only* when authenticated.
        // if (!sl.isRegistered<SocketService>()) {
        //   // Check before registering
        //   sl.registerSingleton<SocketService>(SocketService(headers: _getHeaders));
        // }
        // sl<SocketService>().connect(); // Connect
      } else if (state is AuthUnauthenticated) {
        // Disconnect and *unregister* the SocketService.
        // if (sl.isRegistered<SocketService>()) {
        //   // IMPORTANT: Check if registered!
        //   sl<SocketService>().disconnect(); // Disconnect
        //   sl.unregister<SocketService>(); // Unregister (clean up)
        // }
      }
    });
    await authCubit.getLoggedInUser();
    return authCubit;
  });

  await sl.allReady();

  runApp(DevicePreview(builder: (context) => App(), backgroundColor: Colors.black54));
}

// Map<String, dynamic> _getHeaders() {
//   final authState = sl.isRegistered<AuthCubit>() ? sl<AuthCubit>().state : null;
//   final Map<String, dynamic> headers = {'Content-Type': 'application/json'};
//   if (authState is AuthAuthenticated) {
//     headers['userid'] = authState.user.id;
//   }
//   return headers;
// }
