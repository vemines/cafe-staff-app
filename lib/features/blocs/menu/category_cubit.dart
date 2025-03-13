import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/errors/failures.dart';
import '../../../../../core/usecase/params.dart';
import '../../entities/category_entity.dart';
import '../../usecases/menu/create_category_usecase.dart';
import '../../usecases/menu/delete_category_usecase.dart';
import '../../usecases/menu/get_all_categories_usecase.dart';
import '../../usecases/menu/update_category_usecase.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetAllCategoriesUseCase getAllCategoriesUseCase;
  final CreateCategoryUseCase createCategoryUseCase;
  final UpdateCategoryUseCase updateCategoryUseCase;
  final DeleteCategoryUseCase deleteCategoryUseCase;

  CategoryCubit({
    required this.getAllCategoriesUseCase,
    required this.createCategoryUseCase,
    required this.updateCategoryUseCase,
    required this.deleteCategoryUseCase,
  }) : super(CategoryInitial());

  Future<void> getAllCategories() async {
    emit(CategoryLoading());
    final result = await getAllCategoriesUseCase(NoParams());
    result.fold(
      (failure) => emit(CategoryError(failure: failure)),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }

  Future<void> createCategory(CreateCategoryParams params) async {
    emit(CategoryLoading());
    final result = await createCategoryUseCase(params);
    result.fold(
      (failure) => emit(CategoryError(failure: failure)),
      (category) => emit(CategoryCreated(category: category)),
    );
  }

  Future<void> updateCategory(UpdateCategoryParams params) async {
    emit(CategoryLoading());
    final result = await updateCategoryUseCase(params);
    result.fold(
      (failure) => emit(CategoryError(failure: failure)),
      (category) => emit(CategoryUpdated(category: category)),
    );
  }

  Future<void> deleteCategory(DeleteCategoryParams params) async {
    emit(CategoryLoading());
    final result = await deleteCategoryUseCase(params);
    result.fold(
      (failure) => emit(CategoryError(failure: failure)),
      (_) => emit(CategoryDeleted()), // No data needed on success.
    );
  }
}
