import '../../core/constants/api_map.dart';
import '../../core/utils/parse_utils.dart';
import '../entities/statistics_entity.dart';

class StatisticsModel extends StatisticsEntity {
  const StatisticsModel({
    required super.id,
    required super.date,
    required super.totalOrders,
    required super.totalRevenue,
    required super.paymentMethodSummary,
    required super.ordersByHour,
    required super.averageRating,
    required super.totalComments,
    required super.bestSellingItems,
  });

  factory StatisticsModel.fromJson(Map<String, dynamic> json) {
    return StatisticsModel(
      id: json[StatisticsApiMap.id] as String,
      date: json[StatisticsApiMap.date] as String,
      totalOrders: intParse(json[StatisticsApiMap.totalOrders]),
      totalRevenue: doubleParse(json[StatisticsApiMap.totalRevenue]),
      paymentMethodSummary:
          (json[StatisticsApiMap.paymentMethodSummary] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, intParse(value)),
          ) ??
          {},
      ordersByHour:
          (json[StatisticsApiMap.ordersByHour] as Map<String, dynamic>?)?.map(
            (key, value) => MapEntry(key, intParse(value)),
          ) ??
          {},
      averageRating: doubleParse(json[StatisticsApiMap.averageRating]),
      totalComments: intParse(json[StatisticsApiMap.totalComments]),
      bestSellingItems:
          (json[StatisticsApiMap.bestSellingItems] as Map<String, dynamic>?)?.map(
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
      paymentMethodSummary: entity.paymentMethodSummary,
      ordersByHour: entity.ordersByHour,
      averageRating: entity.averageRating,
      totalComments: entity.totalComments,
      bestSellingItems: entity.bestSellingItems,
    );
  }
  @override
  StatisticsModel copyWith({
    String? id,
    String? date,
    int? totalOrders,
    double? totalRevenue,
    Map<String, int>? paymentMethodSummary,
    Map<String, int>? ordersByHour,
    double? averageRating,
    int? totalComments,
    Map<String, int>? bestSellingItems,
  }) {
    return StatisticsModel(
      id: id ?? this.id,
      date: date ?? this.date,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      paymentMethodSummary: paymentMethodSummary ?? this.paymentMethodSummary,
      ordersByHour: ordersByHour ?? this.ordersByHour,
      averageRating: averageRating ?? this.averageRating,
      totalComments: totalComments ?? this.totalComments,
      bestSellingItems: bestSellingItems ?? this.bestSellingItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      StatisticsApiMap.id: id,
      StatisticsApiMap.date: date,
      StatisticsApiMap.totalOrders: totalOrders,
      StatisticsApiMap.totalRevenue: totalRevenue,
      StatisticsApiMap.paymentMethodSummary: paymentMethodSummary,
      StatisticsApiMap.ordersByHour: ordersByHour,
      StatisticsApiMap.averageRating: averageRating,
      StatisticsApiMap.totalComments: totalComments,
      StatisticsApiMap.bestSellingItems: bestSellingItems,
    };
  }
}
