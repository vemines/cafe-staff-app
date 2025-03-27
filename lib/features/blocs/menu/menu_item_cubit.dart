import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/menu_item_entity.dart';
import '../../usecases/menu/create_menu_item_usecase.dart';
import '../../usecases/menu/delete_menu_item_usecase.dart';
import '../../usecases/menu/get_all_menu_items_usecase.dart';
import '../../usecases/menu/update_menu_item_usecase.dart';

part 'menu_item_state.dart';

class MenuItemCubit extends Cubit<MenuItemState> {
  final GetAllMenuItemsUseCase getAllMenuItemsUseCase;
  final CreateMenuItemUsecase createMenuItemUseCase;
  final UpdateMenuItemUseCase updateMenuItemUseCase;
  final DeleteMenuItemUseCase deleteMenuItemUseCase;

  List<MenuItemEntity> _allMenuItems = [];
  String? _selectedSubcategoryId;

  MenuItemCubit({
    required this.getAllMenuItemsUseCase,
    required this.createMenuItemUseCase,
    required this.updateMenuItemUseCase,
    required this.deleteMenuItemUseCase,
  }) : super(MenuItemInitial());

  Future<void> getAllMenuItems() async {
    final result = await getAllMenuItemsUseCase(NoParams());
    result.fold((failure) => emit(MenuItemError(failure: failure)), (menuItems) {
      _allMenuItems = menuItems;
      if (_selectedSubcategoryId != null) {
        filterMenuItemsBySubCategory(_selectedSubcategoryId);
      } else {
        emit(MenuItemLoaded(menuItems: menuItems));
      }
    });
  }

  Future<void> createMenuItem({
    required String name,
    required String subCategory,
    required double price,
  }) async {
    final result = await createMenuItemUseCase(
      CreateMenuItemParams(name: name, subCategory: subCategory, price: price),
    );
    result.fold((failure) => emit(MenuItemError(failure: failure)), (menuItem) {
      _allMenuItems.add(menuItem);
      filterMenuItemsBySubCategory(_selectedSubcategoryId);
    });
  }

  Future<void> updateMenuItem({
    required String id,
    String? name,
    String? subCategoryId,
    double? price,
    bool? isActive,
  }) async {
    final result = await updateMenuItemUseCase(
      UpdateMenuItemParams(
        id: id,
        name: name,
        subCategoryId: subCategoryId,
        price: price,
        isActive: isActive,
      ),
    );

    result.fold((failure) => emit(MenuItemError(failure: failure)), (menuItem) {
      _allMenuItems = _allMenuItems.map((m) => m.id == menuItem.id ? menuItem : m).toList();
      filterMenuItemsBySubCategory(_selectedSubcategoryId);
    });
  }

  Future<void> deleteMenuItem({required String id, required subcategoryId}) async {
    final result = await deleteMenuItemUseCase(DeleteMenuItemParams(id: id));
    result.fold((failure) => emit(MenuItemError(failure: failure)), (_) {
      _allMenuItems.removeWhere((item) => item.id == id);
      filterMenuItemsBySubCategory(_selectedSubcategoryId);
    });
  }

  Future<void> filterMenuItemsBySubCategory(String? subCategoryId) async {
    _selectedSubcategoryId = subCategoryId;

    if (subCategoryId == null) {
      emit(MenuItemLoaded(menuItems: _allMenuItems));
    } else {
      final filteredList =
          _allMenuItems.where((menuItem) => menuItem.subCategory == subCategoryId).toList();
      emit(MenuItemLoaded(menuItems: filteredList));
    }
  }
}
