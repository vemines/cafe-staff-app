import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/app/locale.dart';
import '/app/paths.dart';
import '../../../../injection_container.dart';
import '../../../blocs/auth/auth_cubit.dart';

class AdminDrawer extends StatefulWidget {
  const AdminDrawer({super.key});

  @override
  State<AdminDrawer> createState() => _AdminDrawerState();
}

class _AdminDrawerState extends State<AdminDrawer> {
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
              title: Text(context.tr(I18nKeys.dashboard)),
              onTap: () {
                context.go(Paths.dashboard);
              },
            ),
            ListTile(
              leading: const Icon(Icons.people),
              title: Text(context.tr(I18nKeys.userManagement)),
              onTap: () {
                context.go(Paths.userManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.restaurant_menu),
              title: Text(context.tr(I18nKeys.menuManagement)),
              onTap: () {
                context.go(Paths.menuManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.table_chart),
              title: Text(context.tr(I18nKeys.tableManagement)),
              onTap: () {
                context.go(Paths.tableManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.history),
              title: Text(context.tr(I18nKeys.orderHistory)),
              onTap: () {
                context.go(Paths.orderHistory);
              },
            ),
            ListTile(
              leading: const Icon(Icons.payment),
              title: Text(context.tr(I18nKeys.paymentManagement)),
              onTap: () {
                context.go(Paths.paymentManagement);
              },
            ),
            ListTile(
              leading: const Icon(Icons.star),
              title: Text(context.tr(I18nKeys.feedback)),
              onTap: () {
                context.go(Paths.feedback);
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: Text(context.tr(I18nKeys.settings)),
              onTap: () {
                context.go(Paths.settings);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(context.tr(I18nKeys.logout)),
              onTap: () {
                sl<AuthCubit>().logout().then((_) {
                  if (context.mounted) context.pushReplacement(Paths.login);
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}
