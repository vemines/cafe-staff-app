import '../../core/constants/api_map.dart';
import '../../core/utils/parse_utils.dart';
import '../entities/order_history_entity.dart';
import '../entities/order_item_entity.dart';
import '../entities/table_entity.dart';
import 'order_item_model.dart';
import 'table_model.dart';

class OrderHistoryModel extends OrderHistoryEntity {
  const OrderHistoryModel({
    required super.id,
    required super.orderId,
    required super.table,
    required super.paymentMethod,
    required super.createdAt,
    required super.servedAt,
    required super.completedAt,
    required super.orderItems,
    required super.cashierId,
    required super.totalPrice,
  });

  factory OrderHistoryModel.fromJson(Map<String, dynamic> json) {
    return OrderHistoryModel(
      id: json[OrderHistoryApiMap.id] as String,
      orderId: json[OrderHistoryApiMap.orderId] as String,
      table: TableModel.fromJson(json[OrderHistoryApiMap.table]),
      paymentMethod: json[OrderHistoryApiMap.paymentMethod] as String,
      createdAt: dateParse(json[kCreatedAt]),
      servedAt: dateParse(json[OrderHistoryApiMap.servedAt]),
      completedAt: dateParse(json[OrderHistoryApiMap.completedAt]),
      orderItems:
          (json[OrderHistoryApiMap.orderItems] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList(),
      cashierId: json[OrderHistoryApiMap.cashierId] as String,
      totalPrice: doubleParse(json[OrderHistoryApiMap.totalPrice]),
    );
  }
  factory OrderHistoryModel.fromEntity(OrderHistoryEntity entity) {
    return OrderHistoryModel(
      id: entity.id,
      orderId: entity.orderId,
      table: entity.table,
      paymentMethod: entity.paymentMethod,
      createdAt: entity.createdAt,
      servedAt: entity.servedAt,
      completedAt: entity.completedAt,
      orderItems: entity.orderItems.map((e) => OrderItemModel.fromEntity(e)).toList(),
      cashierId: entity.cashierId,
      totalPrice: entity.totalPrice,
    );
  }

  @override
  OrderHistoryModel copyWith({
    String? id,
    String? orderId,
    TableEntity? table,
    String? paymentMethod,
    DateTime? createdAt,
    DateTime? servedAt,
    DateTime? completedAt,
    List<OrderItemEntity>? orderItems,
    String? cashierId,
    double? totalPrice,
  }) {
    return OrderHistoryModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      table: table ?? this.table,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      createdAt: createdAt ?? this.createdAt,
      servedAt: servedAt ?? this.servedAt,
      completedAt: completedAt ?? this.completedAt,
      orderItems: orderItems ?? this.orderItems,
      cashierId: cashierId ?? this.cashierId,
      totalPrice: totalPrice ?? this.totalPrice,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      OrderHistoryApiMap.id: id,
      OrderHistoryApiMap.orderId: orderId,
      OrderHistoryApiMap.table: table,
      OrderHistoryApiMap.paymentMethod: paymentMethod,
      kCreatedAt: createdAt.toIso8601String(),
      OrderHistoryApiMap.servedAt: servedAt.toIso8601String(),
      OrderHistoryApiMap.completedAt: completedAt.toIso8601String(),
      OrderHistoryApiMap.orderItems:
          orderItems.map((item) => (item as OrderItemModel).toJson()).toList(),
      OrderHistoryApiMap.cashierId: cashierId,
      OrderHistoryApiMap.totalPrice: totalPrice,
    };
  }
}
