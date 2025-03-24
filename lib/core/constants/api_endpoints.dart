class ApiEndpoints {
  // Auth
  static String login = '/login';

  // Users
  static String users = '/users';
  static String singleUser(String id) => '$users/$id';

  // Menu
  static String categories = '/categories';
  static String singleCategory(String id) => '$categories/$id';
  static String subcategories = '/subCategories';
  static String singleSubcategory(String id) => '$subcategories/$id';
  static String menuItems = '/menuItems';
  static String singleMenuItem(String id) => '$menuItems/$id';
  static String options = '/options';
  static String singleOption(String id) => '$options/$id';
  static String completeMenu = '/menu';

  // Tables
  static String areas = '/areas';
  static String singleArea(String id) => '$areas/$id';
  static String tables = '/tables';
  static String singleTable(String id) => '$tables/$id';
  static String tableStatuses = '/table-statuses';
  static String areasWithTables = '/areas-with-tables';

  // Payments
  static String payments = '/payments';
  static String singlePayment(String id) => '$payments/$id';

  // Orders
  static String orders = '/orders';
  static String mergeOrder = '/orders/merge-request';
  static String splitOrder = '/orders/split';
  static String approveMergeOrder = '/orders/merge-approve'; //for cashier
  static String rejectMergeOrder = '/orders/merge-reject'; //for cashier
  static String singleOrder(String id) => '$orders/$id';

  // Order History
  static String orderHistory = '/orderHistory';
  static String singleOrderHistory(String id) => '$orderHistory/$id';

  // Feedback
  static String feedback = '/feedback';

  // Statistics
  static String statistics = '/statistics';
  static String todayStatistics = '$statistics/today';
  static String thisWeekStatistics = '$statistics/this-week';
  static String aggregatedStatistics = '/aggregated-statistics';
}
