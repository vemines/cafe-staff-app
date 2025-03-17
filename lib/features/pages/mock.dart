import 'dart:math';

import 'package:cafe_staff_app/core/constants/enum.dart';
import 'package:cafe_staff_app/features/entities/aggregated_statistics_entity.dart';
import 'package:cafe_staff_app/features/entities/area_table_entity.dart';
import 'package:cafe_staff_app/features/entities/area_with_table_entity.dart';
import 'package:cafe_staff_app/features/entities/category_entity.dart';
import 'package:cafe_staff_app/features/entities/feedback_entity.dart';
import 'package:cafe_staff_app/features/entities/menu_item_entity.dart';
import 'package:cafe_staff_app/features/entities/order_entity.dart';
import 'package:cafe_staff_app/features/entities/order_history_entity.dart';
import 'package:cafe_staff_app/features/entities/order_item_entity.dart';
import 'package:cafe_staff_app/features/entities/statistics_entity.dart';
import 'package:cafe_staff_app/features/entities/sub_category_entity.dart';
import 'package:cafe_staff_app/features/entities/table_entity.dart';
import 'package:cafe_staff_app/features/entities/user_entity.dart';

class MockData {
  static final Random _random = Random();

  // --- Counters ---
  static int _subCategoryCounter = 1;
  static int _menuItemCounter = 1;
  static int _tableCounter = 1;
  static int _areaCounter = 1;
  static int _orderCounter = 1;
  static int _orderItemCounter = 1;
  static int _orderHistoryCounter = 1;
  static int _userCounter = 1;
  static int _feedbackCounter = 1;
  static int _statisticsCounter = 1;

  static String generateSubCategoryId() => 'subcat_${_subCategoryCounter++}';
  static String generateMenuItemId() => 'menu_${_menuItemCounter++}';
  static String generateTableId() => 'table_${_tableCounter++}';
  static String generateAreaId() => 'area_${_areaCounter++}';
  static String generateOrderId() => 'order_${_orderCounter++}';
  static String generateOrderItemId() => 'order_item_${_orderItemCounter++}';
  static String generateOrderHistoryId() => 'history_${_orderHistoryCounter++}';
  static String generateUserId() => 'user_${_userCounter++}';
  static String generateFeedbackId() => 'feedback_${_feedbackCounter++}';
  static String generateStatisticsId() => 'statistics_${_statisticsCounter++}';

  static void resetCounters() {
    _subCategoryCounter = 1;
    _menuItemCounter = 1;
    _tableCounter = 1;
    _areaCounter = 1;
    _orderCounter = 1;
    _orderItemCounter = 1;
    _orderHistoryCounter = 1;
    _userCounter = 1;
    _feedbackCounter = 1;
    _statisticsCounter = 1;
  }

  // --- Utility Functions ---
  static int weightedRandom(List<double> weights, [int? max]) {
    max ??= weights.length;
    double sum = weights.reduce((a, b) => a + b);
    double rand = _random.nextDouble() * sum;
    double cumulative = 0.0;
    for (int i = 0; i < max; i++) {
      cumulative += weights[i];
      if (rand < cumulative) {
        return i;
      }
    }
    return max - 1;
  }

  // --- Data Generation Functions ---
  static List<CategoryEntity> generateCategories() {
    final List<String> categoryNames = ['Food', 'Drinks', 'Snacks', 'Desserts'];

    return List.generate(categoryNames.length, (index) {
      return CategoryEntity(
        id: 'cat_${index + 1}', // Simple IDs for categories
        name: categoryNames[index],
      );
    });
  }

  static List<SubCategoryEntity> generateSubCategories(List<CategoryEntity> categories) {
    final List<SubCategoryEntity> subCategories = [];
    final List<String> subCategoryNames = [
      'Appetizers',
      'Salads',
      'Burgers',
      'Pasta',
      'Steaks',
      'Asian Fusion',
      'Desserts',
      'Beverages',
    ];

    for (final category in categories) {
      final subCount = 2 + _random.nextInt(3); //2-4 sub per category
      for (int i = 0; i < subCount; i++) {
        final subCategoryName =
            subCategoryNames[_random.nextInt(subCategoryNames.length)]; // Random name
        subCategories.add(
          SubCategoryEntity(
            id: generateSubCategoryId(),
            name: subCategoryName,
            category: category.id, // Use category ID
            items: [], // Filled later by menu items
          ),
        );
      }
    }
    return subCategories;
  }

  static List<MenuItemEntity> generateMenuItems(List<SubCategoryEntity> subCategories) {
    final List<MenuItemEntity> menuItems = [];
    final List<String> firstWords = [
      'Spicy',
      'Grilled',
      'Fresh',
      'Creamy',
      'Crispy',
      'Savory',
      'Sweet',
      'Hot',
      'Cold',
      'Zesty',
      'Tangy',
      'Rich',
      'Light',
      'Hearty',
      'Exotic',
    ];
    final List<String> secondWords = [
      'Wings',
      'Salad',
      'Burger',
      'Pasta',
      'Steak',
      'Soup',
      'Wrap',
      'Tacos',
      'Fries',
      'Rice',
      'Noodles',
      'Bread',
      'Cake',
      'Pie',
      'Drink',
    ];

    for (final subCategory in subCategories) {
      final itemCount = 5 + _random.nextInt(6);
      final Set<String> usedNames = {}; // Track used names

      for (int i = 0; i < itemCount; i++) {
        String name;
        do {
          final firstWord = firstWords[_random.nextInt(firstWords.length)];
          final secondWord = secondWords[_random.nextInt(secondWords.length)];
          name = '$firstWord $secondWord';
        } while (usedNames.contains(name));
        usedNames.add(name);

        final price = 5.0 + (_random.nextDouble() * 15.0); // Prices from 5 to 20
        final menuItemId = generateMenuItemId();
        final menuItem = MenuItemEntity(
          id: menuItemId,
          name: name,
          price: double.parse(price.toStringAsFixed(2)),
          subCategory: subCategory.id, // Assign subCategory ID
          isAvailable: _random.nextBool(),
        );
        menuItems.add(menuItem);
        subCategory.items.add(menuItemId); // Add to subcategory
      }
    }
    return menuItems;
  }

  static List<AreaTableEntity> generateAreas() {
    final List<String> areaNames = [
      'Main Dining',
      'Outdoor Patio',
      'Lounge Area',
      'Private Room',
      'Bar Seating',
    ];
    return List.generate(5, (index) {
      final areaId = generateAreaId();
      return AreaTableEntity(
        id: areaId,
        name: areaNames[index],
        tables: [], // Filled later
      );
    });
  }

  static List<TableEntity> generateTables(List<AreaTableEntity> areas) {
    List<TableEntity> tables = [];

    final List<TableStatus> statusOptions = [
      TableStatus.pending,
      TableStatus.served,
      TableStatus.completed,
    ];

    for (final area in areas) {
      for (int i = 1; i <= 14; i++) {
        final tableId = generateTableId();
        final table = TableEntity(
          id: tableId,
          tableName: 'Table ${_tableCounter - 1}',
          status: statusOptions[_random.nextInt(statusOptions.length)],
          areaId: area.id,
          mergedTable: 1,
          order: null, // Will be filled by generateOrders
        );
        tables.add(table);
        area.tables.add(tableId);
      }
    }
    return tables;
  }

  static List<AreaWithTablesEntity> generateAreaWithTables(
    List<AreaTableEntity> areas,
    List<TableEntity> tables,
  ) {
    final Map<String, TableEntity> tableMap = {for (final table in tables) table.id: table};

    return areas.map((area) {
      final List<TableEntity> areaTables =
          area.tables.map((tableId) => tableMap[tableId]).whereType<TableEntity>().toList();

      return AreaWithTablesEntity(id: area.id, name: area.name, tables: areaTables);
    }).toList();
  }

  static List<UserEntity> generateUsers(int serveCount, int cashierCount, int adminCount) {
    List<UserEntity> users = [];
    final firstNames = [
      'John',
      'Jane',
      'Mike',
      'Sarah',
      'David',
      'Emily',
      'Kevin',
      'Ashley',
      'Brian',
      'Jessica',
    ];
    final lastNames = [
      'Smith',
      'Johnson',
      'Brown',
      'Davis',
      'Wilson',
      "O'Reilly",
      'Garcia',
      'Rodriguez',
      'Lee',
      'Kim',
    ];

    UserEntity createUser(UserRole role, int index) {
      final firstName = firstNames[index % firstNames.length];
      final lastName = lastNames[(index ~/ firstNames.length) % lastNames.length];
      final username = '${firstName.toLowerCase()}_${lastName.toLowerCase()}';
      final createdAt = DateTime.now().subtract(Duration(days: 365 - index * 10));
      final updatedAt = createdAt.add(Duration(days: index * 5));

      return UserEntity(
        id: generateUserId(),
        username: username,
        fullname: '$firstName $lastName',
        role: role.toString().split('.').last,
        email: '$username@example.com',
        phoneNumber: '+1${800 + index}${500 + index}${1000 + index}',
        isActive: _random.nextBool(),
        createdAt: createdAt,
        updatedAt: updatedAt,
      );
    }

    for (int i = 0; i < serveCount; i++) {
      users.add(createUser(UserRole.serve, users.length));
    }
    for (int i = 0; i < cashierCount; i++) {
      users.add(createUser(UserRole.cashier, users.length));
    }
    for (int i = 0; i < adminCount; i++) {
      users.add(createUser(UserRole.admin, users.length));
    }
    return users;
  }

  // Inside mock.dart

  static List<OrderEntity> generateOrders(
    List<TableEntity> tables,
    List<UserEntity> users,
    List<MenuItemEntity> menuItems,
  ) {
    List<OrderEntity> orders = [];
    final servers = users.where((user) => user.role == 'serve').toList();

    // Create createdAt base on current time, and random subtract with duration
    DateTime generateCreatedAt() {
      final now = DateTime.now();
      return now.subtract(
        Duration(
          days: _random.nextInt(5), // Up to 5 days ago
          hours: _random.nextInt(24), // Up to 24 hours ago
          minutes: _random.nextInt(60), // Up to 60 minutes ago
        ),
      );
    }

    for (final table in tables) {
      // Only create orders for tables that are NOT completed
      if (table.status != TableStatus.completed) {
        final orderId = generateOrderId();
        final itemCount = 1 + _random.nextInt(5);
        final menuItemWeights = List.generate(menuItems.length, (index) => 0.1);

        List<OrderItemEntity> orderItems = [];
        for (int j = 0; j < itemCount; j++) {
          final menuItemIndex = weightedRandom(menuItemWeights, menuItems.length);
          final menuItem = menuItems[menuItemIndex];
          final quantity = 1 + _random.nextInt(3);

          orderItems.add(
            OrderItemEntity(
              id: generateOrderItemId(),
              orderId: orderId,
              menuItem: menuItem, //Use entity
              quantity: quantity,
              price: menuItem.price,
            ),
          );
        }

        final server = servers[_random.nextInt(servers.length)];
        // final now = DateTime.now();
        // Generate a random time within the last 4 hours
        // final createdAt = now.subtract(
        //   Duration(hours: _random.nextInt(4), minutes: _random.nextInt(60)),
        // );
        final createdAt = generateCreatedAt();

        double totalPrice = 0.0;
        for (final item in orderItems) {
          totalPrice += item.price * item.quantity;
        }
        totalPrice = double.parse(totalPrice.toStringAsFixed(2));

        final order = OrderEntity(
          id: orderId,
          tableId: table.id,
          timestamp: createdAt, // Use the generated createdAt
          orderItems: orderItems,
          createdBy: server.id,
          createdAt: createdAt, // Use the generated createdAt
          servedBy: null,
          servedAt: null,
          totalPrice: totalPrice,
        );
        orders.add(order);

        // Update the table *in place* using copyWith.  VERY IMPORTANT
        final originalTableIndex = tables.indexWhere((t) => t.id == table.id);
        if (originalTableIndex != -1) {
          tables[originalTableIndex] = table.copyWith(order: order);
        }
      }
    }
    return orders;
  }

  static List<TableEntity> generateTablesOrders(
    List<TableEntity> tables,
    List<UserEntity> users,
    List<MenuItemEntity> menuItems,
  ) {
    // Create createdAt base on current time, and random subtract with duration
    DateTime generateCreatedAt() {
      final now = DateTime.now();
      return now.subtract(
        Duration(
          days: _random.nextInt(5), // Up to 5 days ago
          hours: _random.nextInt(24), // Up to 24 hours ago
          minutes: _random.nextInt(60), // Up to 60 minutes ago
        ),
      );
    }

    List<OrderEntity> orders = [];
    final servers = users.where((user) => user.role == 'serve').toList();

    for (final table in tables) {
      // Only create orders for tables that are NOT completed
      if (table.status != TableStatus.completed) {
        final orderId = generateOrderId();
        final itemCount = 1 + _random.nextInt(5);
        final menuItemWeights = List.generate(menuItems.length, (index) => 0.1);

        List<OrderItemEntity> orderItems = [];
        for (int j = 0; j < itemCount; j++) {
          final menuItemIndex = weightedRandom(menuItemWeights, menuItems.length);
          final menuItem = menuItems[menuItemIndex];
          final quantity = 1 + _random.nextInt(3);

          orderItems.add(
            OrderItemEntity(
              id: generateOrderItemId(),
              orderId: orderId,
              menuItem: menuItem,
              quantity: quantity,
              price: menuItem.price,
            ),
          );
        }

        final server = servers[_random.nextInt(servers.length)];
        // final now = DateTime.now();
        // Generate a random time within the last 4 hours
        // final createdAt = now.subtract(
        //   Duration(hours: _random.nextInt(4), minutes: _random.nextInt(60)),
        // );
        final createdAt = generateCreatedAt();

        double totalPrice = 0.0;
        for (final item in orderItems) {
          totalPrice += item.price * item.quantity;
        }
        totalPrice = double.parse(totalPrice.toStringAsFixed(2));

        final order = OrderEntity(
          id: orderId,
          tableId: table.id,
          timestamp: createdAt, // Use the generated createdAt
          orderItems: orderItems,
          createdBy: server.id,
          createdAt: createdAt, // Use the generated createdAt
          servedBy: null,
          servedAt: null,
          totalPrice: totalPrice,
        );
        orders.add(order);
        // Update the table *in place* using copyWith.  VERY IMPORTANT
        final originalTableIndex = tables.indexWhere((t) => t.id == table.id);
        if (originalTableIndex != -1) {
          tables[originalTableIndex] = table.copyWith(order: order);
        }
      }
    }
    return tables;
  }

  static List<OrderHistoryEntity> generateOrderHistory(
    List<TableEntity> tables,
    List<UserEntity> users,
    List<MenuItemEntity> menuItems,
    int historyCount,
  ) {
    List<OrderHistoryEntity> completedOrders = [];
    final cashiers = users.where((user) => user.role == 'cashier').toList();
    final paymentMethods = ['cash', 'online payment'];

    // Create createdAt base on current time, and random subtract with duration
    DateTime generateCreatedAt() {
      final now = DateTime.now();
      return now.subtract(
        Duration(
          days: _random.nextInt(90), // Up to 90 days ago
          hours: _random.nextInt(24), // Up to 24 hours ago
          minutes: _random.nextInt(60), // Up to 60 minutes ago
        ),
      );
    }

    for (int i = 0; i < historyCount; i++) {
      final orderId = generateOrderHistoryId();
      // final now = DateTime.now();
      // final completedAt = now.subtract(Duration(days: i % 90, hours: i % 24, minutes: i % 60));
      // final servedAt = completedAt.subtract(Duration(minutes: 30 + _random.nextInt(60)));
      // final createdAt = servedAt.subtract(Duration(minutes: 15 + _random.nextInt(30)));
      final createdA = generateCreatedAt();
      final servedAt = createdA.add(Duration(minutes: 15 + _random.nextInt(30)));
      final completedAt = servedAt.add(Duration(minutes: 30 + _random.nextInt(60))); //

      final menuItemWeights = List.generate(menuItems.length, (index) {
        //Simplified
        return 0.1;
      });

      final itemCount = 1 + _random.nextInt(5); // 1 to 5 items
      List<OrderItemEntity> orderItems = [];
      for (int j = 0; j < itemCount; j++) {
        final menuItemIndex = weightedRandom(menuItemWeights, menuItems.length);
        final menuItem = menuItems[menuItemIndex];
        final quantity = 1 + _random.nextInt(3);

        orderItems.add(
          OrderItemEntity(
            id: generateOrderItemId(),
            orderId: orderId,
            menuItem: menuItem,
            quantity: quantity,
            price: menuItem.price,
          ),
        );
      }

      double totalPrice = 0.0;
      for (final item in orderItems) {
        totalPrice += item.price * item.quantity;
      }
      totalPrice = double.parse(totalPrice.toStringAsFixed(2));

      final cashier = cashiers[_random.nextInt(cashiers.length)];
      final table = tables[_random.nextInt(tables.length)]; // Random table

      completedOrders.add(
        OrderHistoryEntity(
          id: orderId,
          orderId: orderId,
          table: TableEntity(
            //Use entity
            id: table.id,
            tableName: table.tableName,
            status: table.status,
            areaId: table.areaId,
            mergedTable: table.mergedTable,
          ),
          paymentMethod: paymentMethods[_random.nextInt(paymentMethods.length)],
          createdAt: createdA,
          servedAt: servedAt,
          completedAt: completedAt,
          orderItems: orderItems,
          cashierId: cashier.id,
          totalPrice: totalPrice, // Include total price
        ),
      );
    }

    return completedOrders;
  }

  static List<FeedbackEntity> generateFeedback(int count) {
    final List<FeedbackEntity> feedbacks = [];
    final comments = [
      'Great food!',
      'Excellent service!',
      'Will come back again.',
      'Good value for money.',
      'Could be better.',
      'Not bad.',
    ];
    // Create createdAt base on current time, and random subtract with duration
    DateTime generateCreatedAt() {
      final now = DateTime.now();
      return now.subtract(
        Duration(
          days: _random.nextInt(365), // Up to 365 days ago
          hours: _random.nextInt(24), // Up to 24 hours ago
          minutes: _random.nextInt(60), // Up to 60 minutes ago
        ),
      );
    }

    for (int i = 0; i < count; i++) {
      final feedbackId = generateFeedbackId();
      // final now = DateTime.now();
      // final createdAt = now.subtract(
      //   Duration(days: 365 - i * 5, minutes: i * 30),
      // ); // Up to one year ago
      final createdAt = generateCreatedAt();
      feedbacks.add(
        FeedbackEntity(
          id: feedbackId,
          rating: 1 + _random.nextInt(5), // Rating between 1 and 5.
          comment: comments[_random.nextInt(comments.length)],
          timestamp: createdAt,
        ),
      );
    }

    return feedbacks;
  }

  static List<StatisticsEntity> generateDailyStatistics(DateTime start, DateTime end) {
    final List<StatisticsEntity> statistics = [];
    final List<OrderHistoryEntity> completedOrders = MockData.completedOrders;

    // Helper function to format DateTime to 'YYYY-MM-DD'
    String formatDate(DateTime date) =>
        "${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}";

    for (DateTime date = start; date.isBefore(end); date = date.add(Duration(days: 1))) {
      // Use formatted date string for comparison
      final String formattedDate = formatDate(date);
      final dailyOrders =
          completedOrders.where((order) => formatDate(order.completedAt) == formattedDate).toList();

      final totalOrders = dailyOrders.length;
      final totalRevenue = dailyOrders.fold<double>(0, (sum, order) => sum + order.totalPrice);
      final paymentMethods = <String, int>{};
      final ordersByHour = <int, int>{};
      for (int i = 0; i < 24; i++) {
        ordersByHour[i] = 0;
      }
      final bestSellingItems = <String, int>{};
      int totalComments = 0;
      double totalRating = 0;
      int ratingCount = 0;

      for (final order in dailyOrders) {
        paymentMethods.update(order.paymentMethod, (value) => value + 1, ifAbsent: () => 1);
        ordersByHour.update(order.completedAt.hour, (value) => value + 1, ifAbsent: () => 1);
        for (final item in order.orderItems) {
          bestSellingItems.update(
            item.menuItem.name,
            (value) => value + item.quantity,
            ifAbsent: () => item.quantity,
          );
        }
      }

      // Filter feedback for the current date using formatted date string
      final dailyFeedback =
          MockData.feedback.where((f) => formatDate(f.timestamp) == formattedDate).toList();

      totalComments = dailyFeedback.length;

      for (final feedback in dailyFeedback) {
        totalRating += feedback.rating;
        ratingCount++;
      }

      final averageRating =
          ratingCount > 0 ? double.parse((totalRating / ratingCount).toStringAsFixed(1)) : 0.0;

      statistics.add(
        StatisticsEntity(
          id: generateStatisticsId(),
          date: date, // Store as DateTime
          totalOrders: totalOrders,
          totalRevenue: totalRevenue,
          paymentMethodSummary: paymentMethods,
          ordersByHour: ordersByHour,
          averageRating: averageRating,
          totalFeedbacks: totalComments,
          bestSellingItems: bestSellingItems,
        ),
      );
    }
    return statistics;
  }

  static List<AggregatedStatisticsEntity> generateMonthlyStatistics() {
    final Map<String, AggregatedStatisticsEntity> aggregated = {};
    final List<StatisticsEntity> dailyStats = MockData.dailyStatistics;

    for (final stat in dailyStats) {
      final date = stat.date; // Already a DateTime
      final yearMonth = '${date.year}-${date.month.toString().padLeft(2, '0')}';

      if (!aggregated.containsKey(yearMonth)) {
        aggregated[yearMonth] = AggregatedStatisticsEntity(
          id: yearMonth, // Keep as YYYY-MM string
          year: date.year,
          month: date.month, // Use the month from DateTime
          totalOrders: 0,
          totalRevenue: 0.0,
          paymentMethodSummary: {},
          averageRating: 0.0,
          totalComments: 0,
          bestSellingItems: {},
        );
      }

      final current = aggregated[yearMonth]!;
      aggregated[yearMonth] = current.copyWith(
        totalOrders: current.totalOrders + stat.totalOrders,
        totalRevenue: current.totalRevenue + stat.totalRevenue,
        totalComments: current.totalComments + stat.totalFeedbacks,
        paymentMethodSummary: _mergeMaps(current.paymentMethodSummary, stat.paymentMethodSummary),
        bestSellingItems: _mergeMaps(current.bestSellingItems, stat.bestSellingItems),
      );

      // Accumulate ratings and counts for averaging *after* summing.
      if (stat.averageRating > 0) {
        // Only consider days with ratings
        if (current.averageRating == 0.0) {
          // Use averageRating field to store sum temporarily.  Kludgy, but works
          aggregated[yearMonth] = current.copyWith(averageRating: stat.averageRating);
        } else {
          aggregated[yearMonth] = current.copyWith(
            averageRating: current.averageRating + stat.averageRating, // Accumulate sum
          );
        }
      }
    }

    // Calculate average rating after summing
    final List<AggregatedStatisticsEntity> result =
        aggregated.values.map((aggStat) {
          final daysWithRatings =
              dailyStats
                  .where(
                    (dailyStat) =>
                        dailyStat.averageRating > 0 &&
                        '${dailyStat.date.year}-${dailyStat.date.month.toString().padLeft(2, '0')}' ==
                            aggStat.id,
                  )
                  .length;

          if (daysWithRatings > 0) {
            return aggStat.copyWith(
              averageRating: double.parse(
                (aggStat.averageRating / daysWithRatings).toStringAsFixed(1),
              ),
            ); // Now divide
          } else {
            return aggStat.copyWith(averageRating: 0.0); // No ratings
          }
        }).toList();

    return result;
  }

  static List<AggregatedStatisticsEntity> generateYearlyStatistics() {
    final Map<int, AggregatedStatisticsEntity> aggregated = {}; // Key is the year
    final monthlyStats =
        MockData.monthlyStatistics; // Make sure this is the list of *monthly* aggregated stats

    for (final stat in monthlyStats) {
      final year = stat.year;

      if (!aggregated.containsKey(year)) {
        aggregated[year] = AggregatedStatisticsEntity(
          id: year.toString(), // Year as ID
          year: year,
          totalOrders: 0,
          totalRevenue: 0.0,
          paymentMethodSummary: {},
          averageRating: 0.0,
          totalComments: 0,
          bestSellingItems: {},
        );
      }

      final current = aggregated[year]!;
      aggregated[year] = current.copyWith(
        totalOrders: current.totalOrders + stat.totalOrders,
        totalRevenue: current.totalRevenue + stat.totalRevenue,
        totalComments: current.totalComments + stat.totalComments,
        paymentMethodSummary: _mergeMaps(current.paymentMethodSummary, stat.paymentMethodSummary),
        bestSellingItems: _mergeMaps(current.bestSellingItems, stat.bestSellingItems),
      );
      if (stat.averageRating > 0) {
        // Similar temporary sum storage
        aggregated[year] = current.copyWith(
          averageRating: current.averageRating + stat.averageRating,
        );
      }
    }

    // Calculate average after summing, similar to monthly
    final List<AggregatedStatisticsEntity> result =
        aggregated.values.map((aggStat) {
          final monthsWithRatings =
              monthlyStats
                  .where(
                    (monthlyStat) =>
                        monthlyStat.averageRating > 0 && monthlyStat.year == aggStat.year,
                  )
                  .length;

          if (monthsWithRatings > 0) {
            return aggStat.copyWith(
              averageRating: double.parse(
                (aggStat.averageRating / monthsWithRatings).toStringAsFixed(1),
              ),
            );
          } else {
            return aggStat.copyWith(averageRating: 0.0);
          }
        }).toList();

    return result;
  }

  static Map<String, int> _mergeMaps(Map<String, int> map1, Map<String, int> map2) {
    final mergedMap = Map<String, int>.from(map1);
    map2.forEach((key, value) {
      mergedMap.update(key, (v) => v + value, ifAbsent: () => value);
    });
    return mergedMap;
  }

  // --- Data Initialization (Called Once) ---
  static final List<CategoryEntity> categories = generateCategories();
  static final List<SubCategoryEntity> subCategories = generateSubCategories(categories);
  static final List<MenuItemEntity> menuItems = generateMenuItems(subCategories);
  static final List<AreaTableEntity> areas = generateAreas();
  static final List<TableEntity> tables = generateTables(areas);
  static final List<UserEntity> staff = generateUsers(5, 2, 1);
  static final List<OrderEntity> orders = generateOrders(tables, staff, menuItems);
  static final List<TableEntity> tablesWithOrder = generateTablesOrders(
    tables,
    staff,
    menuItems,
  ); // Keep for now
  static final List<AreaWithTablesEntity> areaWithTables = generateAreaWithTables(
    areas,
    tablesWithOrder,
  );
  static final List<OrderHistoryEntity> completedOrders = generateOrderHistory(
    tables,
    staff,
    menuItems,
    50,
  );
  static final List<FeedbackEntity> feedback = generateFeedback(
    100,
  ); // Example: 100 feedback entries
  static final List<StatisticsEntity> dailyStatistics = generateDailyStatistics(
    DateTime(2023, 1, 1),
    DateTime.now(),
  );
  static final List<AggregatedStatisticsEntity> monthlyStatistics = generateMonthlyStatistics();
  static final List<AggregatedStatisticsEntity> yearlyStatistics = generateYearlyStatistics();
}

enum UserRole { serve, cashier, admin }
