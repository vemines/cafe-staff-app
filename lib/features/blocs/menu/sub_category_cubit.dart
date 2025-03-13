import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/errors/failures.dart';
import '../../entities/sub_category_entity.dart';
import '../../usecases/menu/create_subcategory_usecase.dart';
import '../../usecases/menu/delete_subcategory_usecase.dart';
import '../../usecases/menu/get_all_subcategories_usecase.dart';
import '../../usecases/menu/update_subcategory_usecase.dart';

part 'sub_category_state.dart';

class SubCategoryCubit extends Cubit<SubCategoryState> {
  final GetAllSubCategoriesUseCase getAllSubCategoriesUseCase;
  final CreateSubCategoryUseCase createSubCategoryUseCase;
  final UpdateSubCategoryUseCase updateSubCategoryUseCase;
  final DeleteSubCategoryUseCase deleteSubCategoryUseCase;

  SubCategoryCubit({
    required this.getAllSubCategoriesUseCase,
    required this.createSubCategoryUseCase,
    required this.updateSubCategoryUseCase,
    required this.deleteSubCategoryUseCase,
  }) : super(SubCategoryInitial());

  Future<void> getAllSubCategories(GetAllSubCategoriesParams params) async {
    emit(SubCategoryLoading());
    final result = await getAllSubCategoriesUseCase(params);
    result.fold(
      (failure) => emit(SubCategoryError(failure: failure)),
      (subCategories) => emit(SubCategoryLoaded(subCategories: subCategories)),
    );
  }

  Future<void> createSubCategory(CreateSubCategoryParams params) async {
    emit(SubCategoryLoading());
    final result = await createSubCategoryUseCase(params);
    result.fold(
      (failure) => emit(SubCategoryError(failure: failure)),
      (subCategory) => emit(SubCategoryCreated(subCategory: subCategory)),
    );
  }

  Future<void> updateSubCategory(UpdateSubCategoryParams params) async {
    emit(SubCategoryLoading());
    final result = await updateSubCategoryUseCase(params);
    result.fold(
      (failure) => emit(SubCategoryError(failure: failure)),
      (subCategory) => emit(SubCategoryUpdated(subCategory: subCategory)),
    );
  }

  Future<void> deleteSubCategory(DeleteSubCategoryParams params) async {
    emit(SubCategoryLoading());
    final result = await deleteSubCategoryUseCase(params);
    result.fold(
      (failure) => emit(SubCategoryError(failure: failure)),
      (_) => emit(SubCategoryDeleted()),
    );
  }
}
