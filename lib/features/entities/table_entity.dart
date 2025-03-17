import 'package:equatable/equatable.dart';

import '/core/constants/enum.dart';
import 'order_entity.dart'; // Import OrderEntity

class TableEntity extends Equatable {
  final String id;
  final String tableName;
  final TableStatus status;
  final String areaId;
  final int mergedTable;
  final OrderEntity? order;

  const TableEntity({
    required this.id,
    required this.tableName,
    required this.status,
    required this.areaId,
    required this.mergedTable,
    this.order,
  });

  @override
  List<Object?> get props => [id, tableName, status, areaId, mergedTable, order];

  TableEntity copyWith({
    String? id,
    String? tableName,
    TableStatus? status,
    String? areaId,
    int? mergedTable,
    OrderEntity? order,
  }) {
    return TableEntity(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      status: status ?? this.status,
      areaId: areaId ?? this.areaId,
      mergedTable: mergedTable ?? this.mergedTable,
      order: order ?? this.order,
    );
  }
}
