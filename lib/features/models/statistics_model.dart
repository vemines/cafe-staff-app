import '/core/constants/api_map.dart';
import '/core/utils/parse_utils.dart';
import '../entities/payment_statistic_entity.dart';
import '../entities/statistics_entity.dart';
import 'payment_statistic_model.dart';

class StatisticsModel extends StatisticsEntity {
  const StatisticsModel({
    required super.id,
    required super.date,
    required super.totalOrders,
    required super.totalRevenue,
    required super.paymentMethodSummary,
    required super.ordersByHour,
    required super.averageRating,
    required super.totalFeedbacks,
    required super.soldItems,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    // print(json[StatisticsApiMap.paymentMethodSummary]);
    return StatisticsModel(
      id: json[StatisticsApiMap.id] as String,
      date: dateParse(json[StatisticsApiMap.date]),
      totalOrders: intParse(json[StatisticsApiMap.totalOrders]),
      totalRevenue: doubleParse(json[StatisticsApiMap.totalRevenue]),
      paymentMethodSummary:
          (json[StatisticsApiMap.paymentMethodSummary] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(
              key, // This is the paymentName
              PaymentStatisticModel.fromJson(value),
            ),
          ) ??
          {},
      ordersByHour:
          (json[StatisticsApiMap.ordersByHour] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(intParse(key), intParse(value)),
          ) ??
          {},
      averageRating: doubleParse(json[StatisticsApiMap.averageRating]),
      totalFeedbacks: intParse(json[StatisticsApiMap.totalFeedbacks]),
      soldItems:
          (json[StatisticsApiMap.soldItems] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, intParse(value)),
          ) ??
          {},
    );
  }

  factory StatisticsModel.fromEntity(StatisticsEntity entity) {
    return StatisticsModel(
      id: entity.id,
      date: entity.date,
      totalOrders: entity.totalOrders,
      totalRevenue: entity.totalRevenue,
      paymentMethodSummary: entity.paymentMethodSummary.map(
        (key, value) => MapEntry(key, PaymentStatisticModel.fromEntity(value)),
      ),
      ordersByHour: entity.ordersByHour,
      averageRating: entity.averageRating,
      totalFeedbacks: entity.totalFeedbacks,
      soldItems: entity.soldItems,
    );
  }

  @override
  StatisticsModel copyWith({
    String? id,
    DateTime? date,
    int? totalOrders,
    double? totalRevenue,
    Map<String, PaymentStatisticEntity>? paymentMethodSummary,
    Map<int, int>? ordersByHour,
    double? averageRating,
    int? totalFeedbacks,
    Map<String, int>? soldItems,
  }) {
    return StatisticsModel(
      id: id ?? this.id,
      date: date ?? this.date,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      paymentMethodSummary: paymentMethodSummary ?? this.paymentMethodSummary,
      ordersByHour: ordersByHour ?? this.ordersByHour,
      averageRating: averageRating ?? this.averageRating,
      totalFeedbacks: totalFeedbacks ?? this.totalFeedbacks,
      soldItems: soldItems ?? this.soldItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      StatisticsApiMap.id: id,
      StatisticsApiMap.date: date.toIso8601String(),
      StatisticsApiMap.totalOrders: totalOrders,
      StatisticsApiMap.totalRevenue: totalRevenue,
      StatisticsApiMap.paymentMethodSummary: paymentMethodSummary.map(
        (key, value) => MapEntry(key, (value as PaymentStatisticModel).toJson()),
      ),
      StatisticsApiMap.ordersByHour: ordersByHour,
      StatisticsApiMap.averageRating: averageRating,
      StatisticsApiMap.totalFeedbacks: totalFeedbacks,
      StatisticsApiMap.soldItems: soldItems,
    };
  }
}
