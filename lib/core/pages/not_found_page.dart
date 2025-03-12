import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../app/routes.dart';

class NotFoundPage extends StatelessWidget {
  const NotFoundPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Oops! The page you're looking for doesn't exist.",
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: () => context.go(Paths.home),
              style: FilledButton.styleFrom(padding: EdgeInsets.all(10)),
              child: const Text('Go to Home'),
            ),
          ],
        ),
      ),
    );
  }
}
