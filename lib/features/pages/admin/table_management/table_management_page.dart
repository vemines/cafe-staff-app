import '../../../../core/extensions/build_content_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/app/locale.dart';
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
        context.tr(I18nKeys.tableManagement),
        bottom: TabBar(
          controller: _tabController,
          tabs: [Tab(text: context.tr(I18nKeys.areas)), Tab(text: context.tr(I18nKeys.tables))],
        ),
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_areaTab(context), _tableTab(context)],
        ),
      ),
    );
  }

  Widget _areaTab(BuildContext context) {
    return BlocProvider.value(
      value: _areaCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: context.tr(I18nKeys.areas),
            onPressed: () => _showCreateOrEditAreaDialog(context, null),
            buttonText: context.tr(I18nKeys.createArea),
          ),
          Expanded(
            child: BlocBuilder<AreaCubit, AreaState>(
              builder: (context, state) {
                if (state is AreaInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is AreaError) {
                  return Center(
                    child: Text(
                      context.tr(I18nKeys.errorWithMessage, {
                        'message': state.failure.message ?? 'Unknown error',
                      }),
                    ),
                  );
                } else if (state is AreaLoaded) {
                  final areas = state.areas;

                  return areas.isEmpty
                      ? Center(child: Text(context.tr(I18nKeys.noAreaForDisplay)))
                      : ListView.builder(
                        itemCount: areas.length,
                        itemBuilder: (context, index) {
                          final area = areas[index];
                          return _areaListTile(context, area);
                        },
                      );
                } else {
                  return Center(child: Text(context.tr(I18nKeys.noData)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _tableTab(BuildContext context) {
    return BlocProvider.value(
      value: _tableCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: context.tr(I18nKeys.tables),
            onPressed: () => _showCreateOrEditTableDialog(context, null),
            buttonText: context.tr(I18nKeys.createTable),
          ),
          sbH2,
          selectButton(
            onPressed: () => _showSelectAreaDialog(context),
            text: _selectedArea?.name ?? context.tr(I18nKeys.selectArea),
          ),
          Expanded(
            child: BlocBuilder<TableCubit, TableState>(
              builder: (context, state) {
                if (state is TableInitial) {
                  return const SizedBox.shrink();
                } else if (state is TableError) {
                  return Center(
                    child: Text(
                      context.tr(I18nKeys.errorWithMessage, {
                        'message': state.failure.message ?? 'Unknown error',
                      }),
                    ),
                  );
                } else if (state is TableLoaded) {
                  final tables = state.tables;
                  return tables.isEmpty
                      ? Center(child: Text(context.tr(I18nKeys.noTablesFoundForArea)))
                      : ListView.builder(
                        itemCount: tables.length,
                        itemBuilder: (context, index) {
                          final table = tables[index];
                          return _tableListTile(context, table);
                        },
                      );
                } else {
                  return Center(child: Text(context.tr(I18nKeys.noTablesFoundForArea)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _tableListTile(BuildContext context, TableEntity table) {
    return ListTile(
      title: Text(table.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: context.tr(I18nKeys.editTable),
            onPressed: () => _showCreateOrEditTableDialog(context, table),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: context.tr(I18nKeys.deleteTable),
            onPressed: () => _showDeleteTableDialog(context, table),
          ),
        ],
      ),
    );
  }

  ListTile _areaListTile(BuildContext context, AreaEntity area) {
    return ListTile(
      title: Text(area.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: context.tr(I18nKeys.editArea),
            onPressed: () => _showCreateOrEditAreaDialog(context, area),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: context.tr(I18nKeys.deleteArea),
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
    String title = isCreate ? context.tr(I18nKeys.createArea) : context.tr(I18nKeys.editArea);

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: name,
          decoration: InputDecoration(hintText: context.tr(I18nKeys.enterAreaName)),
          validator: (value) => value!.isEmpty ? context.tr(I18nKeys.pleaseEnterName) : null,
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
      title: context.tr(I18nKeys.confirmDelete),
      actionText: context.tr(I18nKeys.deleteArea),
      content: Text(context.tr(I18nKeys.confirmDeleteAreaMessage, {'areaName': area.name})),
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
    String title = isCreate ? context.tr(I18nKeys.createTable) : context.tr(I18nKeys.editTable);

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
              decoration: InputDecoration(hintText: context.tr(I18nKeys.enterTableName)),
              validator: (value) => value!.isEmpty ? context.tr(I18nKeys.require) : null,
            ),
          ],
        ),
      ),
      onAction: () {
        if (formKey.currentState!.validate() && initialAreaId.isNotEmpty) {
          if (isCreate) {
            _tableCubit.createTable(
              tableName: name.text,
              status: 'completed',
              areaId: initialAreaId,
            );
          } else {
            _tableCubit.updateTable(
              id: table.id,
              tableName: name.text,
              status: table.status.name,
              areaId: initialAreaId,
            );
          }
          context.pop();
        } else if (initialAreaId.isEmpty) {
          if (mounted) {
            context.snakebar(context.tr(I18nKeys.pleaseSelectAreaFirst));
          }
        }
      },
    );
  }

  Future<void> _showDeleteTableDialog(BuildContext context, TableEntity table) async {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.confirmDelete),
      actionText: context.tr(I18nKeys.deleteTable),
      content: Text(context.tr(I18nKeys.confirmDeleteTableMessage, {'tableName': table.name})),
      onAction: () {
        _tableCubit.deleteTable(id: table.id);
        context.pop();
      },
    );
  }

  void _showSelectAreaDialog(BuildContext context) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.selectArea),
      showAction: false,
      content: SingleChildScrollView(
        child: BlocBuilder<AreaCubit, AreaState>(
          bloc: _areaCubit,
          builder: (context, state) {
            if (state is AreaLoaded) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: state.areas.map((area) => _selectAreaListTile(context, area)).toList(),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  ListTile _selectAreaListTile(BuildContext context, AreaEntity area) {
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
