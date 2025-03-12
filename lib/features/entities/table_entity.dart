import 'package:equatable/equatable.dart';

class TableEntity extends Equatable {
  final String id;
  final String tableName;
  final String status;
  final String areaId;

  const TableEntity({
    required this.id,
    required this.tableName,
    required this.status,
    required this.areaId,
  });

  @override
  List<Object?> get props => [id, tableName, status, areaId];

  TableEntity copyWith({String? id, String? tableName, String? status, String? areaId}) {
    return TableEntity(
      id: id ?? this.id,
      tableName: tableName ?? this.tableName,
      status: status ?? this.status,
      areaId: areaId ?? this.areaId,
    );
  }
}
