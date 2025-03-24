import '/core/constants/api_map.dart';
import '/core/utils/parse_utils.dart';
import '../entities/menu_item_entity.dart';

class MenuItemModel extends MenuItemEntity {
  const MenuItemModel({
    required super.id,
    required super.name,
    required super.price,
    required super.subCategory,
    required super.isActive,
  });

  factory MenuItemModel.fromJson(Map<String, dynamic> json) {
    return MenuItemModel(
      id: json[MenuItemApiMap.id] as String,
      name: json[MenuItemApiMap.name] as String,
      price: doubleParse(json[MenuItemApiMap.price]),
      subCategory: json[MenuItemApiMap.subCategory] as String,
      isActive: json[MenuItemApiMap.isActive] as bool,
    );
  }
  factory MenuItemModel.fromEntity(MenuItemEntity entity) {
    return MenuItemModel(
      id: entity.id,
      name: entity.name,
      price: entity.price,
      subCategory: entity.subCategory,
      isActive: entity.isActive,
    );
  }

  @override
  MenuItemModel copyWith({
    String? id,
    String? name,
    double? price,
    String? subCategory,
    bool? isActive,
  }) {
    return MenuItemModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      subCategory: subCategory ?? this.subCategory,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      MenuItemApiMap.id: id,
      MenuItemApiMap.name: name,
      MenuItemApiMap.price: price,
      MenuItemApiMap.subCategory: subCategory,
      MenuItemApiMap.isActive: isActive,
    };
  }
}
