import 'package:equatable/equatable.dart';

import 'table_entity.dart';

class AreaWithTablesEntity extends Equatable {
  final String id;
  final String name;
  final List<TableEntity> tables;

  const AreaWithTablesEntity({required this.id, required this.name, required this.tables});

  @override
  List<Object?> get props => [id, name, tables];

  AreaWithTablesEntity copyWith({String? id, String? name, List<TableEntity>? tables}) {
    return AreaWithTablesEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      tables: tables ?? this.tables,
    );
  }
}
