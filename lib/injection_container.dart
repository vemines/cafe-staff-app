import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/flavor.dart';
import 'core/network/network_info.dart';

final sl = GetIt.instance;

Future<void> init() async {
  //! Features
  // Bloc

  // Use cases

  // Repository

  // Data sources

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnection());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();
    final flavor = FlavorService.instance.config;

    dio.options.baseUrl = flavor.baseUrl;
    dio.options.connectTimeout = Duration(seconds: flavor.requestTimeout);
    dio.options.receiveTimeout = Duration(seconds: flavor.requestTimeout);

    return dio;
  });
}
