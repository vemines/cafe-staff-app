import 'package:equatable/equatable.dart';

class CategoryEntity extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const CategoryEntity({required this.id, required this.name, required this.isActive});

  @override
  List<Object?> get props => [id, name, isActive];

  CategoryEntity copyWith({String? id, String? name, bool? isActive}) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
