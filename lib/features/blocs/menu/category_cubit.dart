import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '/core/usecase/params.dart';
import '../../entities/category_entity.dart';
import '../../usecases/menu/create_category_usecase.dart';
import '../../usecases/menu/delete_category_usecase.dart';
import '../../usecases/menu/get_all_categories_usecase.dart';
import '../../usecases/menu/update_category_usecase.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final GetAllCategoryUseCase getAllCategoriesUseCase;
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
    final result = await getAllCategoriesUseCase(NoParams());
    result.fold(
      (failure) => emit(CategoryError(failure: failure)),
      (categories) => emit(CategoryLoaded(categories: categories)),
    );
  }

  Future<void> createCategory({required String name}) async {
    final result = await createCategoryUseCase(CreateCategoryParams(name: name));
    result.fold((failure) => emit(CategoryError(failure: failure)), (category) {
      List<CategoryEntity> categories = [];
      if (state is CategoryLoaded) {
        categories = (state as CategoryLoaded).categories;
      }
      emit(CategoryLoaded(categories: [...categories, category]));
    });
  }

  Future<void> updateCategory({required String id, String? name, bool? isActive}) async {
    final result = await updateCategoryUseCase(
      UpdateCategoryParams(id: id, isActive: isActive, name: name),
    );

    result.fold(
      (failure) {
        emit(CategoryError(failure: failure));
      },
      (category) {
        List<CategoryEntity> categories =
            (state as CategoryLoaded).categories
                .map((c) => c.id == category.id ? category : c)
                .toList();
        emit(CategoryLoaded(categories: categories));
      },
    );
  }

  Future<void> deleteCategory({required String id}) async {
    final result = await deleteCategoryUseCase(DeleteCategoryParams(id: id));
    result.fold((failure) => emit(CategoryError(failure: failure)), (_) {
      List<CategoryEntity> categories = [];
      if (state is CategoryLoaded) {
        categories = (state as CategoryLoaded).categories;
      }
      categories = categories.where((c) => c.id != id).toList();
      emit(CategoryLoaded(categories: categories));
    });
  }
}
