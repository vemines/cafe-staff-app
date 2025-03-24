import '../../core/constants/api_map.dart';
import '/core/utils/parse_utils.dart';
import '../entities/payment_statistic_entity.dart';

class PaymentStatisticModel extends PaymentStatisticEntity {
  const PaymentStatisticModel({
    required super.name,
    required super.count,
    required super.totalAmount,
  });

  factory PaymentStatisticModel.fromJson(Map<String, dynamic> json) {
    return PaymentStatisticModel(
      name: json[PaymentStatisticApiMap.name] as String,
      count: intParse(json[PaymentStatisticApiMap.count]),
      totalAmount: doubleParse(json[PaymentStatisticApiMap.totalAmount]),
    );
  }

  factory PaymentStatisticModel.fromEntity(PaymentStatisticEntity entity) {
    return PaymentStatisticModel(
      name: entity.name,
      count: entity.count,
      totalAmount: entity.totalAmount,
    );
  }

  @override
  PaymentStatisticModel copyWith({String? name, int? count, double? totalAmount}) {
    return PaymentStatisticModel(
      name: name ?? this.name,
      count: count ?? this.count,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      PaymentStatisticApiMap.name: name,
      PaymentStatisticApiMap.count: count,
      PaymentStatisticApiMap.totalAmount: totalAmount,
    };
  }
}
