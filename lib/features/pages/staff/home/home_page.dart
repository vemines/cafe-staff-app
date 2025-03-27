import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/paths.dart';
import '/core/extensions/build_content_extensions.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/keep_alive_wraper.dart';
import '/features/blocs/table/area_with_tables_cubit.dart';
import '/features/entities/area_with_table_entity.dart';
import '/features/entities/table_entity.dart';
import '/injection_container.dart';
import '../widgets/staff_drawer.dart';
import '../widgets/table.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage>
    with TickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  int _selectedSegment = 0;
  double _dragStartX = 0.0;
  final double _dragThreshold = 100;
  late AreaWithTablesCubit _areaWithTablesCubit;

  @override
  void initState() {
    super.initState();
    _areaWithTablesCubit = sl<AreaWithTablesCubit>()..getAreasWithTables();
    _tabController = TabController(length: 0, vsync: this, initialIndex: _selectedSegment);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return KeepAliveWrapper(
      child: Scaffold(
        key: _scaffoldKey,
        appBar: AppBar(
          forceMaterialTransparency: true,
          leading: IconButton(
            iconSize: 30,
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState!.openDrawer();
            },
          ),
          title: _buildTabBar(context),
        ),
        drawer: const StaffDrawer(),
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
                _tabController.dispose();
                _setTabController(state.areasWithTables.length);
                return GestureDetector(
                  onHorizontalDragStart: _handleHorizontalDragStart,
                  onHorizontalDragUpdate: _handleHorizontalDragUpdate,
                  child: IndexedStack(
                    index: _selectedSegment,
                    children:
                        areasWithTables.map((area) {
                          return _listTables(context, area);
                        }).toList(),
                  ),
                );
              } else {
                return const Center(child: Text('No data'));
              }
            },
          ),
        ),
      ),
    );
  }

  void _setTabController(int tab) {
    _tabController = TabController(length: tab, vsync: this, initialIndex: _selectedSegment);
    _tabController.addListener(_handleTabSelection);
  }

  Widget _buildTabBar(BuildContext context) {
    return BlocBuilder<AreaWithTablesCubit, AreaWithTablesState>(
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
                    setState(() => _selectedSegment = index);
                    _tabController.animateTo(index);
                  },
                  child: _areaTab(context, index, areasWithTables),
                );
              }),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  Container _areaTab(BuildContext context, int index, List<AreaWithTablesEntity> areasWithTables) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _selectedSegment == index ? Colors.blue : Colors.transparent,
        borderRadius: 4.borderRadius,
      ),
      child: Text(
        areasWithTables[index].name,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w500,
          color: _selectedSegment == index ? Colors.white : context.colorScheme.onSurface,
        ),
      ),
    );
  }

  Widget _listTables(BuildContext context, AreaWithTablesEntity area) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Wrap(
          spacing: 24,
          runSpacing: 24,
          children: area.tables.map((table) => _table(context, table)).toList(),
        ),
      ),
    );
  }

  GestureDetector _table(BuildContext context, TableEntity table) {
    return GestureDetector(
      onTap: () {
        context.push(Paths.order, extra: table);
      },
      child: TableWidget(table: table),
    );
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() => _selectedSegment = _tabController.index);
    }
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    double delta = details.globalPosition.dx - _dragStartX;
    final tabIndex = _tabController.index;

    if (delta > _dragThreshold) {
      if (tabIndex > 0) _tabController.animateTo(tabIndex - 1);
      _dragStartX = details.globalPosition.dx;
    } else if (delta < -_dragThreshold) {
      _tabController.animateTo(tabIndex + 1);
      _dragStartX = details.globalPosition.dx;
    }
  }

  @override
  bool get wantKeepAlive => true;
}
