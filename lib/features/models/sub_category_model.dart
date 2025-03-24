import '/core/constants/api_map.dart';
import '../entities/sub_category_entity.dart';

class SubCategoryModel extends SubcategoryEntity {
  const SubCategoryModel({
    required super.id,
    required super.name,
    required super.category,
    required super.items,
    required super.isActive,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json[SubCategoryApiMap.id] as String,
      name: json[SubCategoryApiMap.name] as String,
      category: json[SubCategoryApiMap.category] as String,
      items: List<String>.from(json[SubCategoryApiMap.items] as List),
      isActive: json[SubCategoryApiMap.isActive] as bool,
    );
  }
  factory SubCategoryModel.fromEntity(SubcategoryEntity entity) {
    return SubCategoryModel(
      id: entity.id,
      name: entity.name,
      category: entity.category,
      items: entity.items,
      isActive: entity.isActive,
    );
  }

  @override
  SubCategoryModel copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? items,
    bool? isActive,
  }) {
    return SubCategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      SubCategoryApiMap.id: id,
      SubCategoryApiMap.name: name,
      SubCategoryApiMap.category: category,
      SubCategoryApiMap.items: items,
      SubCategoryApiMap.isActive: isActive,
    };
  }
}
