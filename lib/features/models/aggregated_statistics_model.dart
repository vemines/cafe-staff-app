import '../../core/constants/api_map.dart';
import '../../core/utils/parse_utils.dart';
import '../entities/aggregated_statistics_entity.dart';

class AggregatedStatisticsModel extends AggregatedStatisticsEntity {
  const AggregatedStatisticsModel({
    required super.id,
    required super.year,
    super.month,
    required super.totalOrders,
    required super.totalRevenue,
    required super.paymentMethodSummary,
    required super.averageRating,
    required super.totalComments,
    required super.bestSellingItems,
  });

  factory AggregatedStatisticsModel.fromJson(Map<String, dynamic> json) {
    return AggregatedStatisticsModel(
      id: json[AggregatedStatisticsApiMap.id] as String,
      year: intParse(json[AggregatedStatisticsApiMap.year]),
      month:
          json[AggregatedStatisticsApiMap.month] != null
              ? intParse(json[AggregatedStatisticsApiMap.month])
              : null,
      totalOrders: intParse(json[AggregatedStatisticsApiMap.totalOrders]),
      totalRevenue: doubleParse(json[AggregatedStatisticsApiMap.totalRevenue]),
      paymentMethodSummary:
          ((json[AggregatedStatisticsApiMap.paymentMethodSummary] as Map<String, dynamic>?) ?? {})
              .map((key, value) => MapEntry(key, intParse(value))),
      averageRating: doubleParse(json[AggregatedStatisticsApiMap.averageRating]),
      totalComments: intParse(json[AggregatedStatisticsApiMap.totalComments]),
      bestSellingItems:
          ((json[AggregatedStatisticsApiMap.bestSellingItems] as Map<String, dynamic>?) ?? {}).map(
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
      paymentMethodSummary: entity.paymentMethodSummary,
      averageRating: entity.averageRating,
      totalComments: entity.totalComments,
      bestSellingItems: entity.bestSellingItems,
    );
  }

  @override
  AggregatedStatisticsModel copyWith({
    String? id,
    int? year,
    int? month,
    int? totalOrders,
    double? totalRevenue,
    Map<String, int>? paymentMethodSummary,
    double? averageRating,
    int? totalComments,
    Map<String, int>? bestSellingItems,
  }) {
    return AggregatedStatisticsModel(
      id: id ?? this.id,
      year: year ?? this.year,
      month: month ?? this.month,
      totalOrders: totalOrders ?? this.totalOrders,
      totalRevenue: totalRevenue ?? this.totalRevenue,
      paymentMethodSummary: paymentMethodSummary ?? this.paymentMethodSummary,
      averageRating: averageRating ?? this.averageRating,
      totalComments: totalComments ?? this.totalComments,
      bestSellingItems: bestSellingItems ?? this.bestSellingItems,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      AggregatedStatisticsApiMap.id: id,
      AggregatedStatisticsApiMap.year: year,
      AggregatedStatisticsApiMap.month: month,
      AggregatedStatisticsApiMap.totalOrders: totalOrders,
      AggregatedStatisticsApiMap.totalRevenue: totalRevenue,
      AggregatedStatisticsApiMap.paymentMethodSummary: paymentMethodSummary,
      AggregatedStatisticsApiMap.averageRating: averageRating,
      AggregatedStatisticsApiMap.totalComments: totalComments,
      AggregatedStatisticsApiMap.bestSellingItems: bestSellingItems,
    };
  }
}
