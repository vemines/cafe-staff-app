import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/app/locale.dart';
import '/core/extensions/num_extensions.dart';
import '/features/blocs/table/area_with_tables_cubit.dart';
import '/features/entities/area_with_table_entity.dart';
import '/injection_container.dart';
import '../../../../core/constants/enum.dart';
import '../../../../core/extensions/color_extensions.dart';
import '../widgets/table.dart';

class SelectTablePage extends StatefulWidget {
  const SelectTablePage({super.key, required this.isSplit});
  final bool isSplit;

  @override
  SelectTablePageState createState() => SelectTablePageState();
}

class SelectTablePageState extends State<SelectTablePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  late TabController _tabController;
  int _selectedSegment = 0;

  String? _selectedTableId;
  bool _confirmEnabled = false;
  late AreaWithTablesCubit _areaWithTablesCubit;
  @override
  void initState() {
    super.initState();
    _areaWithTablesCubit = sl<AreaWithTablesCubit>()..getAreasWithTables();
    if (_areaWithTablesCubit.state is! AreaWithTablesLoaded) {
      _areaWithTablesCubit.getAreasWithTables();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTabController();
    });
  }

  void _initializeTabController() {
    final state = _areaWithTablesCubit.state;
    int length = 0;
    if (state is AreaWithTablesLoaded) {
      length = state.areasWithTables.length;
    }
    _tabController = TabController(length: length, vsync: this, initialIndex: _selectedSegment);
    _tabController.addListener(_handleTabSelection);
    if (mounted) setState(() {});
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging && mounted) {
      setState(() => _selectedSegment = _tabController.index);
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
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
          onPressed: () => Navigator.pop(context, null),
        ),
        title: Text(context.tr(I18nKeys.selectTable)),
        bottom: _customTabBar(context),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: FilledButton(
              onPressed:
                  _confirmEnabled
                      ? () {
                        context.pop(_selectedTableId);
                      }
                      : null,
              style: FilledButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: 8.borderRadius),
              ),
              child: Text(context.tr(I18nKeys.confirm)),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: BlocConsumer<AreaWithTablesCubit, AreaWithTablesState>(
          bloc: _areaWithTablesCubit,
          listener: (context, state) {
            // Re-initialize TabController if the number of areas changes
            if (state is AreaWithTablesLoaded &&
                _tabController.length != state.areasWithTables.length) {
              _initializeTabController();
            }
          },
          builder: (context, state) {
            if (state is AreaWithTablesLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is AreaWithTablesError) {
              return Center(
                child: Text(
                  context.tr(I18nKeys.errorWithMessage, {
                    'message': state.failure.message ?? 'Unknown error',
                  }),
                ),
              );
            } else if (state is AreaWithTablesLoaded) {
              final areasWithTables = state.areasWithTables;
              // Ensure controller length matches before building TabBarView
              if (_tabController.length != areasWithTables.length) {
                return const Center(child: CircularProgressIndicator());
              }

              return IndexedStack(
                index: _selectedSegment,
                children:
                    areasWithTables.map((area) {
                      return _listTables(context, area);
                    }).toList(),
              );
            }
            return Center(child: Text(context.tr(I18nKeys.noData)));
          },
        ),
      ),
    );
  }

  PreferredSizeWidget _customTabBar(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: BlocBuilder<AreaWithTablesCubit, AreaWithTablesState>(
        bloc: _areaWithTablesCubit,
        builder: (context, state) {
          if (state is AreaWithTablesLoaded) {
            final areasWithTables = state.areasWithTables;
            // Ensure controller length matches before building TabBar
            if (_tabController.length != areasWithTables.length) return const SizedBox.shrink();
            return TabBar(
              controller: _tabController,
              isScrollable: true,
              tabs: areasWithTables.map((area) => Tab(text: area.name)).toList(),
              labelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              unselectedLabelStyle: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _listTables(BuildContext context, AreaWithTablesEntity area) {
    final tables = area.tables.where((item) {
      if (widget.isSplit) {
        return item.status == TableStatus.completed;
      } else {
        return item.status == TableStatus.pending || item.status == TableStatus.served;
      }
    });

    if (tables.isEmpty) {
      return Center(child: Text(context.tr(I18nKeys.noData)));
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children:
              tables.map((table) {
                bool isSelected = _selectedTableId == table.id;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedTableId = table.id;
                      _confirmEnabled = _selectedTableId != null;
                    });
                  },
                  child:
                      isSelected
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
    );
  }

  @override
  bool get wantKeepAlive => true;
}
