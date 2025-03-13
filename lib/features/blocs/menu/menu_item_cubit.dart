import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
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

  MenuItemCubit({
    required this.getAllMenuItemsUseCase,
    required this.createMenuItemUseCase,
    required this.updateMenuItemUseCase,
    required this.deleteMenuItemUseCase,
  }) : super(MenuItemInitial());

  Future<void> getAllMenuItems(GetAllMenuItemsParams params) async {
    emit(MenuItemLoading());
    final result = await getAllMenuItemsUseCase(params);
    result.fold(
      (failure) => emit(MenuItemError(failure: failure)),
      (menuItems) => emit(MenuItemLoaded(menuItems: menuItems)),
    );
  }

  Future<void> createMenuItem(CreateMenuItemParams params) async {
    emit(MenuItemLoading());
    final result = await createMenuItemUseCase(params);
    result.fold(
      (failure) => emit(MenuItemError(failure: failure)),
      (menuItem) => emit(MenuItemCreated(menuItem: menuItem)),
    );
  }

  Future<void> updateMenuItem(UpdateMenuItemParams params) async {
    emit(MenuItemLoading());
    final result = await updateMenuItemUseCase(params);
    result.fold(
      (failure) => emit(MenuItemError(failure: failure)),
      (menuItem) => emit(MenuItemUpdated(menuItem: menuItem)),
    );
  }

  Future<void> deleteMenuItem(DeleteMenuItemParams params) async {
    emit(MenuItemLoading());
    final result = await deleteMenuItemUseCase(params);
    result.fold((failure) => emit(MenuItemError(failure: failure)), (_) => emit(MenuItemDeleted()));
  }
}
