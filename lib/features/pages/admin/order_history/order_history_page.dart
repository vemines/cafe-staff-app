import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/app/locale.dart';
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
  List<String?> paymentMethods = [null]; // null represents 'All'

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
        appBar: adminAppBar(_scaffoldKey, context.tr(I18nKeys.orderHistory)),
        drawer: const AdminDrawer(),
        body: SafeArea(
          child: Column(
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
                      return _listOrderHistory(
                        context,
                        orderHistory: orderHistory,
                        hasMore: hasMore,
                      );
                    }
                    return Center(child: Text(context.tr(I18nKeys.noOrdersFound)));
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _listOrderHistory(
    BuildContext context, {
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
            text: _filterPaymentMethod ?? context.tr(I18nKeys.selectPaymentMethods),
            minWidth: 220,
          ),
        ],
      ),
    );
  }

  void _showPaymentMethodDialog(BuildContext context) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.selectPaymentMethods),
      showAction: false,
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: List<Widget>.generate(paymentMethods.length, (index) {
            final paymentName = paymentMethods[index];
            return ListTile(
              title: Text(paymentName ?? context.tr(I18nKeys.allPaymentMethods)),
              onTap: () {
                setState(() => _filterPaymentMethod = paymentName);
                _orderHistoryCubit.getAllOrderHistory(
                  startDate: _startDate,
                  endDate: _endDate,
                  paymentMethod: _filterPaymentMethod,
                );
                Navigator.of(context).pop();
              },
              trailing: _filterPaymentMethod == paymentName ? const Icon(Icons.check) : null,
            );
          }),
        ),
      ),
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
