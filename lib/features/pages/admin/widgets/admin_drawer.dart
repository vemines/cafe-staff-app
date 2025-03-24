import 'package:cafe_staff_app/injection_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/app/paths.dart';
import '../../../blocs/auth/auth_cubit.dart';

class AdminDrawer extends StatelessWidget {
  const AdminDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider.value(
      value: sl<AuthCubit>(),
      child: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            BlocBuilder<AuthCubit, AuthState>(
              builder: (context, state) {
                String userName = '';
                String userRole = '';
                if (state is AuthAuthenticated) {
                  userName = state.user.fullname;
                  userRole = state.user.role;
                }
                return UserAccountsDrawerHeader(
                  accountName: Text(userName),
                  accountEmail: Text(userRole),
                  decoration: const BoxDecoration(color: Colors.blue),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.stacked_bar_chart),
              title: const Text('Dashboard'),
              onTap: () {
                context.go(Paths.dashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: const Text('User Management'),
              onTap: () {
                context.go(Paths.userManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: const Text('Menu Management'),
              onTap: () {
                context.go(Paths.menuManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: const Text('Table Management'),
              onTap: () {
                context.go(Paths.tableManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: const Text('Order History'),
              onTap: () {
                context.go(Paths.orderHistory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: const Text('Payment Management'),
              onTap: () {
                context.go(Paths.paymentManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: const Text('Feedback'),
              onTap: () {
                context.go(Paths.feedback);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Settings'),
              onTap: () {
                context.go(Paths.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                context.read<AuthCubit>().logout();
                context.pushReplacement(Paths.login);
              },
            ),
          ],
        ),
      ),
    );
  }
}
