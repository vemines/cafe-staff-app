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

class MenuItemError extends MenuItemState {
  final Failure failure;

  const MenuItemError({required this.failure});

  @override
  List<Object> get props => [failure];
}
