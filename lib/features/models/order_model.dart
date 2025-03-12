import '../../core/constants/api_map.dart';
import '../../core/utils/parse_utils.dart';
import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.tableId,
    required super.orderStatus,
    required super.timestamp,
    required super.orderItems,
    super.createdBy,
    super.createdAt,
    super.servedBy,
    super.servedAt,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json[OrderApiMap.id] as String,
      tableId: json[OrderApiMap.tableId] as String,
      orderStatus: json[OrderApiMap.orderStatus] as String,
      timestamp: dateParse(json[OrderApiMap.timestamp]),
      orderItems:
          (json[OrderApiMap.orderItems] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList(),
      createdBy: json[OrderApiMap.createdBy] as String?,
      createdAt: dateParse(json[OrderApiMap.createdAt]),
      servedBy: json[OrderApiMap.servedBy] as String?,
      servedAt: dateParse(json[OrderApiMap.servedAt]),
    );
  }
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      tableId: entity.tableId,
      orderStatus: entity.orderStatus,
      timestamp: entity.timestamp,
      orderItems: entity.orderItems.map((e) => OrderItemModel.fromEntity(e)).toList(),
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      servedBy: entity.servedBy,
      servedAt: entity.servedAt,
    );
  }

  @override
  OrderModel copyWith({
    String? id,
    String? tableId,
    String? orderStatus,
    DateTime? timestamp,
    List<OrderItemEntity>? orderItems,
    String? createdBy,
    DateTime? createdAt,
    String? servedBy,
    DateTime? servedAt,
  }) {
    return OrderModel(
      id: id ?? this.id,
      tableId: tableId ?? this.tableId,
      orderStatus: orderStatus ?? this.orderStatus,
      timestamp: timestamp ?? this.timestamp,
      orderItems: orderItems ?? this.orderItems,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      servedBy: servedBy ?? this.servedBy,
      servedAt: servedAt ?? this.servedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      OrderApiMap.id: id,
      OrderApiMap.tableId: tableId,
      OrderApiMap.orderStatus: orderStatus,
      OrderApiMap.timestamp: timestamp.toIso8601String(),
      OrderApiMap.orderItems: orderItems.map((item) => (item as OrderItemModel).toJson()).toList(),
      OrderApiMap.createdBy: createdBy,
      OrderApiMap.createdAt: createdAt?.toIso8601String(),
      OrderApiMap.servedBy: servedBy,
      OrderApiMap.servedAt: servedAt?.toIso8601String(),
    };
  }
}
