import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/paths.dart';
import '../../../../injection_container.dart';
import '../../../blocs/auth/auth_cubit.dart';

class StaffDrawer extends StatelessWidget {
  const StaffDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Use BlocBuilder to get the current AuthState
    return BlocBuilder<AuthCubit, AuthState>(
      bloc: sl<AuthCubit>(),
      builder: (context, state) {
        String userName = '';
        String userRole = '';

        if (state is AuthAuthenticated) {
          userName = state.user.fullname;
          userRole = state.user.role;
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(userName),
                accountEmail: Text(userRole),
                decoration: const BoxDecoration(color: Colors.blue),
              ),
              ListTile(
                leading: const Icon(Icons.history),
                title: const Text('Order History'),
                onTap: () {
                  context.push('/staff_order_history');
                },
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: const Text('Settings'),
                onTap: () {
                  context.push('/settings');
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
        );
      },
    );
  }
}
