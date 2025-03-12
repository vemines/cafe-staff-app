import '../../core/constants/api_map.dart';
import '../../core/utils/parse_utils.dart';
import '../entities/order_item_entity.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.menuItemId,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json[OrderItemApiMap.id] as String,
      orderId: json[OrderItemApiMap.orderId] as String,
      menuItemId: json[OrderItemApiMap.menuItemId] as String,
      quantity: intParse(json[OrderItemApiMap.quantity]),
      price: doubleParse(json[OrderItemApiMap.price]),
    );
  }
  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      menuItemId: entity.menuItemId,
      quantity: entity.quantity,
      price: entity.price,
    );
  }

  @override
  OrderItemModel copyWith({
    String? id,
    String? orderId,
    String? menuItemId,
    int? quantity,
    double? price,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      OrderItemApiMap.id: id,
      OrderItemApiMap.orderId: orderId,
      OrderItemApiMap.menuItemId: menuItemId,
      OrderItemApiMap.quantity: quantity,
      OrderItemApiMap.price: price,
    };
  }
}
