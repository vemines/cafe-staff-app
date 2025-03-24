import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/extensions/num_extensions.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/widgets/dialog.dart';
import '/core/widgets/space.dart';
import '../../../blocs/order_history/order_history_cubit.dart';
import '../../../entities/order_history_entity.dart';
import '/injection_container.dart';

class StaffOrderHistoryPage extends StatefulWidget {
  const StaffOrderHistoryPage({super.key});

  @override
  State<StaffOrderHistoryPage> createState() => _StaffOrderHistoryPageState();
}

class _StaffOrderHistoryPageState extends State<StaffOrderHistoryPage> {
  late final OrderHistoryCubit _orderHistoryCubit;

  @override
  void initState() {
    super.initState();
    _orderHistoryCubit = sl<OrderHistoryCubit>(); // Get from GetIt
    _orderHistoryCubit.getAllOrderHistory(); // Fetch initial data
  }

  @override
  void dispose() {
    _orderHistoryCubit.close(); // Dispose of the Cubit
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(forceMaterialTransparency: true, title: const Text('Order History')),
      body: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
        bloc: _orderHistoryCubit, // Use the local instance
        builder: (context, state) {
          if (state is OrderHistoryLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is OrderHistoryError) {
            return Center(child: Text('Error: ${state.failure.message}'));
          } else if (state is OrderHistoryLoaded || state is OrderHistoryLoadingMore) {
            final orders = state.orderHistory;
            final hasMore = state.hasMore;
            return _orderHistoryList(orderHistory: orders, hasMore: hasMore);
          }
          return const Center(child: Text('No orders found.'));
        },
      ),
    );
  }

  Widget _orderHistoryList({
    required List<OrderHistoryEntity> orderHistory,
    required bool hasMore,
  }) {
    return ListView.builder(
      itemCount: orderHistory.length + (hasMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index < orderHistory.length) {
          final order = orderHistory[index];
          final leadingStyle = context.textTheme.bodySmall!.copyWith(fontWeight: FontWeight.w600);
          final titleStyle = context.textTheme.bodyLarge!.copyWith(fontWeight: FontWeight.w600);
          final subtitleStyle = context.textTheme.bodyMedium;

          return ListTile(
            trailing: Text(order.tableName, style: leadingStyle),
            title: Text('\$${order.totalPrice.shortMoneyString}', style: titleStyle),
            subtitle: Text(order.paymentMethod, style: subtitleStyle),
            leading: Text(order.completedAt.toFormatTime),
            onTap: () => _showOrderDetails(context, order),
          );
        } else {
          if (!hasMore) return const SizedBox.shrink();
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _orderHistoryCubit.getAllOrderHistory(isLoadMore: true);
          });

          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _showOrderDetails(BuildContext context, OrderHistoryEntity order) {
    showCustomizeDialog(
      context,
      title: "Order Detail (${order.orderId})",
      showAction: false,
      content: DefaultTextStyle(
        style: context.textTheme.bodyMedium!,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Table: ${order.tableName}'),
              Text('Payment Method: ${order.paymentMethod}'),
              Text('Created At: ${order.createdAt.toFormatTime}'),
              Text('Served At: ${order.servedAt.toFormatTime}'),
              Text('Complete By: ${order.cashierName}'),
              Text('Completed At: ${order.completedAt.toFormatTime}'),
              Text('Total Price: \$${order.totalPrice.shortMoneyString}'),
              sbH2,
              Text('Items:', style: context.bodyLargeBold),
              ...order.orderItems.map(
                (item) => Text(
                  '${item.menuItem.name} x ${item.quantity} - \$${(item.price * item.quantity).shortMoneyString}',
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
