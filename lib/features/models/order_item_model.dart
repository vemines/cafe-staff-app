import '/core/constants/api_map.dart';
import '/core/utils/parse_utils.dart';
import '../entities/menu_item_entity.dart';
import '../entities/order_item_entity.dart';
import 'menu_item_model.dart';

class OrderItemModel extends OrderItemEntity {
  const OrderItemModel({
    required super.id,
    required super.orderId,
    required super.menuItem,
    required super.quantity,
    required super.price,
  });

  factory OrderItemModel.fromJson(Map<String, dynamic> json) {
    return OrderItemModel(
      id: json[OrderItemApiMap.id] as String,
      orderId: json[OrderItemApiMap.orderId] as String,
      menuItem: MenuItemModel.fromJson(json[OrderItemApiMap.menuItem]),
      quantity: intParse(json[OrderItemApiMap.quantity]),
      price: doubleParse(json[OrderItemApiMap.price]),
    );
  }
  factory OrderItemModel.fromEntity(OrderItemEntity entity) {
    return OrderItemModel(
      id: entity.id,
      orderId: entity.orderId,
      menuItem: entity.menuItem,
      quantity: entity.quantity,
      price: entity.price,
    );
  }

  @override
  OrderItemModel copyWith({
    String? id,
    String? orderId,
    MenuItemEntity? menuItem,
    int? quantity,
    double? price,
  }) {
    return OrderItemModel(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      OrderItemApiMap.id: id,
      OrderItemApiMap.orderId: orderId,
      OrderItemApiMap.menuItem: menuItem,
      OrderItemApiMap.quantity: quantity,
      OrderItemApiMap.price: price,
    };
  }
}
