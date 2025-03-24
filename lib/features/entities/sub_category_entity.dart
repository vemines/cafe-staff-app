import 'package:equatable/equatable.dart';

class SubcategoryEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final List<String> items;
  final bool isActive;

  const SubcategoryEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.items,
    required this.isActive,
  });

  @override
  List<Object?> get props => [id, name, category, items, isActive];

  SubcategoryEntity copyWith({
    String? id,
    String? name,
    String? category,
    List<String>? items,
    bool? isActive,
  }) {
    return SubcategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      items: items ?? this.items,
      isActive: isActive ?? this.isActive,
    );
  }
}
