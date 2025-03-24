import '../../../../core/extensions/color_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/constants/enum.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/keep_alive_wraper.dart';
import '/features/blocs/table/area_with_tables_cubit.dart';
import '/features/entities/area_with_table_entity.dart';
import '/features/entities/order_entity.dart';
import '/features/entities/table_entity.dart';
import '/injection_container.dart';
import '../widgets/table.dart';

class SelectTablePage extends StatefulWidget {
  final List<bool> selectedItems;
  final OrderEntity? order;

  const SelectTablePage({super.key, required this.selectedItems, this.order});

  @override
  SelectTablePageState createState() => SelectTablePageState();
}

class SelectTablePageState extends State<SelectTablePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  int _selectedSegment = 0;

  String? _selectedTableId;
  bool _confirmEnabled = false;
  late AreaWithTablesCubit _areaWithTablesCubit; // Use the Cubit

  @override
  void initState() {
    super.initState();
    _areaWithTablesCubit = sl<AreaWithTablesCubit>(); // Get from GetIt
    _areaWithTablesCubit.getAreasWithTables(); // Load initial data
    _tabController = TabController(
      length: 0, // Will be updated by BlocBuilder
      vsync: this,
      initialIndex: _selectedSegment,
    );
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() => _selectedSegment = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _areaWithTablesCubit.close(); // Close Cubit to prevent leaks
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, null), // Return null if canceled
        ),
        title: const Text("Select Table"),
        bottom: _customTabBar(), // Use a method to build the tabs
        actions: [
          FilledButton(
            onPressed:
                _confirmEnabled
                    ? () {
                      Navigator.of(context).pop(_selectedTableId);
                    }
                    : null,
            style: FilledButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: 8.borderRadius),
            ),
            child: const Text("Confirm"),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocBuilder<AreaWithTablesCubit, AreaWithTablesState>(
          bloc: _areaWithTablesCubit,
          builder: (context, state) {
            if (state is AreaWithTablesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AreaWithTablesError) {
              return Center(child: Text("Error: ${state.failure.message}"));
            } else if (state is AreaWithTablesLoaded) {
              final areasWithTables = state.areasWithTables;
              if (_tabController.length != areasWithTables.length) {
                _tabController.removeListener(_handleTabSelection);
                _tabController.dispose();
                _tabController = TabController(
                  length: areasWithTables.length,
                  vsync: this,
                  initialIndex: _selectedSegment,
                );
                _tabController.addListener(_handleTabSelection);
              }

              return TabBarView(
                controller: _tabController,
                children:
                    areasWithTables.map((area) {
                      return _listTables(area, areasWithTables);
                    }).toList(),
              );
            }
            return const Center(child: Text("No data"));
          },
        ),
      ),
    );
  }

  // Method to build the TabBar dynamically.
  PreferredSizeWidget _customTabBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: BlocBuilder<AreaWithTablesCubit, AreaWithTablesState>(
        bloc: _areaWithTablesCubit,
        builder: (context, state) {
          if (state is AreaWithTablesLoaded) {
            final areasWithTables = state.areasWithTables;
            return SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List.generate(areasWithTables.length, (index) {
                  return InkWell(
                    onTap: () {
                      setState(() {
                        _selectedSegment = index;
                      });
                      _tabController.animateTo(index); // Use _tabController
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _selectedSegment == index ? Colors.blue : Colors.transparent,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        areasWithTables[index].name,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color:
                              _selectedSegment == index
                                  ? Colors.white
                                  : context.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  );
                }),
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  KeepAliveWrapper _listTables(
    AreaWithTablesEntity area,
    List<AreaWithTablesEntity> areasWithTables,
  ) {
    final List<TableEntity> availableTable = [];

    for (final area in areasWithTables) {
      for (final table in area.tables) {
        if (table.id != widget.order?.tableId && table.status != TableStatus.served) {
          availableTable.add(table);
        }
      }
    }

    final List<TableEntity> areas =
        area.tables
            .where((table) => availableTable.any((available) => available.id == table.id))
            .toList();

    return KeepAliveWrapper(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children:
                areas.map((table) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedTableId = table.id;
                        _confirmEnabled = true;
                      });
                    },
                    child:
                        _selectedTableId == table.id
                            ? Stack(
                              children: [
                                TableWidget(table: table),
                                Positioned.fill(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      color: Colors.black.opacityColor(0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.check, color: Colors.white, size: 48),
                                  ),
                                ),
                              ],
                            )
                            : TableWidget(table: table),
                  );
                }).toList(),
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true; // For AutomaticKeepAliveClientMixin
}
