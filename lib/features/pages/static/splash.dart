import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_cubit.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isNavigating = false; // Flag to prevent double navigation

  @override
  void initState() {
    super.initState();
    _checkAuthentication();
  }

  void _checkAuthentication() {
    final authCubit = context.read<AuthCubit>();
    authCubit.getLoggedInUser();

    // Start the 2-second timer *unconditionally*.
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted && !_isNavigating) {
        // Check if still mounted AND not already navigating.
        _isNavigating = true; // Set the flag
        final state =
            context.read<AuthCubit>().state; // Get *current* state.  Don't rely on captured state.
        if (state is AuthAuthenticated) {
          context.go('/home');
        } else {
          // Covers initial, loading, and unauthenticated states.
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
