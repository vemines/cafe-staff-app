import 'package:equatable/equatable.dart';

class StatisticsEntity extends Equatable {
  final String id;
  final String date;
  final int totalOrders;
  final double totalRevenue;
  final Map<String, int> paymentMethodSummary;
  final Map<String, int> ordersByHour;
  final double averageRating;
  final int totalComments;
  final Map<String, int> bestSellingItems;

  const StatisticsEntity({
    required this.id,
    required this.date,
    required this.totalOrders,
    required this.totalRevenue,
    required this.paymentMethodSummary,
    required this.ordersByHour,
    required this.averageRating,
    required this.totalComments,
    required this.bestSellingItems,
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
    totalComments,
    bestSellingItems,
  ];

  StatisticsEntity copyWith({
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
    return StatisticsEntity(
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
}
