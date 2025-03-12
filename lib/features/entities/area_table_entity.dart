import 'package:equatable/equatable.dart';

class AreaTableEntity extends Equatable {
  final String id;
  final String name;
  final List<String> tables;

  const AreaTableEntity({required this.id, required this.name, required this.tables});

  @override
  List<Object?> get props => [id, name, tables];

  AreaTableEntity copyWith({String? id, String? name, List<String>? tables}) {
    return AreaTableEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      tables: tables ?? this.tables,
    );
  }
}
