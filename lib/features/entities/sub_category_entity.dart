import 'package:equatable/equatable.dart';

class SubCategoryEntity extends Equatable {
  final String id;
  final String name;
  final String category;
  final List<String> items;

  const SubCategoryEntity({
    required this.id,
    required this.name,
    required this.category,
    required this.items,
  });

  @override
  List<Object?> get props => [id, name, category, items];

  SubCategoryEntity copyWith({String? id, String? name, String? category, List<String>? items}) {
    return SubCategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      items: items ?? this.items,
    );
  }
}
