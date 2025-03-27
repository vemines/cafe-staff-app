import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/app/locale.dart';
import '../../../../app/paths.dart';
import '../../../../injection_container.dart';
import '../../../blocs/auth/auth_cubit.dart';

class StaffDrawer extends StatefulWidget {
  const StaffDrawer({super.key});

  @override
  State<StaffDrawer> createState() => _StaffDrawerState();
}

class _StaffDrawerState extends State<StaffDrawer> {
  @override
  Widget build(BuildContext context) {
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
                title: Text(context.tr(I18nKeys.orderHistory)),
                onTap: () => context.push(Paths.staffOrderHistory),
              ),
              ListTile(
                leading: const Icon(Icons.settings),
                title: Text(context.tr(I18nKeys.settings)),
                onTap: () => context.push('/settings'),
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(context.tr(I18nKeys.logout)),
                onTap: () async {
                  await sl<AuthCubit>().logout();

                  if (context.mounted) context.pushReplacement(Paths.login);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
