import 'package:another_flutter_splash_screen/another_flutter_splash_screen.dart';
import 'package:flutter/material.dart';
// import 'package:go_router/go_router.dart';
import 'package:lottie/lottie.dart';

import 'mock.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  void _toLoginOrHome(bool isLogged) {
    if (isLogged) {
      // 'serve' , 'cashier', 'admin'
      final user = MockData.staff.where((u) => u.role == 'admin').first;
      Navigator.pushNamed(context, '/home', arguments: user);
    } else {
      Navigator.pushNamed(context, '/login');
    }
  }

  Future<bool> _isLogged() async {
    await Future.delayed(Duration(seconds: 5));
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FlutterSplashScreen(
      useImmersiveMode: true,
      backgroundColor: Colors.white,
      splashScreenBody: Center(child: Lottie.asset("assets/lottie/splash.json", repeat: false)),
      asyncNavigationCallback: () async {
        // TODO: Check auth cubit state
        bool isLogged = await _isLogged();
        _toLoginOrHome(isLogged);
      },
    );
  }
}
