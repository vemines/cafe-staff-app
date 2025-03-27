import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '/core/errors/failures.dart';
import '../../../core/usecase/usecase.dart';
import '../../entities/sub_category_entity.dart';
import '../../usecases/menu/create_subcategory_usecase.dart';
import '../../usecases/menu/delete_subcategory_usecase.dart';
import '../../usecases/menu/get_all_subcategories_usecase.dart';
import '../../usecases/menu/update_subcategory_usecase.dart';

part 'sub_category_state.dart';

class SubCategoryCubit extends Cubit<SubCategoryState> {
  final GetAllSubCategoryUseCase getAllSubCategoriesUseCase;
  final CreateSubCategoryUseCase createSubCategoryUseCase;
  final UpdateSubCategoryUseCase updateSubCategoryUseCase;
  final DeleteSubCategoryUseCase deleteSubCategoryUseCase;

  List<SubcategoryEntity> _allSubCategories = [];
  String? _selectedCategoryId;

  SubCategoryCubit({
    required this.getAllSubCategoriesUseCase,
    required this.createSubCategoryUseCase,
    required this.updateSubCategoryUseCase,
    required this.deleteSubCategoryUseCase,
  }) : super(SubCategoryInitial());

  Future<void> getAllSubCategories() async {
    final result = await getAllSubCategoriesUseCase(NoParams());
    result.fold((failure) => emit(SubCategoryError(failure: failure)), (subCategories) {
      _allSubCategories = subCategories;
      if (_selectedCategoryId != null) {
        filterSubCategoriesByCategory(_selectedCategoryId);
      } else {
        emit(SubCategoryLoaded(subCategories: subCategories));
      }
    });
  }

  Future<void> createSubCategory({required String name, required String categoryId}) async {
    final result = await createSubCategoryUseCase(
      CreateSubCategoryParams(name: name, categoryId: categoryId),
    );

    result.fold((failure) => emit(SubCategoryError(failure: failure)), (subCategory) {
      _allSubCategories.add(subCategory);
      filterSubCategoriesByCategory(_selectedCategoryId);
    });
  }

  Future<void> updateSubCategory({
    required String id,
    String? name,
    String? categoryId,
    List<String>? items,
    bool? isActive,
  }) async {
    final result = await updateSubCategoryUseCase(
      UpdateSubCategoryParams(
        id: id,
        name: name,
        categoryId: categoryId,
        items: items,
        isActive: isActive,
      ),
    );
    result.fold((failure) => emit(SubCategoryError(failure: failure)), (subCategory) {
      _allSubCategories =
          _allSubCategories.map((s) => s.id == subCategory.id ? subCategory : s).toList();
      filterSubCategoriesByCategory(_selectedCategoryId);
    });
  }

  Future<void> deleteSubCategory({required String id, required String categoryId}) async {
    final result = await deleteSubCategoryUseCase(DeleteSubCategoryParams(id: id));
    result.fold((failure) => emit(SubCategoryError(failure: failure)), (_) {
      _allSubCategories.removeWhere((item) => item.id == id);
      filterSubCategoriesByCategory(_selectedCategoryId);
    });
  }

  Future<void> filterSubCategoriesByCategory(String? categoryId) async {
    _selectedCategoryId = categoryId;

    if (categoryId == null || categoryId.isEmpty) {
      emit(SubCategoryLoaded(subCategories: _allSubCategories));
    } else {
      final filteredList =
          _allSubCategories.where((subCategory) => subCategory.category == categoryId).toList();
      emit(SubCategoryLoaded(subCategories: filteredList));
    }
  }
}
