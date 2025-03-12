// usage: FlavorService.instance.config.name
// usage: FlavorService.instance.config.someThing

import '../configs/flavor_config.dart';

enum Flavor { dev, staging, prod }

class FlavorService {
  final Flavor flavor;
  final FlavorConfig config;

  FlavorService._({required this.flavor, required this.config});

  static FlavorService? _instance;

  static FlavorService get instance {
    if (_instance == null) {
      throw Exception('FlavorService not initialized. Call FlavorService.initialize() first.');
    }
    return _instance!;
  }

  static void initialize(Flavor flavor) {
    if (_instance != null) return;

    FlavorConfig config;
    switch (flavor) {
      case Flavor.dev:
        config = FlavorValues.dev;
        break;
      case Flavor.staging:
        config = FlavorValues.staging;
        break;
      case Flavor.prod:
        config = FlavorValues.prod;
        break;
    }

    _instance = FlavorService._(flavor: flavor, config: config);
  }
}
