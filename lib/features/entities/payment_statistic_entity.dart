import 'package:equatable/equatable.dart';

class PaymentStatisticEntity extends Equatable {
  final String name;
  final int count;
  final double totalAmount;

  const PaymentStatisticEntity({
    required this.name,
    required this.count,
    required this.totalAmount,
  });

  @override
  List<Object?> get props => [name, count, totalAmount];

  PaymentStatisticEntity copyWith({String? name, int? count, double? totalAmount}) {
    return PaymentStatisticEntity(
      name: name ?? this.name,
      count: count ?? this.count,
      totalAmount: totalAmount ?? this.totalAmount,
    );
  }
}
