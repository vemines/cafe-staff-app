import '/core/constants/api_map.dart';
import '../entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name, required super.isActive});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json[CategoryApiMap.id] as String,
      name: json[CategoryApiMap.name] as String,
      isActive: json[CategoryApiMap.isActive] as bool,
    );
  }
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  @override
  CategoryModel copyWith({String? id, String? name, bool? isActive}) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {CategoryApiMap.id: id, CategoryApiMap.name: name, CategoryApiMap.isActive: isActive};
  }
}
