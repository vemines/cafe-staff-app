import '/core/constants/api_map.dart';
import '../entities/area_with_table_entity.dart';
import '../entities/table_entity.dart';
import 'table_model.dart';

class AreaWithTablesModel extends AreaWithTablesEntity {
  const AreaWithTablesModel({required super.id, required super.name, required super.tables});

  factory AreaWithTablesModel.fromJson(Map<String, dynamic> json) {
    return AreaWithTablesModel(
      id: json[AreaWithTablesApiMap.id] as String,
      name: json[AreaWithTablesApiMap.name] as String,
      tables:
          (json[AreaWithTablesApiMap.tables] as List)
              .map((tableJson) => TableModel.fromJson(tableJson))
              .toList(),
    );
  }

  factory AreaWithTablesModel.fromEntity(AreaWithTablesEntity entity) {
    return AreaWithTablesModel(
      id: entity.id,
      name: entity.name,
      tables: entity.tables.map((e) => TableModel.fromEntity(e)).toList(),
    );
  }

  @override
  AreaWithTablesModel copyWith({String? id, String? name, List<TableEntity>? tables}) {
    return AreaWithTablesModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tables: tables ?? this.tables,
    );
  }
}
