import 'package:dartz/dartz.dart';

import '../../core/errors/failures.dart';
import '../../core/usecase/usecase.dart';
import '../entities/category_entity.dart';
import '../entities/menu_item_entity.dart';
import '../entities/sub_category_entity.dart';
import '../usecases/menu/create_category_usecase.dart';
import '../usecases/menu/create_menu_item_usecase.dart';
import '../usecases/menu/create_subcategory_usecase.dart';
import '../usecases/menu/delete_category_usecase.dart';
import '../usecases/menu/delete_menu_item_usecase.dart';
import '../usecases/menu/delete_subcategory_usecase.dart';
import '../usecases/menu/get_all_menu_items_usecase.dart';
import '../usecases/menu/get_all_subcategories_usecase.dart';
import '../usecases/menu/get_complete_menu_usecase.dart';
import '../usecases/menu/update_category_usecase.dart';
import '../usecases/menu/update_menu_item_usecase.dart';
import '../usecases/menu/update_subcategory_usecase.dart';

abstract class MenuRepository {
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories(NoParams params);
  Future<Either<Failure, CategoryEntity>> createCategory(CreateCategoryParams params);
  Future<Either<Failure, CategoryEntity>> updateCategory(UpdateCategoryParams params);
  Future<Either<Failure, Unit>> deleteCategory(DeleteCategoryParams params);

  Future<Either<Failure, List<SubCategoryEntity>>> getAllSubCategories(
    GetAllSubCategoriesParams params,
  );
  Future<Either<Failure, SubCategoryEntity>> createSubCategory(CreateSubCategoryParams params);
  Future<Either<Failure, SubCategoryEntity>> updateSubCategory(UpdateSubCategoryParams params);
  Future<Either<Failure, Unit>> deleteSubCategory(DeleteSubCategoryParams params);

  Future<Either<Failure, List<MenuItemEntity>>> getAllMenuItems(GetAllMenuItemsParams params);
  Future<Either<Failure, MenuItemEntity>> createMenuItem(CreateMenuItemParams params);
  Future<Either<Failure, MenuItemEntity>> updateMenuItem(UpdateMenuItemParams params);
  Future<Either<Failure, Unit>> deleteMenuItem(DeleteMenuItemParams params);
  Future<Either<Failure, GetCompleteMenuResponse>> getCompleteMenu(NoParams params);
}

class MenuRepositoryImpl implements MenuRepository {
  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories(NoParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(CreateCategoryParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(UpdateCategoryParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(DeleteCategoryParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<SubCategoryEntity>>> getAllSubCategories(
    GetAllSubCategoriesParams params,
  ) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SubCategoryEntity>> createSubCategory(CreateSubCategoryParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, SubCategoryEntity>> updateSubCategory(UpdateSubCategoryParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteSubCategory(DeleteSubCategoryParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getAllMenuItems(GetAllMenuItemsParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MenuItemEntity>> createMenuItem(CreateMenuItemParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, MenuItemEntity>> updateMenuItem(UpdateMenuItemParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, Unit>> deleteMenuItem(DeleteMenuItemParams params) {
    throw UnimplementedError();
  }

  @override
  Future<Either<Failure, GetCompleteMenuResponse>> getCompleteMenu(NoParams params) {
    throw UnimplementedError();
  }
}
