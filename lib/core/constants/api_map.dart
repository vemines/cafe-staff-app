// file: lib/core/constants/api_map.dart
const kCreatedAt = 'createdAt';
const kUpdatedAt = 'updatedAt';

class UserApiMap {
  static const String id = 'id';
  static const String username = 'username';
  static const String fullname = 'fullname';
  static const String role = 'role';
  static const String email = 'email';
  static const String phoneNumber = 'phoneNumber';
  static const String isActive = 'isActive';
}

class CategoryApiMap {
  static const String id = 'id';
  static const String name = 'name';
}

class SubCategoryApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String category = 'category';
  static const String items = 'items';
}

class MenuItemApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String price = 'price';
  static const String subCategory = 'subCategory';
  static const String isAvailable = 'isAvailable';
}

class AreaTableApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String tables = 'tables';
}

class TableApiMap {
  static const String id = 'id';
  static const String tableName = 'tableName';
  static const String status = 'status';
  static const String areaId = 'areaId';
}

class OrderApiMap {
  static const String id = 'id';
  static const String tableId = 'tableId';
  static const String orderStatus = 'orderStatus';
  static const String timestamp = 'timestamp';
  static const String orderItems = 'orderItems';
  static const String createdBy = 'createdBy';
  static const String createdAt = 'createdAt';
  static const String servedBy = 'servedBy';
  static const String servedAt = 'servedAt';
}

class OrderItemApiMap {
  static const String id = 'id';
  static const String orderId = 'orderId';
  static const String menuItemId = 'menuItemId';
  static const String quantity = 'quantity';
  static const String price = 'price';
}

class OrderHistoryApiMap {
  static const String id = 'id';
  static const String orderId = 'orderId';
  static const String tableId = 'tableId';
  static const String paymentMethod = 'paymentMethod';
  static const String servedAt = 'servedAt';
  static const String completedAt = 'completedAt';
  static const String cashierId = 'cashierId';
  static const String orderItems = 'orderItems';
  static const String totalPrice = 'totalPrice';
}

class FeedbackApiMap {
  static const String id = 'id';
  static const String rating = 'rating';
  static const String comment = 'comment';
  static const String timestamp = 'timestamp';
}

class StatisticsApiMap {
  static const String id = 'id';
  static const String date = 'date';
  static const String totalOrders = 'totalOrders';
  static const String totalRevenue = 'totalRevenue';
  static const String paymentMethodSummary = 'paymentMethodSummary';
  static const String ordersByHour = 'ordersByHour';
  static const String averageRating = 'averageRating';
  static const String totalComments = 'totalComments';
  static const String bestSellingItems = 'bestSellingItems';
}

class AggregatedStatisticsApiMap {
  static const String id = 'id';
  static const String year = 'year';
  static const String month = 'month';
  static const String totalOrders = 'totalOrders';
  static const String totalRevenue = 'totalRevenue';
  static const String paymentMethodSummary = 'paymentMethodSummary';
  static const String averageRating = 'averageRating';
  static const String totalComments = 'totalComments';
  static const String bestSellingItems = 'bestSellingItems';
}

class AreaWithTablesApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String tables = 'tables';
}
