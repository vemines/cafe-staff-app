import 'package:flutter/material.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/space.dart';
import '/features/entities/menu_item_entity.dart';

class OrderButton extends StatelessWidget {
  final MenuItemEntity menuItem;
  final int quantity;
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
    final textStyle = context.textTheme.bodyMedium!.copyWith(color: Colors.white);
    final buttonBorder =
        quantity == 0 ? 8.borderRadius : BorderRadius.only(topLeft: 8.radius, bottomLeft: 8.radius);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        GestureDetector(
          onTap: onIncrement,
          child: Container(
            height: 50,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(color: Colors.blue, borderRadius: buttonBorder),
            child: Row(
              children: [
                Text(menuItem.name, style: textStyle),
                if (quantity > 0) ...[sbW1, Text('($quantity)', style: textStyle)],
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
            onTap: onDecrement,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.only(topRight: 8.radius, bottomRight: 8.radius),
              ),
              width: 50,
              height: 50,
              child: Icon(Icons.remove, color: Colors.white),
            ),
          ),
        ],
      ],
    );
  }
}
