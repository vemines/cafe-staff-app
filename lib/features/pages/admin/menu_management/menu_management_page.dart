import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/app/locale.dart';
import '/core/extensions/num_extensions.dart';
import '/core/widgets/dialog.dart';
import '/core/widgets/space.dart';
import '/features/entities/category_entity.dart';
import '/features/pages/admin/widgets/admin_appbar.dart';
import '/features/pages/admin/widgets/admin_drawer.dart';
import '/features/pages/admin/widgets/header_row_with_create_button.dart';
import '/features/pages/admin/widgets/select_button.dart';
import '../../../../core/extensions/build_content_extensions.dart';
import '../../../../injection_container.dart';
import '../../../blocs/menu/category_cubit.dart';
import '../../../blocs/menu/menu_item_cubit.dart';
import '../../../blocs/menu/sub_category_cubit.dart';
import '../../../entities/menu_item_entity.dart';
import '../../../entities/sub_category_entity.dart';
import '../../../models/category_model.dart';
import '../../../models/sub_category_model.dart';
import '../widgets/action_icon.dart';
import '../widgets/active_checkbox.dart';

class MenuManagementPage extends StatefulWidget {
  const MenuManagementPage({super.key});

  @override
  State<MenuManagementPage> createState() => _MenuManagementPageState();
}

class _MenuManagementPageState extends State<MenuManagementPage>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  late CategoryCubit _categoryCubit;
  late SubCategoryCubit _subCategoryCubit;
  late MenuItemCubit _menuItemCubit;

  late SubCategoryCubit _selectSubcategoryCubit;
  late MenuItemCubit _selectMenuItemCubit;

  CategoryEntity? _selectedCategory;
  SubcategoryEntity? _selectedSubcategory;

  final noCategory = CategoryModel(id: '', name: "No Category", isActive: false);
  final noSubcategory = SubCategoryModel(
    id: '',
    name: "No Subcategory",
    category: '',
    items: [],
    isActive: false,
  );

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _categoryCubit = sl<CategoryCubit>();
    _subCategoryCubit = sl<SubCategoryCubit>();
    _menuItemCubit = sl<MenuItemCubit>();
    _selectSubcategoryCubit = sl<SubCategoryCubit>()..getAllSubCategories();
    _selectMenuItemCubit = sl<MenuItemCubit>()..getAllMenuItems();
    initLoad();
  }

  void initLoad() async {
    await _categoryCubit.getAllCategories();
    await _subCategoryCubit.getAllSubCategories();
    await _menuItemCubit.getAllMenuItems();

    if (_categoryCubit.state is CategoryLoaded && _selectedCategory == null) {
      final categories = (_categoryCubit.state as CategoryLoaded).categories;
      if (categories.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _selectedCategory = categories.first);
        });
        _subCategoryCubit.filterSubCategoriesByCategory(categories.first.id);
      }
    }

    if (_subCategoryCubit.state is SubCategoryLoaded && _selectedSubcategory == null) {
      final subCategories = (_subCategoryCubit.state as SubCategoryLoaded).subCategories;
      if (subCategories.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          setState(() => _selectedSubcategory = subCategories.first);
        });
        _menuItemCubit.filterMenuItemsBySubCategory(subCategories.first.id);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _categoryCubit.close();
    _subCategoryCubit.close();
    _menuItemCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: adminAppBar(
        _scaffoldKey,
        context.tr(I18nKeys.menuManagement),
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: context.tr(I18nKeys.categories)),
            Tab(text: context.tr(I18nKeys.subcategories)),
            Tab(text: context.tr(I18nKeys.menuItems)),
          ],
        ),
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_categoriesTab(context), _subcategoriesTab(context), _menuItemsTab(context)],
        ),
      ),
    );
  }

  Widget _categoriesTab(BuildContext context) {
    return BlocProvider.value(
      value: _categoryCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: context.tr(I18nKeys.categories),
            onPressed: () => _showCreateOrEditCategoryDialog(context, null),
            buttonText: context.tr(I18nKeys.createCategory),
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoryInitial) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryError) {
                  return Center(
                    child: Text(
                      context.tr(I18nKeys.errorWithMessage, {
                        'message': state.failure.message ?? 'Unknown error',
                      }),
                    ),
                  );
                } else if (state is CategoryLoaded) {
                  final categories = state.categories;
                  return categories.isEmpty
                      ? Center(child: Text(context.tr(I18nKeys.noCategoriesFound)))
                      : ListView.builder(
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          final category = categories[index];
                          return _categoryListTile(context, category);
                        },
                      );
                } else {
                  return Center(child: Text(context.tr(I18nKeys.noCategoriesFound)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _categoryListTile(BuildContext context, CategoryEntity category) {
    return ListTile(
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            text: context.tr(I18nKeys.editCategory),
            icon: Icons.edit,
            onPressed: () => _showCreateOrEditCategoryDialog(context, category),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: context.tr(I18nKeys.deleteCategory),
            onPressed: () => _showDeleteCategoryDialog(context, category),
          ),
          activeCheckbox(
            isActive: category.isActive,
            onChanged: (value) => _updateCategoryStatus(category, value),
            textColor: _colorByStatus(category.isActive, Colors.green),
          ),
        ],
      ),
      onTap: () {
        _selectSubcategoriesForCategory(context, category);
      },
    );
  }

  void _selectSubcategoriesForCategory(BuildContext context, CategoryEntity category) {
    showCustomizeDialog(
      context,
      showAction: false,
      title: context.tr(I18nKeys.selectSubcategoriesFor, {'categoryName': category.name}),
      content: BlocBuilder<SubCategoryCubit, SubCategoryState>(
        bloc: _selectSubcategoryCubit,
        builder: (context, state) {
          if (state is SubCategoryLoaded) {
            final subcategories = state.subCategories;
            return subcategories.isNotEmpty
                ? _selectSubcategories(context, category, subcategories)
                : Text(context.tr(I18nKeys.noSubcategoriesFound));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  ListView _selectSubcategories(
    BuildContext context,
    CategoryEntity category,
    List<SubcategoryEntity> subcategories,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: subcategories.length,
      itemBuilder: (context, index) {
        final subcategory = subcategories[index];
        final currentCategory = (_categoryCubit.state as CategoryLoaded).categories.firstWhere(
          (e) => e.id == subcategory.category,
          orElse: () => noCategory,
        );

        return CheckboxListTile(
          title: Text(subcategory.name),
          subtitle: Text(currentCategory.name),
          value: subcategory.category == category.id,
          onChanged: (value) {
            _subCategoryCubit.updateSubCategory(
              id: subcategory.id,
              categoryId: value == true ? category.id : '',
            );
            _subCategoryCubit.getAllSubCategories();
            _selectSubcategoryCubit.getAllSubCategories();
          },
        );
      },
    );
  }

  Widget _subcategoriesTab(BuildContext context) {
    return BlocProvider.value(
      value: _subCategoryCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: context.tr(I18nKeys.subcategories),
            onPressed: () => _showCreateOrEditSubcategoryDialog(context, null),
            buttonText: context.tr(I18nKeys.createSubcategory),
          ),
          sbH2,
          selectButton(
            onPressed: () => _showSelectCategoryDialog(context),
            text: _selectedCategory?.name ?? context.tr(I18nKeys.selectCategory),
          ),
          Expanded(
            child: BlocBuilder<SubCategoryCubit, SubCategoryState>(
              builder: (context, state) {
                if (state is SubCategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SubCategoryError) {
                  return Center(
                    child: Text(
                      context.tr(I18nKeys.errorWithMessage, {
                        'message': state.failure.message ?? 'Unknown error',
                      }),
                    ),
                  );
                } else if (state is SubCategoryLoaded) {
                  final subcategories = state.subCategories;

                  return subcategories.isEmpty
                      ? Center(
                        child: Text(
                          _selectedCategory == null
                              ? context.tr(I18nKeys.noCategorySelected)
                              : context.tr(I18nKeys.noSubcategoryFor, {
                                'categoryName': _selectedCategory!.name,
                              }),
                        ),
                      )
                      : ListView.builder(
                        itemCount: subcategories.length,
                        itemBuilder: (context, index) {
                          final subcategory = subcategories[index];
                          return _subcategoryListTile(context, subcategory);
                        },
                      );
                } else {
                  return Center(child: Text(context.tr(I18nKeys.noSubcategoriesFound)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _subcategoryListTile(BuildContext context, SubcategoryEntity subcategory) {
    return ListTile(
      title: Text(subcategory.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: context.tr(I18nKeys.editSubcategory),
            onPressed: () => _showCreateOrEditSubcategoryDialog(context, subcategory),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: context.tr(I18nKeys.deleteSubcategory),
            onPressed: () => _showDeleteSubcategoryDialog(context, subcategory),
          ),
          activeCheckbox(
            isActive: subcategory.isActive,
            onChanged: (value) => _updateSubcategoryStatus(subcategory, value),
            textColor: _colorByStatus(subcategory.isActive, Colors.green),
          ),
        ],
      ),
      onTap: () {
        _selectMenuItemsForSubcategory(context, subcategory);
      },
    );
  }

  void _selectMenuItemsForSubcategory(BuildContext context, SubcategoryEntity subcategory) {
    showCustomizeDialog(
      context,
      showAction: false,
      title: '${context.tr(I18nKeys.menuItems)} for ${subcategory.name}',
      content: BlocBuilder<MenuItemCubit, MenuItemState>(
        bloc: _selectMenuItemCubit,
        builder: (context, state) {
          if (state is MenuItemLoaded) {
            final menuItems = state.menuItems;
            return menuItems.isNotEmpty
                ? _selectMenuItems(context, subcategory, menuItems)
                : Text(context.tr(I18nKeys.noMenuItemsFound));
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  ListView _selectMenuItems(
    BuildContext context,
    SubcategoryEntity subcategory,
    List<MenuItemEntity> menuItems,
  ) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: menuItems.length,
      itemBuilder: (context, index) {
        final menuItem = menuItems[index];
        final currentSubCategory = (_subCategoryCubit.state as SubCategoryLoaded).subCategories
            .firstWhere((e) => e.id == menuItem.subCategory, orElse: () => noSubcategory);

        return CheckboxListTile(
          title: Text(menuItem.name),
          subtitle: Text(currentSubCategory.name),
          value: menuItem.subCategory == subcategory.id,
          onChanged: (value) {
            _menuItemCubit.updateMenuItem(
              id: menuItem.id,
              subCategoryId: value == true ? subcategory.id : '',
            );
            _selectMenuItemCubit.getAllMenuItems();
          },
        );
      },
    );
  }

  Widget _menuItemsTab(BuildContext context) {
    return BlocProvider.value(
      value: _menuItemCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: context.tr(I18nKeys.menuItems),
            onPressed: () => _showCreateOrEditMenuItemDialog(context, null),
            buttonText: context.tr(I18nKeys.createMenuItem),
          ),
          sbH2,
          selectButton(
            onPressed: () => _showSelectSubcategoryDialog(context),
            text: _selectedSubcategory?.name ?? context.tr(I18nKeys.selectSubcategory),
          ),
          Expanded(
            child: BlocBuilder<MenuItemCubit, MenuItemState>(
              builder: (context, state) {
                if (state is MenuItemLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MenuItemError) {
                  return Center(
                    child: Text(
                      context.tr(I18nKeys.errorWithMessage, {
                        'message': state.failure.message ?? 'Unknown error',
                      }),
                    ),
                  );
                } else if (state is MenuItemLoaded) {
                  final menuItems = state.menuItems;

                  return menuItems.isEmpty
                      ? Center(
                        child: Text(
                          _selectedSubcategory == null
                              ? context.tr(I18nKeys.noSubcategorySelected)
                              : context.tr(I18nKeys.noMenuItemFor, {
                                'subcategoryName': _selectedSubcategory!.name,
                              }),
                        ),
                      )
                      : ListView.builder(
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          final menuItem = menuItems[index];
                          return _menuItemListTile(context, menuItem);
                        },
                      );
                } else {
                  return Center(child: Text(context.tr(I18nKeys.noMenuItemsFound)));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _menuItemListTile(BuildContext context, MenuItemEntity menuItem) {
    return ListTile(
      title: Text(menuItem.name),
      subtitle: Text('\$${menuItem.price.shortMoneyString}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: context.tr(I18nKeys.editMenuItem),
            onPressed: () => _showCreateOrEditMenuItemDialog(context, menuItem),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: context.tr(I18nKeys.deleteMenuItem),
            onPressed: () => _showDeleteMenuItemDialog(context, menuItem),
          ),
          activeCheckbox(
            isActive: menuItem.isActive,
            textColor: _colorByStatus(menuItem.isActive, Colors.green),
            onChanged: (value) => _updateMenuItemStatus(menuItem, value),
          ),
        ],
      ),
    );
  }

  Color? _colorByStatus(bool active, Color? activeColor) => active ? activeColor : Colors.grey;

  void _showCreateOrEditCategoryDialog(BuildContext context, CategoryEntity? category) {
    final name = TextEditingController(text: category?.name);
    bool isCreate = category == null;
    String title =
        isCreate ? context.tr(I18nKeys.createCategory) : context.tr(I18nKeys.editCategory);

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      onAction: () {
        if (name.text.isNotEmpty) {
          isCreate
              ? _categoryCubit.createCategory(name: name.text)
              : _categoryCubit.updateCategory(
                id: category.id,
                name: name.text,
                isActive: category.isActive,
              );
          context.pop();
        }
      },
      content: TextField(
        controller: name,
        decoration: InputDecoration(hintText: context.tr(I18nKeys.enterCategoryName)),
      ),
    );
  }

  void _showDeleteCategoryDialog(BuildContext context, CategoryEntity category) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.confirmDelete),
      actionText: context.tr(I18nKeys.deleteCategory),
      content: Text(
        context.tr(I18nKeys.confirmDeleteCategoryMessage, {'categoryName': category.name}),
      ),
      onAction: () {
        _categoryCubit.deleteCategory(id: category.id);
        context.pop();
      },
    );
  }

  void _showSelectCategoryDialog(BuildContext context) {
    showCustomizeDialog(
      context,
      showAction: false,
      title: context.tr(I18nKeys.selectCategory),
      content: BlocBuilder<CategoryCubit, CategoryState>(
        bloc: _categoryCubit,
        builder: (context, state) {
          if (state is CategoryLoaded) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    state.categories.map((category) {
                      return ListTile(
                        title: Text(category.name),
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                          _subCategoryCubit.filterSubCategoriesByCategory(category.id);
                          context.pop();
                        },
                        trailing:
                            _selectedCategory?.id == category.id ? const Icon(Icons.check) : null,
                      );
                    }).toList(),
              ),
            );
          } else {
            return Center(child: Text(context.tr(I18nKeys.noCategoriesFound)));
          }
        },
      ),
    );
  }

  void _showSelectSubcategoryDialog(BuildContext context) {
    showCustomizeDialog(
      context,
      showAction: false,
      title: context.tr(I18nKeys.selectSubcategory),
      content: BlocBuilder<SubCategoryCubit, SubCategoryState>(
        bloc: _selectSubcategoryCubit,
        builder: (context, state) {
          if (state is SubCategoryLoaded) {
            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children:
                    state.subCategories.map((sub) {
                      return ListTile(
                        title: Text(sub.name),
                        onTap: () {
                          setState(() {
                            _selectedSubcategory = sub;
                          });
                          _menuItemCubit.filterMenuItemsBySubCategory(sub.id);
                          context.pop();
                        },
                        trailing:
                            _selectedSubcategory?.id == sub.id ? const Icon(Icons.check) : null,
                      );
                    }).toList(),
              ),
            );
          } else {
            return Center(child: Text(context.tr(I18nKeys.noSubcategoriesToDisplay)));
          }
        },
      ),
    );
  }

  void _showCreateOrEditSubcategoryDialog(BuildContext context, SubcategoryEntity? subcategory) {
    final name = TextEditingController(text: subcategory?.name);
    bool isCreate = subcategory == null;
    String title =
        isCreate ? context.tr(I18nKeys.createSubcategory) : context.tr(I18nKeys.editSubcategory);

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      onAction: () {
        if (name.text.isNotEmpty && _selectedCategory != null) {
          isCreate
              ? _subCategoryCubit.createSubCategory(
                name: name.text,
                categoryId: _selectedCategory!.id,
              )
              : _subCategoryCubit.updateSubCategory(
                id: subcategory.id,
                name: name.text,
                categoryId: _selectedCategory!.id,
                isActive: subcategory.isActive,
              );
          _selectSubcategoryCubit.getAllSubCategories();
          context.pop();
        } else if (_selectedCategory == null) {
          context.snakebar(context.tr(I18nKeys.noCategorySelected));
        }
      },
      content: TextField(
        controller: name,
        decoration: InputDecoration(hintText: context.tr(I18nKeys.enterCategoryName)),
      ),
    );
  }

  void _showDeleteSubcategoryDialog(BuildContext context, SubcategoryEntity subcategory) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.confirmDelete),
      actionText: context.tr(I18nKeys.deleteSubcategory),
      content: Text(
        context.tr(I18nKeys.confirmDeleteSubcategoryMessage, {'subcategoryName': subcategory.name}),
      ),
      onAction: () {
        _subCategoryCubit.deleteSubCategory(id: subcategory.id, categoryId: subcategory.category);
        context.pop();
      },
    );
  }

  void _showCreateOrEditMenuItemDialog(BuildContext context, MenuItemEntity? menuItem) {
    final name = TextEditingController(text: menuItem?.name);
    final price = TextEditingController(text: menuItem?.price.toString());
    bool isCreate = menuItem == null;
    String title =
        isCreate ? context.tr(I18nKeys.createMenuItem) : context.tr(I18nKeys.editMenuItem);

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      onAction: () {
        if (name.text.isNotEmpty && _selectedSubcategory != null) {
          isCreate
              ? _menuItemCubit.createMenuItem(
                name: name.text,
                subCategory: _selectedSubcategory!.id,
                price: double.parse(price.text),
              )
              : _menuItemCubit.updateMenuItem(
                id: menuItem.id,
                name: name.text,
                subCategoryId: _selectedSubcategory!.id,
                price: double.parse(price.text),
                isActive: menuItem.isActive,
              );
          _selectMenuItemCubit.getAllMenuItems();
          context.pop();
        } else if (_selectedSubcategory == null) {
          context.snakebar(context.tr(I18nKeys.noSubcategorySelected));
        }
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            decoration: InputDecoration(hintText: context.tr(I18nKeys.enterMenuItemName)),
          ),
          TextField(
            controller: price,
            keyboardType: TextInputType.number,
            decoration: InputDecoration(hintText: context.tr(I18nKeys.enterItemPrice)),
          ),
        ],
      ),
    );
  }

  void _showDeleteMenuItemDialog(BuildContext context, MenuItemEntity menuItem) {
    showCustomizeDialog(
      context,
      title: context.tr(I18nKeys.confirmDelete),
      actionText: context.tr(I18nKeys.deleteMenuItem),
      content: Text(
        context.tr(I18nKeys.confirmDeleteMenuItemMessage, {'menuItemName': menuItem.name}),
      ),
      onAction: () {
        _menuItemCubit.deleteMenuItem(id: menuItem.id, subcategoryId: menuItem.subCategory);
        context.pop();
      },
    );
  }

  void _updateCategoryStatus(CategoryEntity category, bool value) {
    _categoryCubit.updateCategory(id: category.id, isActive: value);
  }

  void _updateSubcategoryStatus(SubcategoryEntity subcategory, bool value) {
    _subCategoryCubit.updateSubCategory(id: subcategory.id, isActive: value);
  }

  void _updateMenuItemStatus(MenuItemEntity menuItem, bool value) {
    _menuItemCubit.updateMenuItem(id: menuItem.id, isActive: value);
  }
}
