import 'package:cafe_staff_app/core/extensions/datetime_extension.dart';
import 'package:flutter/material.dart';
import '../../../entities/order_history_entity.dart';
import '../../../entities/user_entity.dart';
import '../../mock.dart';

class OrderHistoryPage extends StatelessWidget {
  final UserEntity user;

  OrderHistoryPage({super.key, required this.user});

  // Use MockData.completedOrders directly
  final List<OrderHistoryEntity> _orderHistory = MockData.completedOrders;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true, title: Text('Order History')),
      body: _buildOrderHistoryList(),
    );
  }

  Widget _buildOrderHistoryList() {
    if (_orderHistory.isEmpty) {
      return Center(child: Text('No order history available.'));
    }

    return ListView.builder(
      itemCount: _orderHistory.length,
      itemBuilder: (context, index) {
        final order = _orderHistory[index];
        return ListTile(
          title: Text('Order ${order.orderId}'),
          subtitle: Text(
            'Table: ${order.table.tableName}, Total: \$${order.totalPrice.toStringAsFixed(2)}',
          ),
          trailing: Text(order.completedAt.toFormatTime()),
          onTap: () {
            _showOrderDetails(context, order);
          },
        );
      },
    );
  }

  void _showOrderDetails(BuildContext context, OrderHistoryEntity order) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Order Details - ${order.orderId}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Table: ${order.table.tableName}'),
                Text('Payment Method: ${order.paymentMethod}'),
                Text('Created At: ${order.createdAt.toFormatTime()}'),
                Text('Served At: ${order.servedAt.toFormatTime()}'),
                Text('Completed At: ${order.completedAt.toFormatTime()}'),
                Text('Total Price: \$${order.totalPrice.toStringAsFixed(2)}'),
                SizedBox(height: 8),
                Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ...order.orderItems.map(
                  (item) => Text(
                    '${item.menuItem.name} x ${item.quantity} - \$${(item.price * item.quantity).toStringAsFixed(2)}',
                  ),
                ),
              ],
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(context), child: Text('Close'))],
        );
      },
    );
  }
}
