import 'package:equatable/equatable.dart';

class AggregatedStatisticsEntity extends Equatable {
  final String id;
  final int year;
  final int? month;
  final int totalOrders;
  final double totalRevenue;
  final Map<String, int> paymentMethodSummary;
  final double averageRating;
  final int totalComments;
  final Map<String, int> bestSellingItems;

  const AggregatedStatisticsEntity({
    required this.id,
    required this.year,
    this.month,
    required this.totalOrders,
    required this.totalRevenue,
    required this.paymentMethodSummary,
    required this.averageRating,
    required this.totalComments,
    required this.bestSellingItems,
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
    totalComments,
    bestSellingItems,
  ];

  AggregatedStatisticsEntity copyWith({
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
    return AggregatedStatisticsEntity(
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
}
