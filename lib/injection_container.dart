import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/cubits/cubits.dart';
import 'app/flavor.dart';
import 'core/network/network_info.dart';
import 'features/blocs/feedback/feedback_cubit.dart';
import 'features/blocs/menu/category_cubit.dart';
import 'features/blocs/menu/complete_menu_cubit.dart';
import 'features/blocs/menu/menu_item_cubit.dart';
import 'features/blocs/menu/sub_category_cubit.dart';
import 'features/blocs/order/order_cubit.dart';
import 'features/blocs/order_history/order_history_cubit.dart';
import 'features/blocs/payment/payment_cubit.dart';
import 'features/blocs/statistics/statistics_cubit.dart';
import 'features/blocs/table/area_table_cubit.dart';
import 'features/blocs/table/area_with_tables_cubit.dart';
import 'features/blocs/table/table_cubit.dart';
import 'features/blocs/user/user_cubit.dart';
import 'features/datasources/auth_local_data_source.dart';
import 'features/datasources/auth_remote_data_source.dart';
import 'features/datasources/feedback_remote_data_source.dart';
import 'features/datasources/menu_remote_data_source.dart';
import 'features/datasources/order_history_remote_data_source.dart';
import 'features/datasources/order_remote_data_source.dart';
import 'features/datasources/payment_remote_data_source.dart';
import 'features/datasources/statistics_remote_data_source.dart';
import 'features/datasources/table_remote_data_source.dart';
import 'features/datasources/user_remote_data_source.dart';
import 'features/repositories/auth_repository.dart';
import 'features/repositories/feedback_repository.dart';
import 'features/repositories/menu_repository.dart';
import 'features/repositories/order_history_repository.dart';
import 'features/repositories/order_repository.dart';
import 'features/repositories/payment_repository.dart';
import 'features/repositories/statistics_repository.dart';
import 'features/repositories/table_repository.dart';
import 'features/repositories/user_repository.dart';
import 'features/usecases/auth/get_logged_user_usecase.dart';
import 'features/usecases/auth/login_usecase.dart';
import 'features/usecases/auth/logout_usecase.dart';
import 'features/usecases/feedback/create_feedback_usecase.dart';
import 'features/usecases/feedback/get_all_feedback_usecase.dart';
import 'features/usecases/menu/create_category_usecase.dart';
import 'features/usecases/menu/create_menu_item_usecase.dart';
import 'features/usecases/menu/create_subcategory_usecase.dart';
import 'features/usecases/menu/delete_category_usecase.dart';
import 'features/usecases/menu/delete_menu_item_usecase.dart';
import 'features/usecases/menu/delete_subcategory_usecase.dart';
import 'features/usecases/menu/get_all_categories_usecase.dart';
import 'features/usecases/menu/get_all_menu_items_usecase.dart';
import 'features/usecases/menu/get_all_subcategories_usecase.dart';
import 'features/usecases/menu/get_complete_menu_usecase.dart';
import 'features/usecases/menu/update_category_usecase.dart';
import 'features/usecases/menu/update_menu_item_usecase.dart';
import 'features/usecases/menu/update_subcategory_usecase.dart';
import 'features/usecases/order/approve_merge_request_usecase.dart';
import 'features/usecases/order/complete_order_usecase.dart';
import 'features/usecases/order/create_merge_request_usecase.dart';
import 'features/usecases/order/create_order_usecase.dart';
import 'features/usecases/order/reject_merge_request_usecase.dart';
import 'features/usecases/order/serve_order_usecase.dart';
import 'features/usecases/order/split_order_usecase.dart';
import 'features/usecases/order/update_order_usecase.dart';
import 'features/usecases/order_history/get_all_order_history_usecase.dart';
import 'features/usecases/payments/create_payment_usecased.dart';
import 'features/usecases/payments/delete_payment_usecase.dart';
import 'features/usecases/payments/get_all_payments_usecase.dart';
import 'features/usecases/payments/update_payment_usecase.dart';
import 'features/usecases/statistics/get_all_aggregated_statistics_usecase.dart';
import 'features/usecases/statistics/get_this_week_statistics_usecase.dart';
import 'features/usecases/statistics/get_today_statistics_usecase.dart';
import 'features/usecases/table/create_area_usecase.dart';
import 'features/usecases/table/create_table_usecase.dart';
import 'features/usecases/table/delete_area_usecase.dart';
import 'features/usecases/table/delete_table_usecase.dart';
import 'features/usecases/table/get_all_area_usecase.dart';
import 'features/usecases/table/get_all_table_usecase.dart';
import 'features/usecases/table/get_areas_with_tables_usecase.dart';
import 'features/usecases/table/update_area_usecase.dart';
import 'features/usecases/table/update_table_usecase.dart';
import 'features/usecases/user/create_user_usecase.dart';
import 'features/usecases/user/delete_user_usecase.dart';
import 'features/usecases/user/get_all_user_usecase.dart';
import 'features/usecases/user/get_user_by_id_usecase.dart';
import 'features/usecases/user/update_user_usecase.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Bloc
  sl.registerFactory(() => FeedbackCubit(createFeedbackUseCase: sl(), getAllFeedbackUseCase: sl()));
  sl.registerFactory(
    () => CategoryCubit(
      getAllCategoriesUseCase: sl(),
      createCategoryUseCase: sl(),
      updateCategoryUseCase: sl(),
      deleteCategoryUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => SubCategoryCubit(
      getAllSubCategoriesUseCase: sl(),
      createSubCategoryUseCase: sl(),
      updateSubCategoryUseCase: sl(),
      deleteSubCategoryUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => MenuItemCubit(
      getAllMenuItemsUseCase: sl(),
      createMenuItemUseCase: sl(),
      updateMenuItemUseCase: sl(),
      deleteMenuItemUseCase: sl(),
    ),
  );
  sl.registerFactory(() => CompleteMenuCubit(getCompleteMenuUseCase: sl()));
  sl.registerFactory(
    () => OrderCubit(
      createOrderUseCase: sl(),
      serveOrderUseCase: sl(),
      completeOrderUseCase: sl(),
      createMergeRequestUseCase: sl(),
      approveMergeRequestUseCase: sl(),
      splitOrderUseCase: sl(),
      rejectMergeRequestUseCase: sl(),
      updateOrderUseCase: sl(),
    ),
  );
  sl.registerFactory(() => OrderHistoryCubit(getAllOrderHistoryUseCase: sl()));
  sl.registerFactory(
    () => StatisticsCubit(
      getAllAggregatedStatisticsUseCase: sl(),
      getTodayStatisticsUseCase: sl(),
      getThisWeekStatisticsUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => AreaCubit(
      createAreaUseCase: sl(),
      updateAreaUseCase: sl(),
      deleteAreaUseCase: sl(),
      getAllAreaUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => TableCubit(
      createTableUseCase: sl(),
      updateTableUseCase: sl(),
      deleteTableUseCase: sl(),
      getAllTablesUseCase: sl(),
    ),
  );
  sl.registerLazySingleton(() => AreaWithTablesCubit(getAreasWithTablesUseCase: sl()));
  sl.registerFactory(
    () => UserCubit(
      getAllUsersUseCase: sl(),
      getUserByIdUseCase: sl(),
      createUserUseCase: sl(),
      updateUserUseCase: sl(),
      deleteUserUseCase: sl(),
    ),
  );
  sl.registerFactory(
    () => PaymentCubit(
      getAllPaymentsUseCase: sl(),
      createPaymentUseCase: sl(),
      updatePaymentUseCase: sl(),
      deletePaymentUseCase: sl(),
    ),
  );

  // Use cases
  sl.registerLazySingleton(() => LoginUseCase(sl()));
  sl.registerLazySingleton(() => LogoutUseCase(sl()));
  sl.registerLazySingleton(() => GetLoggedUserUseCase(sl()));
  sl.registerLazySingleton(() => CreateFeedbackUseCase(sl()));
  sl.registerLazySingleton(() => GetAllFeedbackUseCase(sl()));
  sl.registerLazySingleton(() => GetAllCategoryUseCase(sl()));
  sl.registerLazySingleton(() => CreateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetAllSubCategoryUseCase(sl()));
  sl.registerLazySingleton(() => CreateSubCategoryUseCase(sl()));
  sl.registerLazySingleton(() => UpdateSubCategoryUseCase(sl()));
  sl.registerLazySingleton(() => DeleteSubCategoryUseCase(sl()));
  sl.registerLazySingleton(() => GetAllMenuItemsUseCase(sl()));
  sl.registerLazySingleton(() => CreateMenuItemUsecase(sl()));
  sl.registerLazySingleton(() => UpdateMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => DeleteMenuItemUseCase(sl()));
  sl.registerLazySingleton(() => GetCompleteMenuUseCase(sl()));
  sl.registerLazySingleton(() => CreateOrderUseCase(sl()));
  sl.registerLazySingleton(() => ServeOrderUseCase(sl()));
  sl.registerLazySingleton(() => CompleteOrderUseCase(sl()));
  sl.registerLazySingleton(() => CreateMergeRequestUseCase(sl()));
  sl.registerLazySingleton(() => ApproveMergeRequestUseCase(sl()));
  sl.registerLazySingleton(() => RejectMergeRequestUseCase(sl()));
  sl.registerLazySingleton(() => SplitOrderUseCase(sl()));
  sl.registerLazySingleton(() => GetAllOrderHistoryUseCase(sl()));
  sl.registerLazySingleton(() => GetAllAggregatedStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetTodayStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => GetThisWeekStatisticsUseCase(sl()));
  sl.registerLazySingleton(() => CreateAreaUseCase(sl()));
  sl.registerLazySingleton(() => UpdateAreaUseCase(sl()));
  sl.registerLazySingleton(() => DeleteAreaUseCase(sl()));
  sl.registerLazySingleton(() => GetAllAreaUseCase(sl()));
  sl.registerLazySingleton(() => GetAllTableUseCase(sl()));
  sl.registerLazySingleton(() => CreateTableUseCase(sl()));
  sl.registerLazySingleton(() => UpdateTableUseCase(sl()));
  sl.registerLazySingleton(() => DeleteTableUseCase(sl()));
  sl.registerLazySingleton(() => GetAreasWithTablesUseCase(sl()));
  sl.registerLazySingleton(() => GetAllUserUseCase(sl()));
  sl.registerLazySingleton(() => GetUserByIdUseCase(sl()));
  sl.registerLazySingleton(() => CreateUserUseCase(sl()));
  sl.registerLazySingleton(() => UpdateUserUseCase(sl()));
  sl.registerLazySingleton(() => DeleteUserUseCase(sl()));
  sl.registerLazySingleton(() => GetAllPaymentUseCase(sl()));
  sl.registerLazySingleton(() => CreatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => UpdatePaymentUseCase(sl()));
  sl.registerLazySingleton(() => DeletePaymentUseCase(sl()));
  sl.registerLazySingleton(() => UpdateOrderUseCase(sl()));

  // Repository
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepositoryImpl(remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<FeedbackRepository>(
    () => FeedbackRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<MenuRepository>(
    () => MenuRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<OrderRepository>(
    () => OrderRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<OrderHistoryRepository>(
    () => OrderHistoryRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<StatisticsRepository>(
    () => StatisticsRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<TableRepository>(
    () => TableRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<UserRepository>(
    () => UserRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );
  sl.registerLazySingleton<PaymentRepository>(
    () => PaymentRepositoryImpl(remoteDataSource: sl(), networkInfo: sl()),
  );

  // Data sources
  sl.registerLazySingleton<AuthRemoteDataSource>(() => AuthRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<AuthLocalDataSource>(() => AuthLocalDataSourceImpl(secureStorage: sl()));
  sl.registerLazySingleton<FeedbackRemoteDataSource>(() => FeedbackRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<MenuRemoteDataSource>(() => MenuRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<OrderRemoteDataSource>(() => OrderRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<OrderHistoryRemoteDataSource>(
    () => OrderHistoryRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<StatisticsRemoteDataSource>(
    () => StatisticsRemoteDataSourceImpl(dio: sl()),
  );
  sl.registerLazySingleton<TableRemoteDataSource>(() => TableRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<UserRemoteDataSource>(() => UserRemoteDataSourceImpl(dio: sl()));
  sl.registerLazySingleton<PaymentRemoteDataSource>(() => PaymentRemoteDataSourceImpl(dio: sl()));

  //! Core
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));

  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton(() => sharedPreferences);
  sl.registerLazySingleton(() => InternetConnection());
  sl.registerLazySingleton(() => const FlutterSecureStorage());

  final flavor = FlavorService.instance.config;
  sl.registerLazySingleton<Dio>(() {
    final dio = Dio();

    dio.options.baseUrl = flavor.baseUrl;
    dio.options.connectTimeout = Duration(milliseconds: flavor.requestTimeout);
    dio.options.receiveTimeout = Duration(milliseconds: flavor.requestTimeout);

    return dio;
  });

  sl.registerSingleton<ThemeCubit>(ThemeCubit());
  sl.registerSingleton<LocaleCubit>(LocaleCubit());
}
