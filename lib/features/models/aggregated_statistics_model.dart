import '/core/constants/api_map.dart';
import '/core/utils/parse_utils.dart';
import '../entities/aggregated_statistics_entity.dart';
import '../entities/payment_statistic_entity.dart';
import 'payment_statistic_model.dart';

class AggregatedStatisticsModel extends AggregatedStatisticsEntity {
  const AggregatedStatisticsModel({
    required super.id,
    required super.year,
    required super.month,
    required super.totalOrders,
    required super.totalRevenue,
    required super.paymentMethodSummary,
    required super.averageRating,
    required super.totalFeedbacks,
    required super.soldItems,
  });

  factory AggregatedStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AggregatedStatisticsModel(
      id: json[AggregatedStatisticsApiMap.id] as String,
      year: intParse(json[AggregatedStatisticsApiMap.year]),
      month: intParse(json[AggregatedStatisticsApiMap.month]),
      totalOrders: intParse(json[AggregatedStatisticsApiMap.totalOrders]),
      totalRevenue: doubleParse(json[AggregatedStatisticsApiMap.totalRevenue]),
      paymentMethodSummary:
          ((json[AggregatedStatisticsApiMap.paymentMethodSummary] as Map<String, dynamic>?) ?? {})
              .map((key, value) => MapEntry(key, PaymentStatisticModel.fromJson(value))),
      averageRating: doubleParse(json[AggregatedStatisticsApiMap.averageRating]),
      totalFeedbacks: intParse(json[AggregatedStatisticsApiMap.totalComments]),
      soldItems: ((json[AggregatedStatisticsApiMap.soldItems] as Map<String, dynamic>?) ?? {}).map(
        (key, value) => MapEntry(key, intParse(value)),
      ),
    );
  }

  factory AggregatedStatisticsModel.fromEntity(AggregatedStatisticsEntity entity) {
    return AggregatedStatisticsModel(
      id: entity.id,
      year: entity.year,
      month: entity.month,
      totalOrders: entity.totalOrders,
      totalRevenue: entity.totalRevenue,
      paymentMethodSummary: entity.paymentMethodSummary.map(
        (key, value) => MapEntry(key, PaymentStatisticModel.fromEntity(value)),
      ),
      averageRating: entity.averageRating,
      totalFeedbacks: entity.totalFeedbacks,
      soldItems: entity.soldItems,
    );
  }

  @override
  AggregatedStatisticsModel copyWith({
    String? id,
    int? year,
    int? month,
    int? totalOrders,
    double? totalRevenue,
    Map<String, PaymentStatisticEntity>? paymentMethodSummary,
    double? averageRating,
    int? totalFeedbacks,
    Map<String, int>? soldItems,
  }) {
    return AggregatedStatisticsModel(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      paymentMethodSummary: paymentMethodSummary ?? this.paymentMethodSummary,
      averageRating: averageRating ?? this.averageRating,
      totalFeedbacks: totalFeedbacks ?? this.totalFeedbacks,
      soldItems: soldItems ?? this.soldItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      AggregatedStatisticsApiMap.id: id,
      AggregatedStatisticsApiMap.year: year,
      AggregatedStatisticsApiMap.month: month,
      AggregatedStatisticsApiMap.totalOrders: totalOrders,
      AggregatedStatisticsApiMap.totalRevenue: totalRevenue,
      AggregatedStatisticsApiMap.paymentMethodSummary: paymentMethodSummary.map(
        (key, value) => MapEntry(key, (value as PaymentStatisticModel).toJson()),
      ),
      AggregatedStatisticsApiMap.averageRating: averageRating,
      AggregatedStatisticsApiMap.totalComments: totalFeedbacks,
      AggregatedStatisticsApiMap.soldItems: soldItems,
    };
  }
}
