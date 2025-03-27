const kCreatedAt = 'createdAt';
const kUpdatedAt = 'updatedAt';

class UserApiMap {
  static const String id = 'id';
  static const String username = 'username';
  static const String fullname = 'fullname';
  static const String role = 'role';
  static const String email = 'email';
  static const String password = 'password';
  static const String phoneNumber = 'phoneNumber';
  static const String isActive = 'isActive';
}

class CategoryApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String isActive = 'isActive';
}

class SubCategoryApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String category = 'category';
  static const String items = 'items';
  static const String isActive = 'isActive';
}

class MenuItemApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String price = 'price';
  static const String subCategory = 'subCategory';
  static const String isActive = 'isActive';
}

class AreaApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String tables = 'tables';
}

class TableApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String status = 'status';
  static const String areaId = 'areaId';
  static const String mergedTable = 'mergedTable';
  static const String order = 'order';
}

class OrderApiMap {
  static const String id = 'id';
  static const String tableId = 'tableId';
  static const String orderItems = 'orderItems';
  static const String createdBy = 'createdBy';
  static const String createdAt = 'createdAt';
  static const String servedBy = 'servedBy';
  static const String servedAt = 'servedAt';
  static const String totalPrice = 'totalPrice';
  static const String paymentMethod = 'paymentMethod';
  static const String status = 'status';
}

class OrderItemApiMap {
  static const String id = 'id';
  static const String orderId = 'orderId';
  static const String menuItem = 'menuItem';
  static const String quantity = 'quantity';
  static const String price = 'price';
}

class OrderHistoryApiMap {
  static const String id = 'id';
  static const String orderId = 'orderId';
  static const String tableName = 'tableName';
  static const String paymentMethod = 'paymentMethod';
  static const String servedAt = 'servedAt';
  static const String completedAt = 'completedAt';
  static const String cashierName = 'cashierName';
  static const String orderItems = 'orderItems';
  static const String totalPrice = 'totalPrice';
  static const String createdAt = 'createdAt';
}

class FeedbackApiMap {
  static const String id = 'id';
  static const String rating = 'rating';
  static const String comment = 'comment';
  static const String timestamp = 'timestamp';
  static const String startDate = 'startDate';
  static const String endDate = 'endDate';
}

class StatisticsApiMap {
  static const String id = 'id';
  static const String date = 'date';
  static const String totalOrders = 'totalOrders';
  static const String totalRevenue = 'totalRevenue';
  static const String paymentMethodSummary = 'paymentMethodSummary';
  static const String ordersByHour = 'ordersByHour';
  static const String averageRating = 'averageRating';
  static const String totalFeedbacks = 'totalFeedbacks';
  static const String soldItems = 'soldItems';
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
  static const String soldItems = 'soldItems';
}

class AreaWithTablesApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String tables = 'tables';
}

class PaymentApiMap {
  static const String id = 'id';
  static const String name = 'name';
  static const String isActive = 'isActive';
}

class PaymentStatisticApiMap {
  static const String name = 'name';
  static const String count = 'count';
  static const String totalAmount = 'totalAmount';
}
