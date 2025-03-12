import 'package:flutter/material.dart';

import 'app/app.dart';
import 'app/flavor.dart';
import 'injection_container.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  FlavorService.initialize(Flavor.dev);

  await init();

  runApp(const App());
}
