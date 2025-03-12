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
  static String areaTables = '/areaTables';
  static String singleAreaTable(String id) => '$areaTables/$id';
  static String tables = '/tables';
  static String singleTable(String id) => '$tables/$id';
  static String tableStatuses = '/table-statuses';

  // Orders
  static String orders = '/orders';
  static String singleOrder(String id) => '$orders/$id';

  // Order History
  static String orderHistory = '/orderHistory';
  static String singleOrderHistory(String id) => '$orderHistory/$id';

  // Feedback
  static String feedback = '/feedback';
  static String singleFeedback(String id) => '$feedback/$id';

  // Statistics
  static String statistics = '/statistics';
  static String singleStatistic(String id) => '$statistics/$id';
}
