import 'package:flutter/foundation.dart';

class FlavorConfig {
  final String name;
  final String baseUrl;
  final bool enableSaveLog;
  final int requestTimeout;

  FlavorConfig({
    required this.name,
    required this.baseUrl,
    required this.enableSaveLog,
    required this.requestTimeout,
  });

  // Helper methods
  // String get someThing => someValue + someValue2;
}

class FlavorValues {
  static final dev = FlavorConfig(
    name: 'Developer',
    baseUrl: kIsWeb ? 'http://localhost:3000' : 'http://10.0.2.2:3000',
    enableSaveLog: true,
    requestTimeout: 10,
  );

  static final staging = FlavorConfig(
    name: 'Staging',
    baseUrl: 'http://localhost:3001/api/v1',
    enableSaveLog: true,
    requestTimeout: 10,
  );

  static final prod = FlavorConfig(
    name: 'Production',
    baseUrl: 'http://localhost:3002/api/v1',
    enableSaveLog: false,
    requestTimeout: 10,
  );
}
