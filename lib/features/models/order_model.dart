import '/core/constants/api_map.dart';
import '/core/utils/parse_utils.dart';
import '../entities/order_entity.dart';
import '../entities/order_item_entity.dart';
import 'order_item_model.dart';

class OrderModel extends OrderEntity {
  const OrderModel({
    required super.id,
    required super.tableId,
    required super.orderItems,
    required super.createdBy,
    required super.createdAt,
    required super.servedBy,
    required super.servedAt,
    required super.totalPrice,
  });

  factory OrderModel.fromJson(Map<String, dynamic> json) {
    return OrderModel(
      id: json[OrderApiMap.id] as String,
      tableId: json[OrderApiMap.tableId] as String,
      orderItems:
          (json[OrderApiMap.orderItems] as List)
              .map((item) => OrderItemModel.fromJson(item))
              .toList(),
      createdBy: json[OrderApiMap.createdBy] as String?,
      createdAt: dateParseNullAble(json[OrderApiMap.createdAt]),
      servedBy: json[OrderApiMap.servedBy] as String?,
      servedAt: dateParseNullAble(json[OrderApiMap.servedAt]),
      totalPrice: doubleParse(json[OrderApiMap.totalPrice]),
    );
  }
  factory OrderModel.fromEntity(OrderEntity entity) {
    return OrderModel(
      id: entity.id,
      tableId: entity.tableId,
      orderItems: entity.orderItems.map((e) => OrderItemModel.fromEntity(e)).toList(),
      createdBy: entity.createdBy,
      createdAt: entity.createdAt,
      servedBy: entity.servedBy,
      servedAt: entity.servedAt,
      totalPrice: entity.totalPrice,
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
    double? totalPrice,
  }) {
    return OrderModel(
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

  Map<String, dynamic> toJson() {
    return {
      OrderApiMap.id: id,
      OrderApiMap.tableId: tableId,
      OrderApiMap.orderItems: orderItems.map((item) => (item as OrderItemModel).toJson()).toList(),
      OrderApiMap.createdBy: createdBy,
      OrderApiMap.createdAt: createdAt?.toIso8601String(),
      OrderApiMap.servedBy: servedBy,
      OrderApiMap.servedAt: servedAt?.toIso8601String(),
      OrderApiMap.totalPrice: totalPrice,
    };
  }
}
