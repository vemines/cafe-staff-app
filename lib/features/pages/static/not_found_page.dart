import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '/app/locale.dart';
import '/core/extensions/num_extensions.dart';
import '../../../app/paths.dart';
import '../../../injection_container.dart';
import '../../blocs/auth/auth_cubit.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Image.asset('images/404.png')),
              Center(child: _content(context)),
            ],
          ),
        ),
      ),
    );
  }

  Column _content(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          context.tr(I18nKeys.pageNotFound),
          style: const TextStyle(fontSize: 24, letterSpacing: 1, fontWeight: FontWeight.w700),
        ),
        Text(
          context.tr(I18nKeys.pageNotFoundMessage),
          style: const TextStyle(fontSize: 16, letterSpacing: 1, fontWeight: FontWeight.w500),
          textAlign: TextAlign.center,
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 16),
          child: InkWell(
            onTap: () {
              final authState = sl<AuthCubit>().state;
              if (authState is AuthAuthenticated) {
                final user = authState.user;
                if (user.role == 'admin') {
                  context.go(Paths.dashboard);
                } else if (user.role == 'serve' || user.role == 'cashier') {
                  context.go(Paths.home);
                } else {
                  context.go(Paths.login);
                }
              } else {
                context.go(Paths.login);
              }
            },
            child: Container(
              decoration: BoxDecoration(borderRadius: 10.borderRadius, color: Colors.blue),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 40),
                child: Text(
                  context.tr(I18nKeys.goHome).toUpperCase(),
                  style: const TextStyle(
                    fontSize: 18,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
