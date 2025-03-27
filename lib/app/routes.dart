import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../features/pages/staff/order/select_table_page.dart';
import '/features/blocs/auth/auth_cubit.dart';
import '/features/pages/admin/dashboard/dashboard_page.dart';
import '/features/pages/admin/dashboard/statistics_detail_page.dart';
import '/features/pages/admin/feedback/admin_feedback_page.dart';
import '/features/pages/admin/menu_management/menu_management_page.dart';
import '/features/pages/admin/order_history/order_history_page.dart';
import '/features/pages/admin/payment_management/payment_management_page.dart';
import '/features/pages/admin/table_management/table_management_page.dart';
import '/features/pages/admin/user_management/user_management_page.dart';
import '/features/pages/auth/login_page.dart';
import '/features/pages/settings/settings_page.dart';
import '/features/pages/staff/home/home_page.dart';
import '/features/pages/staff/order_history/order_history_page.dart';
import '/features/pages/static/not_found_page.dart';
import '/features/pages/static/splash.dart';
import '/injection_container.dart';
import '../features/entities/table_entity.dart';
import '../features/pages/staff/order/order_page.dart';
import 'paths.dart';

final GlobalKey<NavigatorState> _rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

final routes = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Paths.splash,
  redirect: (context, state) {
    final authCubit = sl<AuthCubit>();
    final authState = authCubit.state;
    final path = state.uri.path;

    final isLoggedIn = authState is AuthAuthenticated;

    if (path == Paths.splash) return null;

    if (!isLoggedIn) return Paths.login;

    if (isLoggedIn) {
      final user = authState.user;
      if (path == Paths.splash || path == Paths.login) {
        if (user.role == 'admin') return Paths.dashboard;
        if (user.role == 'serve' || user.role == 'cashier') return Paths.home;
      }

      if (user.role == 'admin') {
        if (_isStaffRoute(path) && path != Paths.settings) {
          return '/admin-cannot-access-staff';
        }
      } else if (user.role == 'serve' || user.role == 'cashier') {
        if (_isAdminRoute(path)) return Paths.home;
      }
    } else {
      return Paths.login;
    }

    return null;
  },
  routes: [
    GoRoute(path: Paths.login, builder: (context, state) => const LoginPage()),
    GoRoute(path: Paths.splash, builder: (context, state) => const SplashScreen()),
    GoRoute(path: Paths.settings, builder: (context, state) => const SettingsPage()),

    // Staff routes.
    GoRoute(path: Paths.home, builder: (context, state) => const HomePage()),
    GoRoute(
      path: Paths.staffOrderHistory,
      builder: (context, state) => const StaffOrderHistoryPage(),
    ),
    GoRoute(
      path: Paths.order,
      builder: (_, state) {
        final extra = state.extra;
        if (extra is TableEntity) return OrderPage(table: extra);

        return const NotFoundPage();
      },
    ),
    GoRoute(
      path: Paths.selectTable,
      builder: (_, state) {
        final extra = state.extra;
        if (extra is bool) return SelectTablePage(isSplit: extra);

        return const NotFoundPage();
      },
    ),

    // Admin route
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
    GoRoute(
      path: Paths.statistics,
      builder: (_, state) {
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
    Paths.paymentManagement,
    Paths.statistics,
  ];
  return adminRoutes.contains(path);
}

bool _isStaffRoute(String path) {
  const staffRoutes = [Paths.home, Paths.staffOrderHistory, Paths.settings];
  return staffRoutes.contains(path);
}
