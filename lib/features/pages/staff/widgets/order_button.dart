// lib/features/pages/staff/widgets/order_button.dart
import 'package:cafe_staff_app/features/entities/menu_item_entity.dart';
import 'package:flutter/material.dart';
import '/core/extensions/num_extension.dart';

final _infoStyle = const TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.black);

class OrderButton extends StatelessWidget {
  // Now a StatelessWidget
  final MenuItemEntity menuItem;
  final int quantity; // Receive the quantity directly
  final VoidCallback onIncrement;
  final VoidCallback onDecrement;

  const OrderButton({
    super.key,
    required this.menuItem,
    required this.quantity,
    required this.onIncrement,
    required this.onDecrement,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      decoration: BoxDecoration(borderRadius: 8.radius, color: Colors.blueAccent),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          GestureDetector(
            onTap: onIncrement, // Directly call the callbacks
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Text(menuItem.name, style: _infoStyle.copyWith(color: Colors.white)),
                  if (quantity > 0) ...[
                    const SizedBox(width: 4),
                    Text('($quantity)', style: _infoStyle.copyWith(color: Colors.white)),
                  ],
                ],
              ),
            ),
          ),
          if (quantity > 0) ...[
            SizedBox(
              width: 1,
              child: const VerticalDivider(color: Colors.grey, thickness: 1, width: 20),
            ),
            GestureDetector(
              onTap: onDecrement, // Directly call the callbacks
              child: const SizedBox(
                width: 50,
                height: 50,
                child: Icon(Icons.remove, color: Colors.white),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
