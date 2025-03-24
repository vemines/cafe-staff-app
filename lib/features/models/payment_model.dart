import '/core/constants/api_map.dart';
import '../entities/payment_entity.dart';

class PaymentModel extends PaymentEntity {
  const PaymentModel({required super.id, required super.name, required super.isActive});

  factory PaymentModel.fromJson(Map<String, dynamic> json) {
    return PaymentModel(
      id: json[PaymentApiMap.id] as String,
      name: json[PaymentApiMap.name] as String,
      isActive: json[PaymentApiMap.isActive] as bool,
    );
  }

  factory PaymentModel.fromEntity(PaymentEntity entity) {
    return PaymentModel(id: entity.id, name: entity.name, isActive: entity.isActive);
  }

  @override
  PaymentModel copyWith({String? id, String? name, bool? isActive}) {
    return PaymentModel(
      id: id ?? this.id,
      name: name ?? this.name,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() {
    return {PaymentApiMap.id: id, PaymentApiMap.name: name, PaymentApiMap.isActive: isActive};
  }
}
