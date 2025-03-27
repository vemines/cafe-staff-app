import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/locale.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/dialog.dart';
import '/core/widgets/space.dart';
import '/injection_container.dart';
import '../../../blocs/order_history/order_history_cubit.dart';
import '../../../entities/order_history_entity.dart';

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
    _orderHistoryCubit = sl<OrderHistoryCubit>();
    _orderHistoryCubit.getAllOrderHistory();
  }

  @override
  void dispose() {
    _orderHistoryCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(context.tr(I18nKeys.orderHistory)),
      ),
      body: SafeArea(
        child: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
          bloc: _orderHistoryCubit,
          builder: (context, state) {
            if (state is OrderHistoryLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is OrderHistoryError) {
              return Center(
                child: Text(
                  context.tr(I18nKeys.errorWithMessage, {
                    'message': state.failure.message ?? 'Unknown error',
                  }),
                ),
              );
            } else if (state is OrderHistoryLoaded || state is OrderHistoryLoadingMore) {
              final orderHistory = state.orderHistory;
              final hasMore = state.hasMore;
              return _orderHistoryList(context, orderHistory: orderHistory, hasMore: hasMore);
            }
            return Center(child: Text(context.tr(I18nKeys.noOrdersFound)));
          },
        ),
      ),
    );
  }

  Widget _orderHistoryList(
    BuildContext context, {
    required List<OrderHistoryEntity> orderHistory,
    required bool hasMore,
  }) {
    if (orderHistory.isEmpty && !hasMore) {
      return Center(child: Text(context.tr(I18nKeys.noOrdersFound)));
    }

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
            if (mounted && _orderHistoryCubit.isLoadMore == false) {
              _orderHistoryCubit.getAllOrderHistory(isLoadMore: true);
            }
          });

          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  void _showOrderDetails(BuildContext context, OrderHistoryEntity orderHistory) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.orderDetail, {'orderId': orderHistory.id}),
      showAction: false,
      content: DefaultTextStyle(
        style: context.textTheme.bodyMedium!,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('${context.tr(I18nKeys.table)}: ${orderHistory.tableName}'),
              Text('${context.tr(I18nKeys.paymentMethod)}: ${orderHistory.paymentMethod}'),
              Text('${context.tr(I18nKeys.createdAt)}: ${orderHistory.createdAt.toFormatTime}'),
              Text('${context.tr(I18nKeys.servedAt)}: ${orderHistory.servedAt.toFormatTime}'),
              Text('${context.tr(I18nKeys.completeBy)}: ${orderHistory.cashierName}'),
              Text('${context.tr(I18nKeys.completedAt)}: ${orderHistory.completedAt.toFormatTime}'),
              Text(
                '${context.tr(I18nKeys.totalPrice)}: \$${orderHistory.totalPrice.shortMoneyString}',
              ),
              sbH2,
              Text('${context.tr(I18nKeys.items)}:', style: context.bodyLargeBold),
              ...orderHistory.orderItems.map(
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
