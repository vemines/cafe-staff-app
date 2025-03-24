// lib/features/pages/admin/menu_management/menu_management_page.dart
import 'package:cafe_staff_app/features/blocs/menu/menu_item_cubit.dart';
import 'package:cafe_staff_app/features/blocs/menu/sub_category_cubit.dart';
import 'package:cafe_staff_app/features/entities/menu_item_entity.dart';
import 'package:cafe_staff_app/features/entities/sub_category_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '/core/extensions/num_extensions.dart';
import '/core/widgets/dialog.dart';
import '/core/widgets/space.dart';
import '/features/entities/category_entity.dart';
import '/features/pages/admin/widgets/admin_appbar.dart';
import '/features/pages/admin/widgets/admin_drawer.dart';
import '/features/pages/admin/widgets/header_row_with_create_button.dart';
import '/features/pages/admin/widgets/select_button.dart';
import '../../../../injection_container.dart';
import '../../../blocs/menu/category_cubit.dart';
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
        'Menu Management',
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Categories'),
            Tab(text: 'Subcategories'),
            Tab(text: 'Menu Items'),
          ],
        ),
      ),
      drawer: const AdminDrawer(),
      body: SafeArea(
        child: TabBarView(
          controller: _tabController,
          children: [_categoriesTab(), _subcategoriesTab(), _menuItemsTab()],
        ),
      ),
    );
  }

  Widget _categoriesTab() {
    return BlocProvider.value(
      value: _categoryCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: "Category",
            onPressed: () => _showCreateOrEditCategoryDialog(null),
            buttonText: 'Create Category',
          ),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is CategoryError) {
                  return Center(child: Text('Error: ${state.failure.message}'));
                } else if (state is CategoryLoaded) {
                  final categories = state.categories;
                  return ListView.builder(
                    itemCount: categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return _categoryListTile(category);
                    },
                  );
                } else {
                  return const Center(child: Text('No categories found'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _categoryListTile(CategoryEntity category) {
    return ListTile(
      title: Text(category.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            text: "Edit Category",
            icon: Icons.edit,
            onPressed: () => _showCreateOrEditCategoryDialog(category),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: "Delete Menu",
            onPressed: () => _showDeleteCategoryDialog(category),
          ),
          activeCheckbox(
            isActive: category.isActive,
            onChanged: (value) => _updateCategoryStatus(category, value),
            textColor: _colorByStatus(category.isActive, Colors.green),
          ),
        ],
      ),
      onTap: () {
        _selectSubcategoriesForCategory(category);
      },
    );
  }

  void _selectSubcategoriesForCategory(CategoryEntity category) {
    showCustomizeDialog(
      context,
      showAction: false,
      title: 'Select Subcategories for ${category.name}',
      content: BlocBuilder<SubCategoryCubit, SubCategoryState>(
        bloc: _selectSubcategoryCubit,
        builder: (context, state) {
          if (state is SubCategoryLoaded) {
            final subcategories = state.subCategories;
            return subcategories.isNotEmpty
                ? _selectSubcategories(category, subcategories)
                : const Text("No subcategories found.");
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  ListView _selectSubcategories(CategoryEntity category, List<SubcategoryEntity> subcategories) {
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

  Widget _subcategoriesTab() {
    return BlocProvider.value(
      value: _subCategoryCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: "SubCategory",
            onPressed: () => _showCreateOrEditSubcategoryDialog(null),
            buttonText: 'Create SubCategory',
          ),
          sbH2,
          selectButton(
            onPressed: _showSelectCategoryDialog,
            text: _selectedCategory?.name ?? 'No category',
          ),
          Expanded(
            child: BlocBuilder<SubCategoryCubit, SubCategoryState>(
              builder: (context, state) {
                if (state is SubCategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is SubCategoryError) {
                  return Center(child: Text('Error: ${state.failure.message}'));
                } else if (state is SubCategoryLoaded) {
                  final subcategories = state.subCategories;

                  return subcategories.isEmpty
                      ? Center(
                        child: Text(
                          _selectedCategory == null
                              ? "No Category Selected"
                              : "No Subcategory for ${_selectedCategory!.name}",
                        ),
                      )
                      : ListView.builder(
                        itemCount: subcategories.length,
                        itemBuilder: (context, index) {
                          final subcategory = subcategories[index];
                          return _subcategoryListTile(subcategory, context);
                        },
                      );
                } else {
                  return const Center(child: Text('No subcategories found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _subcategoryListTile(SubcategoryEntity subcategory, BuildContext context) {
    return ListTile(
      title: Text(subcategory.name),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: "Edit Subcategory",
            onPressed: () => _showCreateOrEditSubcategoryDialog(subcategory),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: "Delete Subcategory",
            onPressed: () => _showDeleteSubcategoryDialog(subcategory),
          ),
          activeCheckbox(
            isActive: subcategory.isActive,
            onChanged: (value) => _updateSubcategoryStatus(subcategory, value),
            textColor: _colorByStatus(subcategory.isActive, Colors.green),
          ),
        ],
      ),
      onTap: () {
        _selectMenuItemsForSubcategory(subcategory);
      },
    );
  }

  void _selectMenuItemsForSubcategory(SubcategoryEntity subcategory) {
    showCustomizeDialog(
      context,
      showAction: false,
      title: 'Menu Items for ${subcategory.name}',
      content: BlocBuilder<MenuItemCubit, MenuItemState>(
        bloc: _selectMenuItemCubit,
        builder: (context, state) {
          if (state is MenuItemLoaded) {
            final menuItems = state.menuItems;
            return menuItems.isNotEmpty
                ? _selectMenuItems(subcategory, menuItems)
                : const Text("No menu items found.");
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }

  ListView _selectMenuItems(SubcategoryEntity subcategory, List<MenuItemEntity> menuItems) {
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

  Widget _menuItemsTab() {
    return BlocProvider.value(
      value: _menuItemCubit,
      child: Column(
        children: [
          headerRowWithCreateButton(
            title: "Menu Items",
            onPressed: () => _showCreateOrEditMenuItemDialog(null),
            buttonText: 'Create MenuItem',
          ),
          sbH2,
          selectButton(
            onPressed: _showSelectSubcategoryDialog,
            text: _selectedSubcategory?.name ?? 'No Subcategory',
          ),
          Expanded(
            child: BlocBuilder<MenuItemCubit, MenuItemState>(
              builder: (context, state) {
                if (state is MenuItemLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is MenuItemError) {
                  return Center(child: Text('Error: ${state.failure.message}'));
                } else if (state is MenuItemLoaded) {
                  final menuItems = state.menuItems;

                  return menuItems.isEmpty
                      ? Center(
                        child: Text(
                          _selectedSubcategory == null
                              ? "No Subcategory Selected"
                              : "No MenuItem for ${_selectedSubcategory!.name}",
                        ),
                      )
                      : ListView.builder(
                        itemCount: menuItems.length,
                        itemBuilder: (context, index) {
                          final menuItem = menuItems[index];
                          return _menuItemListTile(menuItem);
                        },
                      );
                } else {
                  return const Center(child: Text('No menu items found.'));
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  ListTile _menuItemListTile(MenuItemEntity menuItem) {
    return ListTile(
      title: Text(menuItem.name),
      subtitle: Text('\$${menuItem.price.shortMoneyString}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          actionIcon(
            context: context,
            icon: Icons.edit,
            text: "Edit Menu",
            onPressed: () => _showCreateOrEditMenuItemDialog(menuItem),
          ),
          actionIcon(
            context: context,
            icon: Icons.delete,
            text: "Delete Menu",
            onPressed: () => _showDeleteMenuItemDialog(menuItem),
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

  void _showCreateOrEditCategoryDialog(CategoryEntity? category) {
    final name = TextEditingController(text: category?.name);
    bool isCreate = category == null;
    String title = isCreate ? 'Create Category' : 'Edit Category';

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
        decoration: const InputDecoration(hintText: "Enter category name"),
      ),
    );
  }

  void _showDeleteCategoryDialog(CategoryEntity category) {
    showCustomizeDialog(
      context,
      title: 'Confirm Delete',
      actionText: 'Delete Category',
      content: Text('Are you sure you want to delete this category ${category.name}?'),
      onAction: () {
        _categoryCubit.deleteCategory(id: category.id);
        context.pop();
      },
    );
  }

  void _showSelectCategoryDialog() {
    showCustomizeDialog(
      context,
      showAction: false,
      title: 'Select Category',
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
            return const Center(child: Text("No Categories to display."));
          }
        },
      ),
    );
  }

  void _showSelectSubcategoryDialog() {
    showCustomizeDialog(
      context,
      showAction: false,
      title: 'Select SubCategory',
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
            return const Center(child: Text("No subCategories to display."));
          }
        },
      ),
    );
  }

  void _showCreateOrEditSubcategoryDialog(SubcategoryEntity? subcategory) {
    final name = TextEditingController(text: subcategory?.name);
    bool isCreate = subcategory == null;
    String title = isCreate ? 'Create Subcategory' : 'Edit Subcategory';

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      onAction: () {
        if (name.text.isNotEmpty) {
          isCreate
              ? _subCategoryCubit.createSubCategory(
                name: name.text,
                categoryId: _selectedCategory!.id,
              )
              : _subCategoryCubit.updateSubCategory(
                id: subcategory.id,
                name: name.text,
                categoryId: _selectedCategory!.id,
              );
          _selectSubcategoryCubit.getAllSubCategories();
          context.pop();
        }
      },
      content: TextField(
        controller: name,
        decoration: const InputDecoration(hintText: "Enter category name"),
      ),
    );
  }

  void _showDeleteSubcategoryDialog(SubcategoryEntity subcategory) {
    showCustomizeDialog(
      context,
      title: 'Confirm Delete',
      actionText: 'Delete Subcategory',
      content: Text('Are you sure you want to delete this subcategory ${subcategory.name}?'),
      onAction: () {
        _subCategoryCubit.deleteSubCategory(id: subcategory.id, categoryId: subcategory.category);
        context.pop();
      },
    );
  }

  void _showCreateOrEditMenuItemDialog(MenuItemEntity? menuItem) {
    final name = TextEditingController(text: menuItem?.name);
    final price = TextEditingController(text: menuItem?.price.toString());
    bool isCreate = menuItem == null;
    String title = isCreate ? 'Create MenuItem' : 'Edit MenuItem';

    showCustomizeDialog(
      context,
      title: title,
      actionText: title,
      onAction: () {
        if (name.text.isNotEmpty) {
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
        }
      },
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: name,
            decoration: const InputDecoration(hintText: "Enter menu item name"),
          ),
          TextField(
            controller: price,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: "Enter item price"),
          ),
        ],
      ),
    );
  }

  void _showDeleteMenuItemDialog(MenuItemEntity menuItem) {
    showCustomizeDialog(
      context,
      title: 'Confirm Delete',
      actionText: 'Delete MenuItem',
      content: Text('Are you sure you want to delete this category ${menuItem.name}?'),
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
