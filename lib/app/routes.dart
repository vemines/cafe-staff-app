import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// import '../features/entities/aggregated_statistics_entity.dart';
// import '../features/entities/statistics_entity.dart';
import '../features/pages/static/splash.dart';
import '/features/blocs/auth/auth_cubit.dart';
import '/features/pages/admin/dashboard/dashboard_page.dart';
import '/features/pages/admin/dashboard/statistics_detail_page.dart';
import '/features/pages/admin/feedback/admin_feedback_page.dart';
import '/features/pages/admin/menu_management/menu_management_page.dart';
import '/features/pages/admin/order_history/order_history_page.dart';
import '/features/pages/admin/table_management/table_management_page.dart';
import '/features/pages/admin/user_management/user_management_page.dart';
import '/features/pages/admin/payment_management/payment_management_page.dart';
import '/features/pages/auth/login_page.dart';
import '/features/pages/settings/settings_page.dart';
import '/features/pages/staff/home/home_page.dart';
import '/features/pages/staff/order_history/order_history_page.dart';
import '../features/pages/static/not_found_page.dart';
import '../injection_container.dart';
import 'paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Paths.login,
  redirect: (context, state) {
    final authCubit = sl<AuthCubit>();
    final authState = authCubit.state;
    final path = state.uri.path;

    if (authState is AuthUnauthenticated && path != Paths.login) {
      return Paths.login;
    } else if (authState is AuthAuthenticated) {
      final user = authState.user;

      // Admin-only routes
      if (_isAdminRoute(path) && user.role != 'admin') {
        return Paths.home;
      }
      // Staff routes + setting
      if (_isStaffRoute(path) &&
          !(user.role == 'serve' || user.role == 'cashier' || user.role == 'admin')) {
        authCubit.logout();
        return Paths.login;
      }

      if (path == Paths.login) {
        return Paths.home;
      }
    }
    return null;
  },
  routes: [
    GoRoute(path: Paths.login, builder: (context, state) => LoginPage()),
    GoRoute(
      path: Paths.home,
      builder: (context, state) {
        return HomePage();
      },
    ),
    // Staff routes.
    GoRoute(
      path: '/staff_order_history',
      builder: (context, state) {
        return StaffOrderHistoryPage();
      },
    ),

    GoRoute(path: Paths.dashboard, builder: (context, state) => const DashboardPage()),
    GoRoute(path: Paths.userManagement, builder: (context, state) => const UserManagementPage()),
    GoRoute(path: Paths.menuManagement, builder: (context, state) => const MenuManagementPage()),
    GoRoute(path: Paths.tableManagement, builder: (context, state) => const TableManagementPage()),
    GoRoute(path: Paths.feedback, builder: (context, state) => const AdminFeedbackPage()),
    GoRoute(path: Paths.orderHistory, builder: (context, state) => const OrderHistoryPage()),
    GoRoute(
      path: Paths.paymentManagement,
      builder: (context, state) => const PaymentManagementPage(),
    ),
    GoRoute(path: Paths.settings, builder: (context, state) => const SettingsPage()),
    GoRoute(path: Paths.splash, builder: (context, state) => const SplashScreen()),
    GoRoute(
      path: Paths.statistics,
      builder: (context, state) {
        final extra = state.extra;

        return StatisticsDetailPage(stats: extra);
      },
    ),
  ],
  errorBuilder: (context, state) => const NotFoundPage(),
);

bool _isAdminRoute(String path) {
  const adminRoutes = [
    Paths.dashboard,
    Paths.userManagement,
    Paths.menuManagement,
    Paths.tableManagement,
    Paths.feedback,
    Paths.orderHistory,
    Paths.statistics,
  ];
  return adminRoutes.contains(path);
}

bool _isStaffRoute(String path) {
  const staffRoutes = [Paths.home, '/staff_order_history', Paths.settings];
  return staffRoutes.contains(path);
}
