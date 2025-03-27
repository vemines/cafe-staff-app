import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import '../../blocs/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final authCubit = context.read<AuthCubit>();
    authCubit.getLoggedInUser();

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isNavigating) {
        _isNavigating = true;
        final state = context.read<AuthCubit>().state;
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else {
          context.go('/login');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen(
      useImmersiveMode: true,
      backgroundColor: Colors.white,
      splashScreenBody: Center(child: Lottie.asset("assets/lottie/splash.json", repeat: false)),
    );
  }
}
