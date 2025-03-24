// Path: lib/features/blocs/menu/menu_item_state.dart
// Defines the states for the MenuItemCubit.
part of 'menu_item_cubit.dart';

abstract class MenuItemState extends Equatable {
  const MenuItemState();

  @override
  List<Object?> get props => [];
}

class MenuItemInitial extends MenuItemState {}

class MenuItemLoading extends MenuItemState {}

class MenuItemLoaded extends MenuItemState {
  final List<MenuItemEntity> menuItems;

  const MenuItemLoaded({required this.menuItems});

  @override
  List<Object?> get props => [menuItems];
}

// class MenuItemCreated extends MenuItemState {
//   final MenuItemEntity menuItem;

//   const MenuItemCreated({required this.menuItem});

//   @override
//   List<Object> get props => [menuItem];
// }

// class MenuItemUpdated extends MenuItemState {
//   final MenuItemEntity menuItem;

//   const MenuItemUpdated({required this.menuItem});

//   @override
//   List<Object> get props => [menuItem];
// }

// class MenuItemDeleted extends MenuItemState {}

class MenuItemError extends MenuItemState {
  final Failure failure;

  const MenuItemError({required this.failure});

  @override
  List<Object> get props => [failure];
}
