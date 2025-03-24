import 'package:equatable/equatable.dart';

class PaymentEntity extends Equatable {
  final String id;
  final String name;
  final bool isActive;

  const PaymentEntity({required this.id, required this.name, required this.isActive});

  @override
  List<Object?> get props => [id, name, isActive];

  PaymentEntity copyWith({String? id, String? name, bool? isActive}) {
    return PaymentEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }
}
