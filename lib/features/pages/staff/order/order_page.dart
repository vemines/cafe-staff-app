import '../../../blocs/menu/complete_menu_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/constants/enum.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/services/socket_service.dart';
import '/core/widgets/dialog.dart';
import '/core/widgets/space.dart';
import '/features/blocs/order/order_cubit.dart';
import '/features/entities/menu_item_entity.dart';
import '/features/entities/order_entity.dart';
import '/features/entities/order_item_entity.dart';
import '/features/entities/sub_category_entity.dart';
import '/features/entities/table_entity.dart';
import '/injection_container.dart';
import 'select_table_page.dart';
import 'widgets/order_button.dart';
import 'widgets/row_subcategories_button.dart';

class OrderPage extends StatefulWidget {
  final TableEntity table;
  final OrderEntity? order;

  const OrderPage({super.key, required this.table, this.order});

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
  // late final SocketService _socketService;

  @override
  void initState() {
    super.initState();
    _table = widget.table;
    _order = widget.order;
    _orderCubit = sl<OrderCubit>();
    _completeMenuCubit = sl<CompleteMenuCubit>();
    _completeMenuCubit.getCompleteMenu();
    // _socketService = sl<SocketService>();
    _initSocketListeners();
    if (_order != null) _currentOrderItems.addAll(_order!.orderItems);
  }

  // Add this method
  void _initSocketListeners() {
    // _socketService.socket.on('order_updated', (data) => _handleOrderUpdated(data));
    // _socketService.socket.on('order_created', (data) => _handleOrderUpdated(data));
  }

  void _handleOrderUpdated(dynamic data) {
    _completeMenuCubit.getCompleteMenu(); // Refresh to ensure consistency
  }

  @override
  void dispose() {
    _orderCubit.close();
    _completeMenuCubit.close();
    // _socketService.socket.off('order_updated');
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(_table.name),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [_popupMenu()],
      ),
      body: SafeArea(
        child: BlocBuilder<CompleteMenuCubit, CompleteMenuState>(
          bloc: _completeMenuCubit,
          builder: (context, menuState) {
            if (menuState is CompleteMenuLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (menuState is CompleteMenuError) {
              return Center(child: Text("Error: ${menuState.failure.message}"));
            } else if (menuState is CompleteMenuLoaded) {
              final subcategories = menuState.response.subCategories;
              final menuItems = menuState.response.menuItems;
              if (_selectedSubcategoryId == null && subcategories.isNotEmpty) {
                _selectedSubcategoryId = subcategories.first.id;
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 2, child: _serverMenu(context, subcategories, menuItems)),
                  const VerticalDivider(width: 2, thickness: 2, color: Colors.grey),
                  Expanded(flex: 1, child: _serverOrderView(menuState)),
                ],
              );
            }
            return const Center(child: Text("No data"));
          },
        ),
      ),
    );
  }

  PopupMenuButton<String> _popupMenu() {
    return PopupMenuButton<String>(
      onSelected: (value) {
        if (value == 'split') _onSplit();
        if (value == 'merge') _onMerge();
      },
      itemBuilder: (_) {
        return [
          const PopupMenuItem<String>(value: 'split', child: Text('Split Order')),
          const PopupMenuItem<String>(value: 'merge', child: Text('Merge Order')),
        ];
      },
    );
  }

  Widget _serverMenu(
    BuildContext context,
    List<SubcategoryEntity> subcategories,
    List<MenuItemEntity> menuItems,
  ) {
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
        Text(
          subcategories
              .firstWhere(
                (element) => element.id == _selectedSubcategoryId,
                orElse: () => subcategories.first,
              )
              .name,
          style: context.bodyLargeBold,
        ),
        Expanded(
          child: SingleChildScrollView(
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

  Widget _serverOrderView(CompleteMenuState menuState) {
    // Added menuState parameter
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
      for (final entry in _pendingOrderItems.entries) {
        final menuItem = menuState.response.menuItems.firstWhere(
          // Access menuItems safely
          (item) => item.id == entry.key,
        );
        combinedList.add(
          ListTile(
            title: Text(menuItem.name),
            subtitle: Text('Qty: ${entry.value} (Pending)'),
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
                  ? const Center(child: Text('No items in order'))
                  : ListView(children: combinedList),
        ),
        Padding(
          padding: eiAll2,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: (_order != null && !_isServed()) ? _onServed : null,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: 8.borderRadius),
                ),
                child: const Text('Served'),
              ),
              FilledButton(
                onPressed: _addOrder,
                style: FilledButton.styleFrom(
                  shape: RoundedRectangleBorder(borderRadius: 8.borderRadius),
                ),
                child: const Text('Add Order'),
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
    if (_pendingOrderItems.isEmpty) return;

    List<OrderItemEntity> newOrderItems =
        _pendingOrderItems.entries.map((entry) {
          final menuItem = (_completeMenuCubit.state as CompleteMenuLoaded).response.menuItems
              .firstWhere((item) => item.id == entry.key);
          return OrderItemEntity(
            id: 'new_item_id',
            orderId: _order?.id ?? "",
            menuItem: menuItem,
            quantity: entry.value,
            price: menuItem.price,
          );
        }).toList();

    if (_order == null) {
      // Create a new order via Cubit
      _orderCubit.createOrder(tableId: _table.id, orderItems: newOrderItems);
    } else {
      final mergedItems = [..._currentOrderItems];

      for (final newItem in newOrderItems) {
        final existingIndex = mergedItems.indexWhere(
          (item) => item.menuItem.id == newItem.menuItem.id,
        );
        if (existingIndex != -1) {
          // Update quantity if item exists
          mergedItems[existingIndex] = mergedItems[existingIndex].copyWith(
            quantity: mergedItems[existingIndex].quantity + newItem.quantity,
          );
        } else {
          // Add new item
          mergedItems.add(newItem);
        }
      }
      setState(() {
        _currentOrderItems.clear();
        _currentOrderItems.addAll(mergedItems);
        _order = _order!.copyWith(orderItems: mergedItems);
        _pendingOrderItems.clear();
      });
    }
  }

  void _onSplit() {
    if (_order == null) return;

    List<bool> selectedItems = List.generate(_order!.orderItems.length, (index) => false);

    showCustomizeDialog(
      context,
      title: "Split Table: ${_table.name}",
      actionText: "Select Table",
      onAction: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SelectTablePage(order: _order, selectedItems: selectedItems),
          ),
        );
        if (context.mounted && result != null) {
          _orderCubit.splitOrder(
            sourceTableId: _table.id,
            targetTableId: result,
            splitItemIds: getSelectedItems(_order!.orderItems, selectedItems),
          );
        }
      },
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 400,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: _order!.orderItems.length,
                  itemBuilder: (context, index) {
                    final orderItem = _order!.orderItems[index];
                    return CheckboxListTile(
                      title: Text(orderItem.menuItem.name),
                      subtitle: Text("Qty: ${orderItem.quantity}"),
                      value: selectedItems[index],
                      onChanged: (newValue) {
                        setStateDialog(() {
                          selectedItems[index] = newValue!;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onMerge() {
    if (_order == null) return;
    List<bool> selectedItems = List.generate(_order!.orderItems.length, (index) => false);

    showCustomizeDialog(
      context,
      title: "Merge Table: ${_table.name}",
      actionText: "Select Table",
      onAction: () async {
        final result = await Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => SelectTablePage(order: _order, selectedItems: selectedItems),
          ),
        );

        if (context.mounted && result != null) {
          _orderCubit.createMergeRequest(
            sourceTableId: _table.id,
            targetTableId: result,
            splitItemIds: getSelectedItems(_order!.orderItems, selectedItems),
          );
        }
      },
      content: StatefulBuilder(
        builder: (BuildContext context, StateSetter setStateDialog) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 400,
                width: double.maxFinite,
                child: ListView.builder(
                  itemCount: selectedItems.length,
                  itemBuilder: (context, index) {
                    final orderItem = _order!.orderItems[index];
                    return CheckboxListTile(
                      title: Text(orderItem.menuItem.name),
                      subtitle: Text("Qty: ${orderItem.quantity}"),
                      value: selectedItems[index],
                      onChanged: (newValue) {
                        setStateDialog(() {
                          selectedItems[index] = newValue!;
                        });
                      },
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
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

  void _onServed() {
    if (_order == null) return;
    _orderCubit.serveOrder(orderId: _order!.id); // Use Cubit for state management
  }

  bool _isServed() =>
      widget.table.status == TableStatus.served || widget.table.status == TableStatus.completed;
}
