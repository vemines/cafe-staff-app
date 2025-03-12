import 'package:equatable/equatable.dart';

import '../constants/enum.dart';

class NoParams extends Equatable {
  @override
  List<Object?> get props => [];
}

class PaginationParams extends Equatable {
  final int page;
  final int limit;
  final PaginationOrder order;

  const PaginationParams({
    required this.page,
    required this.limit,
    this.order = PaginationOrder.desc,
  });

  @override
  List<Object?> get props => [page, limit, order];
}
