import 'package:equatable/equatable.dart';

import 'payment_statistic_entity.dart';

class AggregatedStatisticsEntity extends Equatable {
  final String id;
  final int year;
  final int month;
  final int totalOrders;
  final double totalRevenue;
  final Map<String, PaymentStatisticEntity> paymentMethodSummary;
  final double averageRating;
  final int totalFeedbacks;
  final Map<String, int> soldItems;

  const AggregatedStatisticsEntity({
    required this.id,
    required this.year,
    required this.month,
    required this.totalOrders,
    required this.totalRevenue,
    required this.paymentMethodSummary,
    required this.averageRating,
    required this.totalFeedbacks,
    required this.soldItems,
  });

  @override
  List<Object?> get props => [
    id,
    year,
    month,
    totalOrders,
    totalRevenue,
    paymentMethodSummary,
    averageRating,
    totalFeedbacks,
    soldItems,
  ];

  AggregatedStatisticsEntity copyWith({
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
    return AggregatedStatisticsEntity(
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
}
