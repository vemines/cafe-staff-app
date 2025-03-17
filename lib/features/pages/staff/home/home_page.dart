import 'package:cafe_staff_app/core/widgets/keep_alive.dart'; // Import KeepAliveWrapper
import '/core/extensions/build_content_extensions.dart';
import 'package:flutter/material.dart';
import '../../../entities/area_with_table_entity.dart';
import '../../../entities/user_entity.dart';
import '../../mock.dart';
import '../../staff/widgets/app_drawer.dart';
import '../../staff/widgets/table.dart';
import '../order/order_page.dart';

class HomePage extends StatefulWidget {
  final UserEntity user;

  const HomePage({super.key, required this.user});

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

  List<AreaWithTablesEntity> _areasWithTables = [];

  @override
  void initState() {
    super.initState();
    _areasWithTables = MockData.areaWithTables;

    _tabController = TabController(
      length: _areasWithTables.length,
      vsync: this,
      initialIndex: _selectedSegment,
    );

    _tabController.addListener(_handleTabSelection);
  }

  void _handleTabSelection() {
    if (_tabController.indexIsChanging) {
      setState(() {
        _selectedSegment = _tabController.index;
      });
    }
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleHorizontalDragStart(DragStartDetails details) {
    _dragStartX = details.globalPosition.dx;
  }

  void _handleHorizontalDragUpdate(DragUpdateDetails details) {
    double delta = details.globalPosition.dx - _dragStartX;

    if (delta > _dragThreshold) {
      if (_tabController.index > 0) {
        _tabController.animateTo(_tabController.index - 1);
      }
      _dragStartX = details.globalPosition.dx;
    } else if (delta < -_dragThreshold) {
      if (_tabController.index < _areasWithTables.length - 1) {
        _tabController.animateTo(_tabController.index + 1);
      }
      _dragStartX = details.globalPosition.dx;
    }
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
        title: _buildCustomTabBar(),
      ),
      drawer: AppDrawer(user: widget.user),
      body: SafeArea(
        child: GestureDetector(
          onHorizontalDragStart: _handleHorizontalDragStart,
          onHorizontalDragUpdate: _handleHorizontalDragUpdate,
          child: IndexedStack(
            index: _selectedSegment,
            children:
                _areasWithTables.map((area) {
                  return KeepAliveWrapper(
                    // Wrap the ENTIRE tab content
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Wrap(
                          runSpacing: 24,
                          spacing: 24,
                          children:
                              area.tables.map((table) {
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder:
                                            (context) => OrderPage(
                                              user: widget.user,
                                              table: table,
                                              order: table.order,
                                            ),
                                      ),
                                    );
                                  },
                                  child: TableWidget(table: table),
                                );
                              }).toList(),
                        ),
                      ),
                    ),
                  );
                }).toList(), // Use the pre-built list
          ),
        ),
      ),
    );
  }

  Widget _buildCustomTabBar() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_areasWithTables.length, (index) {
          return InkWell(
            onTap: () {
              setState(() {
                _selectedSegment = index;
              });
              _tabController.animateTo(index);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _selectedSegment == index ? Colors.blue : Colors.transparent,
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _areasWithTables[index].name,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: _selectedSegment == index ? Colors.white : context.colorScheme.onSurface,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
