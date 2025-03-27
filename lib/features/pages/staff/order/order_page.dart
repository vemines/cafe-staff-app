import 'dart:math' show min;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/paths.dart';
import '/app/locale.dart';
import '../../../../core/utils/screen_utils.dart';
import '../../../../core/widgets/dialog.dart';
import '../../../blocs/payment/payment_cubit.dart';
import '/core/constants/enum.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/space.dart';
import '/features/blocs/order/order_cubit.dart';
import '/features/entities/menu_item_entity.dart';
import '/features/entities/order_entity.dart';
import '/features/entities/order_item_entity.dart';
import '/features/entities/sub_category_entity.dart';
import '/features/entities/table_entity.dart';
import '/injection_container.dart';
import '../../../blocs/auth/auth_cubit.dart';
import '../../../blocs/menu/complete_menu_cubit.dart';
import 'widgets/order_button.dart';
import 'widgets/row_subcategories_button.dart';

class OrderPage extends StatefulWidget {
  final TableEntity table;

  const OrderPage({super.key, required this.table});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  String? _selectedSubcategoryId;
  late OrderEntity? _order;
  final List<OrderItemEntity> _currentOrderItems = [];
  final Map<String, int> _pendingOrderItems = {};
  late TableEntity _table;

  late OrderCubit _orderCubit;
  late CompleteMenuCubit _completeMenuCubit;
  late AuthCubit _authCubit;
  late PaymentCubit _paymentCubit;

  @override
  void initState() {
    super.initState();
    _table = widget.table;
    _order = widget.table.order;
    _orderCubit = sl<OrderCubit>();
    _completeMenuCubit = sl<CompleteMenuCubit>()..getCompleteMenu();
    _authCubit = sl<AuthCubit>();
    _paymentCubit = sl<PaymentCubit>()..getAllPayments();
    if (_order != null) _currentOrderItems.addAll(_order!.orderItems);
  }

  @override
  void dispose() {
    _orderCubit.close();
    _completeMenuCubit.close();
    _paymentCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LandscapeWrapper(
      child: Scaffold(
        appBar: AppBar(
          forceMaterialTransparency: true,
          title: Text(_table.name),
          centerTitle: true,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pop(context),
          ),
          actions: [_popupMenu((_authCubit.state as AuthAuthenticated).user.role)],
        ),
        body: SafeArea(
          child: BlocBuilder<CompleteMenuCubit, CompleteMenuState>(
            bloc: _completeMenuCubit,
            builder: (context, menuState) {
              if (menuState is CompleteMenuLoading) {
                return const Center(child: CircularProgressIndicator());
              } else if (menuState is CompleteMenuError) {
                return Center(
                  child: Text(
                    context.tr(I18nKeys.errorWithMessage, {
                      'message': menuState.failure.message ?? 'Unknown error',
                    }),
                  ),
                );
              } else if (menuState is CompleteMenuLoaded) {
                final subcategories = menuState.response.subCategories;
                final menuItems = menuState.response.menuItems;
                if (_selectedSubcategoryId == null && subcategories.isNotEmpty) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (mounted && _selectedSubcategoryId == null) {
                      setState(() {
                        _selectedSubcategoryId = subcategories.first.id;
                      });
                    }
                  });
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 2, child: _leftOrder(context, subcategories, menuItems)),
                    const VerticalDivider(width: 2, thickness: 2, color: Colors.grey),
                    Expanded(
                      flex: 1,
                      child: _rightOrder(
                        context,
                        menuState,
                        (_authCubit.state as AuthAuthenticated).user.role,
                      ),
                    ),
                  ],
                );
              }
              return Center(child: Text(context.tr(I18nKeys.noData)));
            },
          ),
        ),
      ),
    );
  }

  PopupMenuButton<String> _popupMenu(String role) {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'split') _onSplit();
        if (value == 'merge') _onMerge();
        if (value == 'approve') _onApprove();
        if (value == 'reject') _onReject();
      },
      itemBuilder: (_) {
        return [
          if (role == 'serve')
            PopupMenuItem<String>(value: 'split', child: Text(context.tr(I18nKeys.splitOrder))),
          if (role == 'serve')
            PopupMenuItem<String>(value: 'merge', child: Text(context.tr(I18nKeys.mergeOrder))),
          if (role == 'cashier')
            PopupMenuItem<String>(value: 'approve', child: Text(context.tr(I18nKeys.approveMerge))),
          if (role == 'cashier')
            PopupMenuItem<String>(value: 'reject', child: Text(context.tr(I18nKeys.rejectMerge))),
        ];
      },
    );
  }

  void _onApprove() => _orderCubit.approveMergeRequest(tableId: widget.table.id);
  void _onReject() => _orderCubit.rejectMergeRequest(tableId: widget.table.id);

  Widget _leftOrder(
    BuildContext context,
    List<SubcategoryEntity> subcategories,
    List<MenuItemEntity> menuItems,
  ) {
    if (subcategories.isEmpty || _selectedSubcategoryId == null) return SizedBox.shrink();

    final selectedSub = subcategories.firstWhere((item) => item.id == _selectedSubcategoryId);

    final listMenuItem =
        menuItems.where((item) => item.subCategory == _selectedSubcategoryId).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: RowSubcategoriesButton(
              onButtonPress: (value) => setState(() => _selectedSubcategoryId = value.id),
              subcategories: subcategories,
              selectedSubcateroryId: _selectedSubcategoryId,
            ),
          ),
        ),
        sbH2,
        Padding(
          padding: const EdgeInsets.only(left: 8),
          child: Text(selectedSub.name, style: context.bodyLargeBold),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: eiAll2,
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  listMenuItem.map((item) {
                    return OrderButton(
                      menuItem: item,
                      quantity: _pendingOrderItems[item.id] ?? 0,
                      onIncrement: () => _addPendingItem(item),
                      onDecrement: () => _removePendingItem(item),
                    );
                  }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _rightOrder(BuildContext context, CompleteMenuState menuState, String role) {
    List<Widget> combinedList = [];

    for (final orderItem in _currentOrderItems) {
      combinedList.add(
        ListTile(
          title: Text(orderItem.menuItem.name),
          subtitle: Text('Qty: ${orderItem.quantity}'),
          trailing: Text(
            '\$${(orderItem.quantity * orderItem.price).shortMoneyString}',
            style: context.bodyMediumBold,
          ),
        ),
      );
    }

    if (_currentOrderItems.isNotEmpty && _pendingOrderItems.isNotEmpty) {
      combinedList.add(const Divider(height: 2, thickness: 2, color: Colors.grey));
    }
    if (menuState is CompleteMenuLoaded) {
      final menuItems = menuState.response.menuItems;
      for (final entry in _pendingOrderItems.entries) {
        final MenuItemEntity menuItem = menuItems.firstWhere((item) => item.id == entry.key);
        combinedList.add(
          ListTile(
            title: Text(menuItem.name),
            subtitle: Text('Qty: ${entry.value} (${context.tr(I18nKeys.pending)})'),
            trailing: Text(
              '\$${(menuItem.price * entry.value).shortMoneyString}',
              style: context.bodyMediumBold,
            ),
          ),
        );
      }
    }

    return Column(
      children: [
        Expanded(
          child:
              combinedList.isEmpty
                  ? Center(child: Text(context.tr(I18nKeys.noItemsInOrder)))
                  : ListView(children: combinedList),
        ),
        Padding(
          padding: eiAll2,
          child: Wrap(
            alignment: WrapAlignment.end,
            spacing: 12,
            children: [
              ElevatedButton(
                onPressed: (_order != null && !_isServed()) ? _onServed : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: 6.borderRadius),
                ),
                child: Text(context.tr(I18nKeys.served)),
              ),
              if (role == 'serve')
                FilledButton(
                  onPressed: _addOrder,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: 6.borderRadius),
                  ),
                  child: Text(context.tr(I18nKeys.addOrder)),
                ),
              if (role == 'cashier')
                FilledButton(
                  onPressed: _onComplete,
                  style: FilledButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: 6.borderRadius),
                  ),
                  child: Text(context.tr(I18nKeys.complete)),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _addPendingItem(MenuItemEntity item) {
    setState(() {
      _pendingOrderItems.update(item.id, (value) => value + 1, ifAbsent: () => 1);
    });
  }

  void _removePendingItem(MenuItemEntity item) {
    setState(() {
      if (_pendingOrderItems.containsKey(item.id)) {
        _pendingOrderItems.update(item.id, (value) => value - 1);
        if (_pendingOrderItems[item.id]! <= 0) {
          _pendingOrderItems.remove(item.id);
        }
      }
    });
  }

  void _addOrder() {
    if (_pendingOrderItems.isEmpty) {
      context.snakebar(context.tr(I18nKeys.noPendingItemsToAdd));
      return;
    }
    final menuItems = (_completeMenuCubit.state as CompleteMenuLoaded).response.menuItems;

    List<OrderItemEntity> newOrderItems =
        _pendingOrderItems.entries.map((entry) {
          final menuItem = menuItems.firstWhere((item) => item.id == entry.key);
          return OrderItemEntity(
            id: '',
            orderId: _order?.id ?? "",
            menuItem: menuItem,
            quantity: entry.value,
            price: menuItem.price,
          );
        }).toList();

    if (_order == null) {
      _orderCubit
          .createOrder(tableId: _table.id, orderItems: newOrderItems)
          .then((_) {
            setState(() => _pendingOrderItems.clear());
          })
          .catchError((e) {
            if (mounted) context.snakebar("Failed to create order: $e");
          });
      context.pop();
    } else {
      _orderCubit
          .updateOrder(orderId: _order!.id, orderItems: newOrderItems)
          .then((_) {
            final mergedItems = List<OrderItemEntity>.from(_currentOrderItems);

            for (final newItem in newOrderItems) {
              final existingIndex = mergedItems.indexWhere(
                (item) => item.menuItem.id == newItem.menuItem.id,
              );
              if (existingIndex != -1) {
                mergedItems[existingIndex] = mergedItems[existingIndex].copyWith(
                  quantity: mergedItems[existingIndex].quantity + newItem.quantity,
                );
              } else {
                // Ensure the newItem has the correct orderId if added to an existing order
                final itemToAdd = newItem.copyWith(orderId: _order!.id);
                mergedItems.add(itemToAdd);
              }
            }

            setState(() {
              _currentOrderItems.clear();
              _currentOrderItems.addAll(mergedItems);
              _pendingOrderItems.clear();
            });
          })
          .catchError((e) {
            if (mounted) context.snakebar("Failed to update order: $e");
          });
    }
  }

  Map<String, int> itemsToMove = {};
  void _onSplit() async {
    if (_order == null || _order!.orderItems.isEmpty) {
      context.snakebar(context.tr(I18nKeys.noItemsToSplit));
      return;
    }
    itemsToMove.clear();
    final result = await _showSplitMergeDialog(context, true);

    if (result != null && itemsToMove.isNotEmpty) {
      final itemsToSend = Map<String, int>.from(itemsToMove)
        ..removeWhere((key, value) => value == 0);
      if (itemsToSend.isEmpty) {
        if (mounted) context.snakebar(context.tr(I18nKeys.noItemsSelectedToSplit));
        return;
      }
      _orderCubit.splitOrder(
        sourceTableId: _table.id,
        targetTableId: result['tableId'],
        splitItemIds: itemsToSend,
      );
    }
  }

  void _onMerge() async {
    if (_order == null || _order!.orderItems.isEmpty) {
      context.snakebar(context.tr(I18nKeys.noItemsToMerge));
      return;
    }
    itemsToMove.clear();
    final result = await _showSplitMergeDialog(context, false);

    if (result != null && itemsToMove.isNotEmpty) {
      final itemsToSend = Map<String, int>.from(itemsToMove)
        ..removeWhere((key, value) => value == 0);
      if (itemsToSend.isEmpty) {
        if (mounted) context.snakebar(context.tr(I18nKeys.noItemsSelectedToMerge));
        return;
      }
      _orderCubit.createMergeRequest(
        sourceTableId: _table.id,
        targetTableId: result['tableId'],
        splitItemIds: itemsToSend,
      );
      itemsToMove = {};
    }
  }

  Future<Map<String, dynamic>?> _showSplitMergeDialog(BuildContext context, bool isSplit) async {
    return await showDialog<Map<String, dynamic>?>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (statefulContext, setStateDialog) {
            return AlertDialog(
              title: Text(
                isSplit ? context.tr(I18nKeys.splitOrder) : context.tr(I18nKeys.mergeOrder),
              ),
              content: SizedBox(
                width: min(statefulContext.width * 0.9, 400),
                child: SingleChildScrollView(
                  child: _selectMenuitem(itemsToMove, setStateDialog, context),
                ),
              ),
              actions: [
                TextButton(
                  child: Text(context.tr(I18nKeys.cancel)),
                  onPressed: () {
                    itemsToMove.clear();
                    Navigator.of(dialogContext).pop(null);
                  },
                ),
                FilledButton(
                  onPressed:
                      itemsToMove.values.any((qty) => qty > 0)
                          ? () async {
                            final String? targetTableId = await dialogContext.push(
                              Paths.selectTable,
                              extra: isSplit,
                            );

                            if (targetTableId != null) {
                              if (context.mounted) {
                                Navigator.pop(dialogContext, {'tableId': targetTableId});
                              }
                            }
                          }
                          : null,
                  child: Text(context.tr(I18nKeys.selectTable)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget _selectMenuitem(
    Map<String, int> itemsToMove,
    StateSetter setStateDialog,
    BuildContext context,
  ) {
    final menuState = _completeMenuCubit.state;
    if (menuState is! CompleteMenuLoaded) {
      return Center(child: Text(context.tr(I18nKeys.noMenuItemsFound)));
    }

    if (_order == null || _order!.orderItems.isEmpty) {
      return Center(child: Text(context.tr(I18nKeys.noItemsInOrder)));
    }

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        ..._order!.orderItems.map((orderItem) {
          final menuItem = orderItem.menuItem;
          final currentQuantity = orderItem.quantity;
          itemsToMove.putIfAbsent(menuItem.id, () => 0);

          return OrderButton(
            menuItem: menuItem,
            quantity: itemsToMove[menuItem.id]!,
            max: currentQuantity,
            onIncrement: () {
              if ((itemsToMove[menuItem.id] ?? 0) < currentQuantity) {
                setStateDialog(() {
                  itemsToMove[menuItem.id] = (itemsToMove[menuItem.id] ?? 0) + 1;
                });
              }
            },
            onDecrement: () {
              if ((itemsToMove[menuItem.id] ?? 0) > 0) {
                setStateDialog(() {
                  itemsToMove[menuItem.id] = (itemsToMove[menuItem.id] ?? 0) - 1;
                });
              }
            },
          );
        }),
      ],
    );
  }

  List<String> getSelectedItems(List<OrderItemEntity> orderItems, List<bool> selectedItems) {
    List<String> selectedIds = [];
    for (int i = 0; i < selectedItems.length; i++) {
      if (selectedItems[i]) {
        selectedIds.add(orderItems[i].id);
      }
    }
    return selectedIds;
  }

  void _onServed() => _orderCubit.serveOrder(orderId: _order!.id);

  void _onComplete() {
    if (_order == null) {
      context.snakebar(context.tr(I18nKeys.noOrderToComplete));
      return;
    }
    showCustomizeDialog(
      context,
      showAction: false,
      title: context.tr(I18nKeys.selectPaymentMethods),
      content: BlocBuilder<PaymentCubit, PaymentState>(
        bloc: _paymentCubit,
        builder: (context, state) {
          if (state is PaymentLoaded) {
            final activePayments = state.payments.where((p) => p.isActive).toList();
            if (activePayments.isEmpty) {
              return Center(child: Text(context.tr(I18nKeys.noActivePaymentMethods)));
            }
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    activePayments.map((payment) {
                      return ListTile(
                        title: Text(payment.name),
                        onTap: () {
                          _orderCubit.completeOrder(
                            orderId: _order!.id,
                            paymentMethod: payment.name,
                          );
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                      );
                    }).toList(),
              ),
            );
          } else if (state is PaymentError) {
            return Center(
              child: Text(
                context.tr(I18nKeys.errorWithMessage, {'message': state.failure.message ?? ''}),
              ),
            );
          } else {
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  bool _isServed() =>
      widget.table.status == TableStatus.served || widget.table.status == TableStatus.completed;
}
