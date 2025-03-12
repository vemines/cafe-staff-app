import 'package:equatable/equatable.dart';

class MenuItemEntity extends Equatable {
  final String id;
  final String name;
  final double price;
  final String subCategory;
  final bool isAvailable;

  const MenuItemEntity({
    required this.id,
    required this.name,
    required this.price,
    required this.subCategory,
    required this.isAvailable,
  });

  @override
  List<Object?> get props => [id, name, price, subCategory, isAvailable];

  MenuItemEntity copyWith({
    String? id,
    String? name,
    double? price,
    String? subCategory,
    bool? isAvailable,
  }) {
    return MenuItemEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      subCategory: subCategory ?? this.subCategory,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }
}
