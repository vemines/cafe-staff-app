import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/widgets/dialog.dart';
import '/core/widgets/space.dart';
import '/features/blocs/table/area_table_cubit.dart';
import '/features/blocs/table/table_cubit.dart';
import '/features/entities/area_entity.dart';
import '/features/entities/table_entity.dart';
import '/features/pages/admin/widgets/action_icon.dart';
import '/features/pages/admin/widgets/admin_appbar.dart';
import '/features/pages/admin/widgets/admin_drawer.dart';
import '/features/pages/admin/widgets/header_row_with_create_button.dart';
import '/features/pages/admin/widgets/select_button.dart';
import '/injection_container.dart';

class TableManagementPage extends StatefulWidget {
  const TableManagementPage({super.key});

  @override
  State<TableManagementPage> createState() => _TableManagementPageState();
}

class _TableManagementPageState extends State<TableManagementPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  AreaEntity? _selectedArea;
  late AreaCubit _areaCubit;
  late TableCubit _tableCubit;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _areaCubit = sl<AreaCubit>();
    _tableCubit = sl<TableCubit>();
    initLoad();
  }

  void initLoad() async {
    await _areaCubit.getAllArea();
    await _tableCubit.getAllTables();
    if (_areaCubit.state is AreaLoaded && _selectedArea == null) {
      final areas = (_areaCubit.state as AreaLoaded).areas;
      if (areas.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _selectedArea = areas.first);
        });
        _tableCubit.filterTablesByArea(areas.first.id);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _areaCubit.close();
    _tableCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: adminAppBar(
        _scaffoldKey,
        'Table Management',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [Tab(text: 'Areas'), Tab(text: 'Tables')],
        ),
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: TabBarView(controller: _tabController, children: [_areaTab(), _tableTab()]),
      ),
    );
  }

  Widget _areaTab() {
    return BlocProvider.value(
      value: _areaCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: "Areas",
            onPressed: () => _showCreateOrEditAreaDialog(context, null),
            buttonText: 'Create Area',
          ),
          Expanded(
            child: BlocBuilder<AreaCubit, AreaState>(
              builder: (context, state) {
                if (state is AreaLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AreaError) {
                  return Center(child: Text('Error: ${state.failure.message}'));
                } else if (state is AreaLoaded) {
                  final areas = state.areas;

                  return areas.isEmpty
                      ? Center(child: Text("No Area for Display"))
                      : ListView.builder(
                        itemCount: areas.length,
                        itemBuilder: (context, index) {
                          final area = areas[index];
                          return _areaListTile(area);
                        },
                      );
                } else {
                  return const Center(child: Text('No data.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableTab() {
    return BlocProvider.value(
      value: _tableCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: "Table",
            onPressed: () => _showCreateOrEditTableDialog(context, null),
            buttonText: "Create Table",
          ),
          sbH2,
          selectButton(
            onPressed: _showSelectAreaDialog,
            text: _selectedArea?.name ?? 'Select area',
          ),
          Expanded(
            child: BlocBuilder<TableCubit, TableState>(
              builder: (context, state) {
                if (state is TableLoading) {
                  return const SizedBox.shrink();
                } else if (state is TableError) {
                  return Center(child: Text('Error: ${state.failure.message}'));
                } else if (state is TableLoaded) {
                  final tables = state.tables;
                  return ListView.builder(
                    itemCount: tables.length,
                    itemBuilder: (context, index) {
                      final table = tables[index];
                      return _tableListTile(table);
                    },
                  );
                } else {
                  return const Center(child: Text('No tables found for the selected area.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _tableListTile(TableEntity table) {
    return ListTile(
      title: Text(table.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: "Edit Table",
            onPressed: () => _showCreateOrEditTableDialog(context, table),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: "Delete Table",
            onPressed: () => _showDeleteTableDialog(context, table),
          ),
        ],
      ),
    );
  }

  ListTile _areaListTile(AreaEntity area) {
    return ListTile(
      title: Text(area.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: "Edit Area",
            onPressed: () => _showCreateOrEditAreaDialog(context, area),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: "Delete Area",
            onPressed: () => _showDeleteAreaDialog(context, area),
          ),
        ],
      ),
      onTap: () {
        setState(() {
          _selectedArea = area;
        });
        _tableCubit.filterTablesByArea(area.id);
      },
    );
  }

  void _showCreateOrEditAreaDialog(BuildContext context, AreaEntity? area) {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: area?.name);

    bool isCreate = area == null;
    String title = isCreate ? 'Create Area' : 'Edit Area';

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: name,
          decoration: const InputDecoration(hintText: 'Enter area name'),
          validator: (value) => value!.isEmpty ? 'Please enter a name' : null,
        ),
      ),
      onAction: () {
        if (formKey.currentState!.validate()) {
          if (isCreate) {
            _areaCubit.createArea(name: name.text);
          } else {
            _areaCubit.updateArea(id: area.id, name: name.text);
          }
          context.pop();
        }
      },
    );
  }

  Future<void> _showDeleteAreaDialog(BuildContext context, AreaEntity area) async {
    showCustomizeDialog(
      context,
      title: 'Confirm Delete Area',
      actionText: "Delete Area",
      content: Text('Are you sure you want to delete this area ${area.name}?'),
      onAction: () {
        _areaCubit.deleteArea(id: area.id);
        context.pop();
      },
    );
  }

  void _showCreateOrEditTableDialog(BuildContext context, TableEntity? table) {
    final formKey = GlobalKey<FormState>();
    final name = TextEditingController(text: table?.name);

    bool isCreate = table == null;
    String title = isCreate ? 'Create Table' : 'Edit Table';

    final String initialAreaId = _selectedArea?.id ?? '';

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: name,
              decoration: const InputDecoration(hintText: 'Enter table name'),
              validator: (value) => value!.isEmpty ? "Required" : null,
            ),
          ],
        ),
      ),
      onAction: () {
        if (formKey.currentState!.validate() && initialAreaId.isNotEmpty) {
          if (isCreate) {
            _tableCubit.createTable(tableName: name.text, status: 'pending', areaId: initialAreaId);
          } else {
            _tableCubit.updateTable(
              id: table.id,
              tableName: name.text,
              status: 'pending',
              areaId: initialAreaId,
            );
          }
          context.pop();
        } else if (initialAreaId.isEmpty) {
          if (mounted) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(const SnackBar(content: Text("Please select an area first.")));
          }
        }
      },
    );
  }

  Future<void> _showDeleteTableDialog(BuildContext context, TableEntity table) async {
    showCustomizeDialog(
      context,
      title: 'Confirm Delete Table',
      actionText: "Delete Table",
      content: Text('Are you sure you want to delete this table (${table.name})?'),
      onAction: () {
        _tableCubit.deleteTable(id: table.id);
        context.pop();
      },
    );
  }

  void _showSelectAreaDialog() {
    showCustomizeDialog(
      context,
      title: 'Select area',
      showAction: false,
      content: SingleChildScrollView(
        child: BlocBuilder<AreaCubit, AreaState>(
          bloc: _areaCubit,
          builder: (context, state) {
            if (state is AreaLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: state.areas.map((area) => _selectAreaListTile(area)).toList(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  ListTile _selectAreaListTile(AreaEntity area) {
    return ListTile(
      title: Text(area.name),
      onTap: () {
        setState(() {
          _selectedArea = area;
        });
        _tableCubit.filterTablesByArea(area.id);
        Navigator.of(context).pop();
      },
      trailing: _selectedArea?.id == area.id ? const Icon(Icons.check) : null,
    );
  }
}
