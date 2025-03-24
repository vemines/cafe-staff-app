// lib/features/usecases/order_history/get_all_order_history_usecase.dart
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '/core/errors/failures.dart';
import '/core/usecase/usecase.dart';
import '../../entities/order_history_entity.dart';
import '../../repositories/order_history_repository.dart';
import '../../models/order_history_model.dart'; // Import

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

// --- Add OrderHistoryResponse class ---
class OrderHistoryResponse extends Equatable {
  final List<OrderHistoryEntity> data;
  final bool hasMore;
  final int? page;

  const OrderHistoryResponse({required this.data, required this.hasMore, this.page});

  @override
  List<Object?> get props => [data, hasMore, page];
}

class GetAllOrderHistoryUseCase implements UseCase<OrderHistoryResponse, GetAllOrderHistoryParams> {
  // Corrected return type
  final OrderHistoryRepository repository;

  GetAllOrderHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, OrderHistoryResponse>> call(
    // Corrected return type
    GetAllOrderHistoryParams params,
  ) async {
    if (params.page < 1) {
      return Left(InvalidInputFailure(message: "Page number must be >= 1"));
    }
    if (params.limit < 1) {
      return Left(InvalidInputFailure(message: "Limit must be >= 1"));
    }

    try {
      final result = await repository.getAllOrderHistory(params);
      return result.fold((failure) => Left(failure), (data) {
        final orderHistories =
            (data['data'] as List).map((item) => OrderHistoryModel.fromJson(item)).toList();
        return Right(
          OrderHistoryResponse(data: orderHistories, hasMore: data['hasMore'], page: params.page),
        );
      });
    } catch (e) {
      return Left(AppFailure(message: "Unexpected error in UseCase: $e"));
    }
  }
}
