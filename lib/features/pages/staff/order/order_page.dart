// lib/features/pages/staff/order/order_page.dart
import 'package:cafe_staff_app/core/constants/enum.dart';
import 'package:cafe_staff_app/core/extensions/build_content_extensions.dart';
import 'package:cafe_staff_app/core/extensions/num_extension.dart';
import 'package:cafe_staff_app/core/widgets/widgets.dart';
import 'package:flutter/material.dart';

import '../../../entities/menu_item_entity.dart';
import '../../../entities/order_entity.dart';
import '../../../entities/order_history_entity.dart';
import '../../../entities/order_item_entity.dart';
import '../../../entities/sub_category_entity.dart';
import '../../../entities/table_entity.dart';
import '../../../entities/user_entity.dart';
import '../../mock.dart';
import '../widgets/order_button.dart';

class OrderPage extends StatefulWidget {
  final UserEntity user;
  final TableEntity table;
  final OrderEntity? order;

  const OrderPage({super.key, required this.user, required this.table, this.order});

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> {
  late final List<SubCategoryEntity> _subcategories;
  late final List<MenuItemEntity> _menuItems;
  String? _selectedSubcategoryId;
  late OrderEntity? _order;
  final List<OrderItemEntity> _currentOrderItems = []; // Existing order items
  final Map<String, int> _pendingOrderItems = {}; // MenuItem ID -> Quantity
  late TableEntity _table;

  @override
  void initState() {
    super.initState();
    _table = widget.table;
    _order = widget.order;
    _subcategories = MockData.subCategories;
    _menuItems = MockData.menuItems;
    _selectedSubcategoryId = _subcategories.first.id;

    if (_order != null) {
      _currentOrderItems.addAll(_order!.orderItems);
    }
  }

  // --- Add Pending Item ---
  void _addPendingItem(MenuItemEntity item) {
    setState(() {
      _pendingOrderItems.update(item.id, (value) => value + 1, ifAbsent: () => 1);
    });
  }

  // --- Remove Pending Item ---
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

  // --- Create or Update Order (Combined) ---
  void _addOrder() {
    if (_pendingOrderItems.isEmpty) return;

    List<OrderItemEntity> newOrderItems =
        _pendingOrderItems.entries.map((entry) {
          final menuItem = _menuItems.firstWhere((item) => item.id == entry.key);
          return OrderItemEntity(
            id: MockData.generateOrderItemId(), // New ID for each item
            orderId: _order?.id ?? "", // Existing or new order ID
            menuItem: menuItem,
            quantity: entry.value,
            price: menuItem.price,
          );
        }).toList();

    if (_order == null) {
      // Create a new order
      final newOrder = OrderEntity(
        id: MockData.generateOrderId(),
        tableId: _table.id,
        timestamp: DateTime.now(),
        orderItems: newOrderItems,
        totalPrice: _calculateTotalPrice(newOrderItems), // Calculate for new order
        createdBy: widget.user.id,
        createdAt: DateTime.now(),
      );
      setState(() {
        _order = newOrder;
        MockData.orders.add(newOrder);
        _table = _table.copyWith(status: TableStatus.pending, order: newOrder);
        final tableIndex = MockData.tables.indexWhere((t) => t.id == _table.id);
        if (tableIndex != -1) {
          MockData.tables[tableIndex] = _table;
        }
        _currentOrderItems.addAll(newOrderItems); // Add to displayed items
        _pendingOrderItems.clear(); // Clear pending
      });
    } else {
      // Update the existing order

      // Merge current items and new items
      final mergedItems = [..._currentOrderItems];
      for (final newItem in newOrderItems) {
        final existingIndex = mergedItems.indexWhere(
          (item) => item.menuItem.id == newItem.menuItem.id,
        );
        if (existingIndex != -1) {
          mergedItems[existingIndex] = mergedItems[existingIndex].copyWith(
            quantity: mergedItems[existingIndex].quantity + newItem.quantity,
          );
        } else {
          mergedItems.add(newItem);
        }
      }

      setState(() {
        _order = _order!.copyWith(
          orderItems: mergedItems,
          totalPrice: _calculateTotalPrice(mergedItems),
        ); // Update
        final orderIndex = MockData.orders.indexWhere((o) => o.id == _order!.id);
        if (orderIndex != -1) {
          MockData.orders[orderIndex] = _order!;
        }
        _currentOrderItems.clear(); // Clear
        _currentOrderItems.addAll(mergedItems); // Add all
        _pendingOrderItems.clear(); // Clear pending
      });
    }
  }

  // --- Calculate Total Price (Modified to accept items) ---
  double _calculateTotalPrice(List<OrderItemEntity> items) {
    double totalPrice = 0;
    for (final orderItem in items) {
      final menuItem = _menuItems.firstWhere((item) => item.id == orderItem.menuItem.id);
      totalPrice += menuItem.price * orderItem.quantity;
    }
    return double.parse(totalPrice.toStringAsFixed(2));
  }

  // --- Complete Order ---
  void _completeOrder(String paymentMethod) {
    if (_order == null || _order!.orderItems.isEmpty) return;

    final completedOrder = OrderHistoryEntity(
      id: MockData.generateOrderHistoryId(),
      orderId: _order!.id,
      table: _table,
      paymentMethod: paymentMethod,
      createdAt: _order!.createdAt!,
      servedAt: _order!.servedAt ?? DateTime.now(), // Use current time if null
      completedAt: DateTime.now(),
      orderItems: _order!.orderItems,
      cashierId: widget.user.id,
      totalPrice: _order!.totalPrice,
    );

    setState(() {
      MockData.completedOrders.add(completedOrder);
      MockData.orders.removeWhere((o) => o.id == _order!.id);

      // Update the table using copyWith, setting order to null
      _table = _table.copyWith(status: TableStatus.completed, order: null);
      // Find table and update
      final tableIndex = MockData.tables.indexWhere((t) => t.id == _table.id);
      if (tableIndex != -1) {
        MockData.tables[tableIndex] = _table;
      }
      // Clear local state
      _order = null;
      _currentOrderItems.clear();
    });
  }

  // --- Update Order Item Quantity --- No longer used directly, kept for potential future use

  void _onSplit() {}

  void _onMerge() {}

  void _onConfirmMerge() {}

  void _onServed() {
    if (_order == null) return;

    setState(() {
      // Update the order with served information
      _order = _order!.copyWith(servedBy: widget.user.id, servedAt: DateTime.now());

      // Update the table's status to served
      _table = _table.copyWith(status: TableStatus.served);

      // Find the order and update
      final orderIndex = MockData.orders.indexWhere((o) => o.id == _order!.id);
      if (orderIndex != -1) {
        MockData.orders[orderIndex] = _order!;
      }

      // Find table and update
      final tableIndex = MockData.tables.indexWhere((t) => t.id == _table.id);
      if (tableIndex != -1) {
        MockData.tables[tableIndex] = _table;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: Text(_table.tableName),
        centerTitle: true,
        leading: IconButton(icon: Icon(Icons.arrow_back), onPressed: () => Navigator.pop(context)),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'split') {
                _onSplit();
              } else if (value == 'merge') {
                _onMerge();
              } else if (value == 'confirm_merge') {
                _onConfirmMerge();
              }
            },
            itemBuilder: (BuildContext context) {
              if (widget.user.role == 'serve') {
                return [
                  PopupMenuItem<String>(value: 'split', child: Text('Split Order')),
                  PopupMenuItem<String>(value: 'merge', child: Text('Merge Order')),
                ];
              } else if (widget.user.role == 'cashier' && _table.mergedTable > 1) {
                return [
                  PopupMenuItem<String>(value: 'confirm_merge', child: Text('Confirm Merge')),
                ];
              }
              return [];
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.user.role == 'serve') ...[
              Expanded(flex: 2, child: _buildServerMenu(context)),
              VerticalDivider(width: 2, thickness: 2, color: Colors.grey),
            ],
            Expanded(
              flex: 1,
              child:
                  widget.user.role == 'serve'
                      ? _buildServerOrderView()
                      : _buildCashierOrderView(context),
            ),
          ],
        ),
      ),
    );
  }

  bool _isServedOrComplete() =>
      widget.table.status == TableStatus.served || widget.table.status == TableStatus.completed;

  Widget _buildServerMenu(BuildContext context) {
    final filteredSubcategories =
        _subcategories.where((sub) {
          return _menuItems.any((menuItem) => menuItem.subCategory == sub.name);
        }).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(right: 12),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  filteredSubcategories.map((sub) {
                    return Padding(
                      padding: const EdgeInsets.all(4.0),
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _selectedSubcategoryId = sub.id;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              _selectedSubcategoryId == sub.id
                                  ? Colors.blue
                                  : context.colorScheme.surfaceContainerHighest,
                          shape: RoundedRectangleBorder(borderRadius: 8.radius),
                        ),
                        child: Text(
                          sub.name,
                          style: TextStyle(
                            color: _selectedSubcategoryId == sub.id ? Colors.white : null,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ),
        sbH2(),
        Text(
          _subcategories
              .firstWhere(
                (element) => element.id == _selectedSubcategoryId,
                orElse: () => _subcategories.first,
              )
              .name,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Expanded(
          child: SingleChildScrollView(
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children:
                  _menuItems
                      .where(
                        (item) =>
                            item.subCategory ==
                            _subcategories.firstWhere((e) => e.id == _selectedSubcategoryId).name,
                      )
                      .map((item) {
                        final quantity = _pendingOrderItems[item.id] ?? 0; // Get pending quantity
                        return OrderButton(
                          menuItem: item,
                          quantity: quantity,
                          onIncrement: () {
                            _addPendingItem(item);
                          },
                          onDecrement: () {
                            _removePendingItem(item);
                          },
                        );
                      })
                      .toList(),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerOrderView() {
    // 1. Combine the lists:
    List<Widget> combinedList = [];

    // Add existing order items (if any)
    for (final orderItem in _currentOrderItems) {
      final menuItem = _menuItems.firstWhere((item) => item.id == orderItem.menuItem.id);
      combinedList.add(
        ListTile(
          title: Text(menuItem.name),
          subtitle: Text('Qty: ${orderItem.quantity}'),
          trailing: Text('\$${(orderItem.quantity * orderItem.price).toStringAsFixed(2)}'),
        ),
      );
    }

    // Add a divider IF there are existing items AND pending items
    if (_currentOrderItems.isNotEmpty && _pendingOrderItems.isNotEmpty) {
      combinedList.add(Divider(height: 2, thickness: 2, color: Colors.grey));
    }

    // Add pending order items (if any)
    for (final entry in _pendingOrderItems.entries) {
      final menuItem = _menuItems.firstWhere((item) => item.id == entry.key);
      combinedList.add(
        ListTile(
          title: Text(menuItem.name),
          subtitle: Text('Qty: ${entry.value} (Pending)'), // Indicate pending
          trailing: Text('\$${(menuItem.price * entry.value).toStringAsFixed(2)}'),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          child:
              combinedList.isEmpty
                  ? Center(child: Text('No items in order'))
                  : ListView(
                    children: combinedList, // Use the combined list
                  ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: (_order != null && !_isServedOrComplete()) ? _onServed : null,
                child: Text('Served'),
              ),
              ElevatedButton(onPressed: _addOrder, child: Text('Add Order')),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCashierOrderView(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child:
              _order == null || _order!.orderItems.isEmpty
                  ? Center(child: Text('No items in order'))
                  : ListView.builder(
                    itemCount: _order!.orderItems.length,
                    itemBuilder: (context, index) {
                      final orderItem = _order!.orderItems[index];
                      final menuItem = _menuItems.firstWhere(
                        (item) => item == orderItem.menuItem,
                        orElse:
                            () => MenuItemEntity(
                              id: 'unknown',
                              name: 'Unknown Item',
                              price: 0,
                              subCategory: '',
                              isAvailable: false,
                            ),
                      );
                      return ListTile(
                        title: Text(menuItem.name),
                        subtitle: Text('Qty: ${orderItem.quantity}'),
                        trailing: Text(
                          '\$${(orderItem.quantity * orderItem.price).toStringAsFixed(2)}',
                        ),
                      );
                    },
                  ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: ElevatedButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) {
                  String? selectedPaymentMethod;
                  return AlertDialog(
                    title: Text('Select Payment Method'),
                    content: StatefulBuilder(
                      builder: (BuildContext context, StateSetter setState) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            RadioListTile<String>(
                              title: const Text('Cash'),
                              value: 'cash',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                            ),
                            RadioListTile<String>(
                              title: const Text('Online Payment'),
                              value: 'online payment',
                              groupValue: selectedPaymentMethod,
                              onChanged: (value) {
                                setState(() {
                                  selectedPaymentMethod = value;
                                });
                              },
                            ),
                          ],
                        );
                      },
                    ),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
                      TextButton(
                        onPressed:
                            selectedPaymentMethod != null
                                ? () {
                                  _completeOrder(selectedPaymentMethod!);
                                  Navigator.pop(context); // Close dialog
                                  Navigator.pop(context); // Go back to HomePage
                                }
                                : null,
                        child: Text('Complete'),
                      ),
                    ],
                  );
                },
              );
            },
            child: Text('Complete Order'),
          ),
        ),
      ],
    );
  }
}
