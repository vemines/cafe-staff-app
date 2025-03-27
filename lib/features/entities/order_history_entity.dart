import 'package:equatable/equatable.dart';

import 'order_item_entity.dart';

class OrderHistoryEntity extends Equatable {
  final String id;
  final String tableName;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime servedAt;
  final DateTime completedAt;
  final List<OrderItemEntity> orderItems;
  final String cashierName;
  final double totalPrice;

  const OrderHistoryEntity({
    required this.id,
    required this.tableName,
    required this.paymentMethod,
    required this.createdAt,
    required this.servedAt,
    required this.completedAt,
    required this.orderItems,
    required this.cashierName,
    required this.totalPrice,
  });

  @override
  List<Object?> get props => [
    id,
    tableName,
    paymentMethod,
    createdAt,
    servedAt,
    completedAt,
    orderItems,
    cashierName,
    totalPrice,
  ];

  OrderHistoryEntity copyWith({
    String? id,
    String? tableName,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? servedAt,
    DateTime? completedAt,
    List<OrderItemEntity>? orderItems,
    String? cashierName,
    double? totalPrice,
  }) {
    return OrderHistoryEntity(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      servedAt: servedAt ?? this.servedAt,
      completedAt: completedAt ?? this.completedAt,
      orderItems: orderItems ?? this.orderItems,
      cashierName: cashierName ?? this.cashierName,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
