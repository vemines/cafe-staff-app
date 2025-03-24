import 'package:equatable/equatable.dart';

class AreaEntity extends Equatable {
  final String id;
  final String name;
  final List<String> tables;

  const AreaEntity({required this.id, required this.name, required this.tables});

  @override
  List<Object?> get props => [id, name, tables];

  AreaEntity copyWith({String? id, String? name, List<String>? tables}) {
    return AreaEntity(id: id ?? this.id, name: name ?? this.name, tables: tables ?? this.tables);
  }
}
