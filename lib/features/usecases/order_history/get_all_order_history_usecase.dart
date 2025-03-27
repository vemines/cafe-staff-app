import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/order_history_entity.dart';
import '../../repositories/order_history_repository.dart';

class GetAllOrderHistoryParams extends Equatable {
  final DateTime? startDate;
  final DateTime? endDate;
  final String? paymentMethod;
  final int page;
  final int limit;

  const GetAllOrderHistoryParams({
    this.startDate,
    this.endDate,
    this.paymentMethod,
    required this.page,
    required this.limit,
  });

  @override
  List<Object?> get props => [startDate, endDate, paymentMethod, page, limit];
}

class OrderHistoryResponse extends Equatable {
  final List<OrderHistoryEntity> data;
  final bool hasMore;
  final int? page;

  const OrderHistoryResponse({required this.data, required this.hasMore, this.page});

  @override
  List<Object?> get props => [data, hasMore, page];
}

class GetAllOrderHistoryUseCase implements UseCase<OrderHistoryResponse, GetAllOrderHistoryParams> {
  final OrderHistoryRepository repository;

  GetAllOrderHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, OrderHistoryResponse>> call(GetAllOrderHistoryParams params) async {
    if (params.page < 1) {
      return Left(InvalidInputFailure(message: "Page number must be >= 1"));
    }
    if (params.limit < 1) {
      return Left(InvalidInputFailure(message: "Limit must be >= 1"));
    }

    try {
      final result = await repository.getAllOrderHistory(params);
      return result.fold((failure) => Left(failure), (data) {
        return Right(
          OrderHistoryResponse(data: data['data'], hasMore: data['hasMore'], page: params.page),
        );
      });
    } catch (e) {
      return Left(AppFailure(message: "Unexpected error in UseCase: $e"));
    }
  }
}
