import '/core/constants/api_map.dart';
import '../entities/area_entity.dart';

class AreaModel extends AreaEntity {
  const AreaModel({required super.id, required super.name, required super.tables});

  factory AreaModel.fromJson(Map<String, dynamic> json) {
    return AreaModel(
      id: json[AreaApiMap.id] as String,
      name: json[AreaApiMap.name] as String,
      tables: List<String>.from(json[AreaApiMap.tables] as List),
    );
  }
  factory AreaModel.fromEntity(AreaEntity entity) {
    return AreaModel(id: entity.id, name: entity.name, tables: entity.tables);
  }

  @override
  AreaModel copyWith({String? id, String? name, List<String>? tables}) {
    return AreaModel(id: id ?? this.id, name: name ?? this.name, tables: tables ?? this.tables);
  }

  Map<String, dynamic> toJson() {
    return {AreaApiMap.id: id, AreaApiMap.name: name, AreaApiMap.tables: tables};
  }
}
