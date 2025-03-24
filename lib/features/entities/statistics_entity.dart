import 'package:equatable/equatable.dart';

import 'payment_statistic_entity.dart';

class StatisticsEntity extends Equatable {
  final String id;
  final DateTime date;
  final int totalOrders;
  final double totalRevenue;
  final Map<String, PaymentStatisticEntity> paymentMethodSummary;
  final Map<int, int> ordersByHour;
  final double averageRating;
  final int totalFeedbacks;
  final Map<String, int> soldItems;

  const StatisticsEntity({
    required this.id,
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.paymentMethodSummary,
    required this.ordersByHour,
    required this.averageRating,
    required this.totalFeedbacks,
    required this.soldItems,
  });

  @override
  List<Object?> get props => [
    id,
    date,
    totalOrders,
    totalRevenue,
    paymentMethodSummary,
    ordersByHour,
    averageRating,
    totalFeedbacks,
    soldItems,
  ];

  StatisticsEntity copyWith({
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
    return StatisticsEntity(
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
}
