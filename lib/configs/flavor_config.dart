import 'package:flutter/foundation.dart';

class FlavorConfig {
  final String name;
  final String baseUrl;
  final int requestTimeout;

  FlavorConfig({required this.name, required this.baseUrl, required this.requestTimeout});
}

class FlavorValues {
  static final dev = FlavorConfig(
    name: 'Developer',
    baseUrl: kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000',
    requestTimeout: 30000,
  );

  static final staging = FlavorConfig(
    name: 'Staging',
    baseUrl: 'url staging backend',
    requestTimeout: 30000,
  );

  static final prod = FlavorConfig(
    name: 'Production',
    baseUrl: 'url production backend',
    requestTimeout: 30000,
  );
}
