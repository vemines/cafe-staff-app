import 'package:go_router/go_router.dart';

import '../core/pages/not_found_page.dart';
import '../features/blocs/auth/auth_cubit.dart';
import '../injection_container.dart';

class Paths {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
}

final routes = GoRouter(
  initialLocation: sl<AuthCubit>().state is AuthAuthenticated ? Paths.home : Paths.login,
  redirect: (context, state) {
    final userCubit = sl<AuthCubit>();
    // if (userCubit.state is AuthInitial) userCubit.getLoggedInUser();
    final isUserenticated = userCubit.state is AuthAuthenticated;

    final isLoginPage = state.uri.path == Paths.login;
    return isUserenticated && !isLoginPage ? null : Paths.login;
  },
  routes: [
    // GoRoute(path: Paths.login, builder: (context, state) => const LoginPage()),
    // GoRoute(path: Paths.home, builder: (context, state) => const HomePage()),
    // GoRoute(path: Paths.register, builder: (context, state) => const RegisterPage()),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
