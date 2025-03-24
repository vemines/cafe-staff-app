import 'package:equatable/equatable.dart';

import 'menu_item_entity.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final MenuItemEntity menuItem;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.menuItem,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [id, orderId, menuItem, quantity, price];

  OrderItemEntity copyWith({
    String? id,
    String? orderId,
    MenuItemEntity? menuItem,
    int? quantity,
    double? price,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItem: menuItem ?? this.menuItem,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
