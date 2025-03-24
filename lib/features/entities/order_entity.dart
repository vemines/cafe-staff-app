import 'package:equatable/equatable.dart';

import 'order_item_entity.dart';

class OrderEntity extends Equatable {
  final String id;
  final String tableId;
  final List<OrderItemEntity> orderItems;
  final double totalPrice;
  final String? createdBy;
  final DateTime? createdAt;
  final String? servedBy;
  final DateTime? servedAt;

  const OrderEntity({
    required this.id,
    required this.tableId,
    required this.orderItems,
    required this.totalPrice,
    this.createdBy,
    this.createdAt,
    this.servedBy,
    this.servedAt,
  });

  @override
  List<Object?> get props => [
    id,
    tableId,
    orderItems,
    createdBy,
    createdAt,
    servedBy,
    servedAt,
    totalPrice,
  ];

  OrderEntity copyWith({
    String? id,
    String? tableId,
    String? orderStatus,
    List<OrderItemEntity>? orderItems,
    String? createdBy,
    DateTime? createdAt,
    String? servedBy,
    DateTime? servedAt,
    double? totalPrice,
  }) {
    return OrderEntity(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      orderItems: orderItems ?? this.orderItems,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      servedBy: servedBy ?? this.servedBy,
      servedAt: servedAt ?? this.servedAt,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }
}
