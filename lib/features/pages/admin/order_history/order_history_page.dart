import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/datetime_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/dialog.dart';
import '/core/widgets/space.dart';
import '/features/blocs/order_history/order_history_cubit.dart';
import '/features/pages/admin/widgets/admin_appbar.dart';
import '/injection_container.dart';
import '../../../blocs/payment/payment_cubit.dart';
import '../../../entities/order_history_entity.dart';
import '../widgets/admin_drawer.dart';
import '../widgets/date_range_button.dart';
import '../widgets/select_button.dart';

class OrderHistoryPage extends StatefulWidget {
  const OrderHistoryPage({super.key});

  @override
  State<OrderHistoryPage> createState() => _OrderHistoryPageState();
}

class _OrderHistoryPageState extends State<OrderHistoryPage> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  DateTime? _startDate;
  DateTime? _endDate;
  String? _filterPaymentMethod;
  late final OrderHistoryCubit _orderHistoryCubit;
  late final PaymentCubit _paymentCubit;
  List<String?> paymentMethods = [null];

  @override
  void initState() {
    super.initState();
    _orderHistoryCubit = sl<OrderHistoryCubit>()..getAllOrderHistory();
    _paymentCubit = sl<PaymentCubit>()..getAllPayments();
  }

  @override
  void dispose() {
    _orderHistoryCubit.close();
    _paymentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<OrderHistoryCubit>(create: (context) => _orderHistoryCubit),
        BlocProvider<PaymentCubit>(create: (context) => _paymentCubit),
      ],
      child: Scaffold(
        key: _scaffoldKey,
        appBar: adminAppBar(_scaffoldKey, 'Order History'),
        drawer: const AdminDrawer(),
        body: Column(
          children: [
            _filterRow(context),
            BlocListener<PaymentCubit, PaymentState>(
              bloc: _paymentCubit,
              listener: (context, state) {
                if (state is PaymentLoaded) {
                  setState(() {
                    paymentMethods = [null, ...state.payments.map((e) => e.name)];
                  });
                }
              },
              child: SizedBox.shrink(),
            ),
            Expanded(
              child: BlocBuilder<OrderHistoryCubit, OrderHistoryState>(
                bloc: _orderHistoryCubit,
                builder: (context, state) {
                  if (state is OrderHistoryLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is OrderHistoryError) {
                    return Center(child: Text('Error: ${state.failure.message}'));
                  } else if (state is OrderHistoryLoaded || state is OrderHistoryLoadingMore) {
                    final orderHistory = state.orderHistory;
                    final hasMore = state.hasMore;
                    return _listOrderHistory(orderHistory: orderHistory, hasMore: hasMore);
                  }
                  return const Center(child: Text('No orders found.'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _listOrderHistory({
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
            _orderHistoryCubit.getAllOrderHistory(
              isLoadMore: true,
              startDate: _startDate,
              endDate: _endDate,
              paymentMethod: _filterPaymentMethod,
            );
          });
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _filterRow(BuildContext context) {
    return Padding(
      padding: eiAll4,
      child: Wrap(
        spacing: context.isMobile ? 8 : 24,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              DateRangeButtonWidget(
                endDaySelected: _endDate,
                startDaySelected: _startDate,
                onPick: (picked) {
                  if (picked != null) {
                    setState(() {
                      _startDate = picked.start;
                      _endDate = picked.end;
                      _orderHistoryCubit.getAllOrderHistory(
                        startDate: _startDate,
                        endDate: _endDate,
                      );
                    });
                  }
                },
              ),
              sbW2,
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _startDate = null;
                    _endDate = null;
                    _orderHistoryCubit.getAllOrderHistory(startDate: _startDate, endDate: _endDate);
                  });
                },
              ),
            ],
          ),
          selectButton(
            onPressed: () => _showPaymentMethodDialog(context),
            text: _filterPaymentMethod ?? "Select Payment Methods",
            minWidth: 220,
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    showCustomizeDialog(
      context,
      title: 'Select Payment Method',
      showAction: false,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(paymentMethods.length, (index) {
            return ListTile(
              title: Text(paymentMethods[index] ?? "All Payment Methods"),
              onTap: () {
                setState(() => _filterPaymentMethod = paymentMethods[index]);
                _orderHistoryCubit.getAllOrderHistory(
                  startDate: _startDate,
                  endDate: _endDate,
                  paymentMethod: _filterPaymentMethod,
                );
                Navigator.of(context).pop();
              },
              trailing:
                  _filterPaymentMethod == paymentMethods[index] ? const Icon(Icons.check) : null,
            );
          }),
        ),
      ),
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
