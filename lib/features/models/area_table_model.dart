import '../../core/constants/api_map.dart';
import '../entities/area_table_entity.dart';

class AreaTableModel extends AreaTableEntity {
  const AreaTableModel({required super.id, required super.name, required super.tables});

  factory AreaTableModel.fromJson(Map<String, dynamic> json) {
    return AreaTableModel(
      id: json[AreaTableApiMap.id] as String,
      name: json[AreaTableApiMap.name] as String,
      tables: List<String>.from(json[AreaTableApiMap.tables] as List),
    );
  }
  factory AreaTableModel.fromEntity(AreaTableEntity entity) {
    return AreaTableModel(id: entity.id, name: entity.name, tables: entity.tables);
  }

  @override
  AreaTableModel copyWith({String? id, String? name, List<String>? tables}) {
    return AreaTableModel(
      id: id ?? this.id,
      name: name ?? this.name,
      tables: tables ?? this.tables,
    );
  }

  Map<String, dynamic> toJson() {
    return {AreaTableApiMap.id: id, AreaTableApiMap.name: name, AreaTableApiMap.tables: tables};
  }
}
