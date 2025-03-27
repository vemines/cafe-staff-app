import '/core/constants/api_map.dart';
import '/core/constants/enum.dart';
import '/core/utils/parse_utils.dart';
import '../entities/order_entity.dart';
import '../entities/table_entity.dart';
import 'order_model.dart';

class TableModel extends TableEntity {
  const TableModel({
    required super.id,
    required super.name,
    required super.status,
    required super.areaId,
    required super.mergedTable,
    super.order,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json[TableApiMap.id] as String,
      name: json[TableApiMap.name] as String,
      status: json[TableApiMap.status].toString().toTableStatus(),
      areaId: json[TableApiMap.areaId] as String,
      mergedTable: intParse(json[TableApiMap.mergedTable], fallbackValue: 1),
      order: json[TableApiMap.order] != null ? OrderModel.fromJson(json['order']) : null,
    );
  }

  factory TableModel.fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      name: entity.name,
      status: entity.status,
      areaId: entity.areaId,
      mergedTable: entity.mergedTable,
      order: entity.order,
    );
  }

  @override
  TableModel copyWith({
    String? id,
    String? name,
    TableStatus? status,
    String? areaId,
    int? mergedTable,
    OrderEntity? order,
  }) {
    return TableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      status: status ?? this.status,
      areaId: areaId ?? this.areaId,
      mergedTable: mergedTable ?? this.mergedTable,
      order: order ?? this.order,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      TableApiMap.id: id,
      TableApiMap.name: name,
      TableApiMap.status: status.toString(),
      TableApiMap.areaId: areaId,
      TableApiMap.mergedTable: mergedTable,
      'order': order != null ? (order as OrderModel).toJson() : null,
    };
  }
}
