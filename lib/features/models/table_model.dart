import '../../core/constants/api_map.dart';
import '../entities/table_entity.dart';

class TableModel extends TableEntity {
  const TableModel({
    required super.id,
    required super.tableName,
    required super.status,
    required super.areaId,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json[TableApiMap.id] as String,
      tableName: json[TableApiMap.tableName] as String,
      status: json[TableApiMap.status] as String,
      areaId: json[TableApiMap.areaId] as String,
    );
  }
  factory TableModel.fromEntity(TableEntity entity) {
    return TableModel(
      id: entity.id,
      tableName: entity.tableName,
      status: entity.status,
      areaId: entity.areaId,
    );
  }

  @override
  TableModel copyWith({String? id, String? tableName, String? status, String? areaId}) {
    return TableModel(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      status: status ?? this.status,
      areaId: areaId ?? this.areaId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      TableApiMap.id: id,
      TableApiMap.tableName: tableName,
      TableApiMap.status: status,
      TableApiMap.areaId: areaId,
    };
  }
}
