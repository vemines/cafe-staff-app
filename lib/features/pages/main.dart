import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:ui';
import '../../core/pages/not_found_page.dart';
import 'admin/dashboard/dashboard_page.dart';
import 'admin/menu_management/menu_management_page.dart';
import 'admin/order_history/order_history_page.dart';
import 'admin/statistics/statistics_page.dart';
import 'admin/table_management/table_management_page.dart';
import 'admin/user_management/user_management_page.dart';
import 'auth/login_page.dart';
import 'settings/settings_page.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DevicePreview(builder: (context) => MyApp(), backgroundColor: Colors.black54));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Restaurant App',
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      debugShowCheckedModeBanner: false,
      scrollBehavior: MyCustomScrollBehavior(),
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      // home: SplashScreen(),
      routerConfig: routes,
    );
  }
}

final tableColor = Colors.green[100];
final borderColor = Colors.grey;

class MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  ScrollPhysics getScrollPhysics(BuildContext context) {
    switch (getPlatform(context)) {
      case TargetPlatform.linux:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
        return const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics());
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.iOS:
        return super.getScrollPhysics(context);
    }
  }

  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
    PointerDeviceKind.stylus,
    PointerDeviceKind.trackpad,
  };
}

class Paths {
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String dashboard = '/dashboard';
  static const String userManagement = '/user_management';
  static const String menuManagement = '/menu_management';
  static const String tableManagement = '/table_management';
  static const String orderHistory = '/order_history';
  static const String statistics = '/statistics';
  static const String settings = '/settings';
}

final routes = GoRouter(
  initialLocation: Paths.dashboard,

  // redirect: (context, state) async {
  //   final authCubit = sl<AuthCubit>();
  //   await authCubit.getLoggedInUser();

  //   final isAuthenticated = authCubit.state is AuthAuthenticated;

  //   final isLoginPage = state.uri.path == Paths.login;
  //   if (!isAuthenticated && !isLoginPage) {
  //     return Paths.login; // Redirect to login if not authenticated and not on login page
  //   }
  routes: [
    GoRoute(path: Paths.login, builder: (context, state) => const LoginPage()),
    // GoRoute(
    //   path: Paths.home,
    //   builder: (context, state) {
    //     final user = state.extra as UserEntity;
    //     return HomePage(user: user);
    //   },
    // ),
    // Admin Pages
    GoRoute(path: Paths.dashboard, builder: (context, state) => const DashboardPage()),
    GoRoute(path: Paths.userManagement, builder: (context, state) => const UserManagementPage()),
    GoRoute(path: Paths.menuManagement, builder: (context, state) => const MenuManagementPage()),
    GoRoute(path: Paths.tableManagement, builder: (context, state) => const TableManagementPage()),
    GoRoute(
      path: Paths.orderHistory,
      builder: (context, state) {
        return OrderHistoryPage();
      },
    ),
    GoRoute(path: Paths.statistics, builder: (context, state) => const StatisticsPage()),
    GoRoute(path: Paths.settings, builder: (context, state) => const SettingsPage()),
    // GoRoute(path: Paths.register, builder: (context, state) => const RegisterPage()), //Removed
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);
