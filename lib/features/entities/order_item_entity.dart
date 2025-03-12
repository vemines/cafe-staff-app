import 'package:equatable/equatable.dart';

class OrderItemEntity extends Equatable {
  final String id;
  final String orderId;
  final String menuItemId;
  final int quantity;
  final double price;

  const OrderItemEntity({
    required this.id,
    required this.orderId,
    required this.menuItemId,
    required this.quantity,
    required this.price,
  });

  @override
  List<Object?> get props => [id, orderId, menuItemId, quantity, price];

  OrderItemEntity copyWith({
    String? id,
    String? orderId,
    String? menuItemId,
    int? quantity,
    double? price,
  }) {
    return OrderItemEntity(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      menuItemId: menuItemId ?? this.menuItemId,
      quantity: quantity ?? this.quantity,
      price: price ?? this.price,
    );
  }
}
