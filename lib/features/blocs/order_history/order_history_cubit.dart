import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '../../entities/order_history_entity.dart';
import '../../usecases/order_history/get_all_order_history_usecase.dart';

part 'order_history_state.dart';

class OrderHistoryCubit extends Cubit<OrderHistoryState> {
  final GetAllOrderHistoryUseCase getAllOrderHistoryUseCase;

  int _currentPage = 1;
  bool _hasMore = true;
  bool isLoadMore = false;
  final int _limit = 40;

  OrderHistoryCubit({required this.getAllOrderHistoryUseCase}) : super(OrderHistoryInitial());

  Future<void> clearFilters() async {
    _currentPage = 1;
    _hasMore = true;
    isLoadMore = false;
    getAllOrderHistory();
  }

  Future<void> getAllOrderHistory({
    DateTime? startDate,
    DateTime? endDate,
    String? paymentMethod,
    bool isLoadMore = false,
  }) async {
    if (!_hasMore && isLoadMore) return;

    if (isLoadMore) {
      isLoadMore = true;
      emit(OrderHistoryLoadingMore(orderHistory: state.orderHistory));
      _currentPage++;
    } else {
      isLoadMore = false;
      emit(OrderHistoryLoading());
      _currentPage = 1;
      _hasMore = true;
    }

    final result = await getAllOrderHistoryUseCase(
      GetAllOrderHistoryParams(
        startDate: startDate,
        endDate: endDate,
        paymentMethod: paymentMethod,
        page: _currentPage,
        limit: _limit,
      ),
    );

    result.fold(
      (failure) {
        isLoadMore = false;
        emit(OrderHistoryError(failure: failure));
      },
      (response) {
        isLoadMore = false;
        final List<OrderHistoryEntity> newList = List.from(state.orderHistory);
        newList.addAll(response.data);
        _hasMore = response.hasMore;
        emit(OrderHistoryLoaded(orderHistory: newList, hasMore: _hasMore));
      },
    );
  }
}
