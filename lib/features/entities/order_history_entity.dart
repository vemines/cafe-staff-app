import 'package:equatable/equatable.dart';

import 'order_item_entity.dart';

class OrderHistoryEntity extends Equatable {
  final String id;
  final String orderId;
  final String tableId;
  final String paymentMethod;
  final DateTime createdAt;
  final DateTime servedAt;
  final DateTime completedAt;
  final List<OrderItemEntity> orderItems;
  final String cashierId;
  final double totalPrice;

  const OrderHistoryEntity({
    required this.id,
    required this.orderId,
    required this.tableId,
    required this.paymentMethod,
    required this.createdAt,
    required this.servedAt,
    required this.completedAt,
    required this.orderItems,
    required this.cashierId,
    required this.totalPrice, // Added totalPrice
  });

  @override
  List<Object?> get props => [
    id,
    orderId,
    tableId,
    paymentMethod,
    createdAt,
    servedAt,
    completedAt,
    orderItems,
    cashierId,
    totalPrice,
  ];

  OrderHistoryEntity copyWith({
    String? id,
    String? orderId,
    String? tableId,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? servedAt,
    DateTime? completedAt,
    List<OrderItemEntity>? orderItems,
    String? cashierId,
    double? totalPrice,
  }) {
    return OrderHistoryEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      tableId: tableId ?? this.tableId,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      servedAt: servedAt ?? this.servedAt,
      completedAt: completedAt ?? this.completedAt,
      orderItems: orderItems ?? this.orderItems,
      cashierId: cashierId ?? this.cashierId,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
