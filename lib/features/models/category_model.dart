import '../../core/constants/api_map.dart';
import '../entities/category_entity.dart';

class CategoryModel extends CategoryEntity {
  const CategoryModel({required super.id, required super.name});

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json[CategoryApiMap.id] as String,
      name: json[CategoryApiMap.name] as String,
    );
  }
  factory CategoryModel.fromEntity(CategoryEntity entity) {
    return CategoryModel(id: entity.id, name: entity.name);
  }

  @override
  CategoryModel copyWith({String? id, String? name}) {
    return CategoryModel(id: id ?? this.id, name: name ?? this.name);
  }

  Map<String, dynamic> toJson() {
    return {CategoryApiMap.id: id, CategoryApiMap.name: name};
  }
}
