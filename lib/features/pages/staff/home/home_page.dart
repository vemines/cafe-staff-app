// Path: lib/features/page/staff/home/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/extensions/build_content_extensions.dart';
import '/core/widgets/keep_alive_wraper.dart';
import '/features/blocs/table/area_with_tables_cubit.dart';
import '/features/entities/area_with_table_entity.dart';
import '/features/entities/table_entity.dart';
import '/injection_container.dart';
import '../order/order_page.dart';
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
  late AreaWithTablesCubit _areaWithTablesCubit;

  @override
  void initState() {
    super.initState();
    _areaWithTablesCubit = sl<AreaWithTablesCubit>();
    _areaWithTablesCubit.getAreasWithTables();
    _tabController = TabController(length: 0, vsync: this, initialIndex: _selectedSegment);
    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() => _selectedSegment = _tabController.index);
    }
  }

  @override
  void dispose() {
    _areaWithTablesCubit.close();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Scaffold(
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
        title: _buildTabBar(),
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
              if (_tabController.length != areasWithTables.length) {
                // Very important.  Recreate TabController with correct length.
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
                      return _listTables(area);
                    }).toList(),
              );
            } else {
              return const Center(child: Text('No data'));
            }
          },
        ),
      ),
    );
  }

  Widget _buildTabBar() {
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
    );
  }

  KeepAliveWrapper _listTables(AreaWithTablesEntity area) {
    return KeepAliveWrapper(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Wrap(
            spacing: 24,
            runSpacing: 24,
            children: area.tables.map((table) => _table(table)).toList(),
          ),
        ),
      ),
    );
  }

  // Tap to navigate to the OrderPage
  GestureDetector _table(TableEntity table) {
    return GestureDetector(
      onTap: () {
        Navigator.of(
          context,
        ).push(MaterialPageRoute(builder: (context) => OrderPage(table: table)));
      },
      child: TableWidget(table: table),
    );
  }

  @override
  bool get wantKeepAlive => true; // Keep state alive
}
