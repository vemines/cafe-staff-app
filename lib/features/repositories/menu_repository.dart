import 'package:dartz/dartz.dart';

import '../../core/errors/exceptions.dart';
import '../../core/errors/failures.dart';
import '../../core/network/network_info.dart';
import '../../core/usecase/usecase.dart';
import '../datasources/menu_remote_data_source.dart';
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
  final MenuRemoteDataSource remoteDataSource;
  final NetworkInfo networkInfo;

  MenuRepositoryImpl({required this.remoteDataSource, required this.networkInfo});

  @override
  Future<Either<Failure, List<CategoryEntity>>> getAllCategories(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategories = await remoteDataSource.getAllCategories();
        return Right(remoteCategories);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> createCategory(CreateCategoryParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategory = await remoteDataSource.createCategory(name: params.name);
        return Right(remoteCategory);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, CategoryEntity>> updateCategory(UpdateCategoryParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteCategory = await remoteDataSource.updateCategory(
          id: params.id,
          name: params.name,
        );
        return Right(remoteCategory);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCategory(DeleteCategoryParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteCategory(id: params.id);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<SubCategoryEntity>>> getAllSubCategories(
    GetAllSubCategoriesParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteSubCategories = await remoteDataSource.getAllSubCategories(
          page: params.page,
          limit: params.limit,
          categoryId: params.categoryId,
        );
        return Right(remoteSubCategories);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, SubCategoryEntity>> createSubCategory(
    CreateSubCategoryParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteSubCategory = await remoteDataSource.createSubCategory(
          name: params.name,
          categoryId: params.categoryId,
          items: params.items,
        );
        return Right(remoteSubCategory);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, SubCategoryEntity>> updateSubCategory(
    UpdateSubCategoryParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteSubCategory = await remoteDataSource.updateSubCategory(
          id: params.id,
          name: params.name,
          categoryId: params.categoryId,
          items: params.items,
        );
        return Right(remoteSubCategory);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteSubCategory(DeleteSubCategoryParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteSubCategory(id: params.id);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, List<MenuItemEntity>>> getAllMenuItems(
    GetAllMenuItemsParams params,
  ) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMenuItems = await remoteDataSource.getAllMenuItems(
          page: params.page,
          limit: params.limit,
          subcategoryId: params.subcategoryId,
        );
        return Right(remoteMenuItems);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> createMenuItem(CreateMenuItemParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMenuItem = await remoteDataSource.createMenuItem(
          name: params.name,
          subCategory: params.subCategory,
          price: params.price,
          isAvailable: params.isAvailable,
        );
        return Right(remoteMenuItem);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, MenuItemEntity>> updateMenuItem(UpdateMenuItemParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final remoteMenuItem = await remoteDataSource.updateMenuItem(
          id: params.id,
          name: params.name,
          subCategoryId: params.subCategoryId,
          price: params.price,
          isAvailable: params.isAvailable,
        );
        return Right(remoteMenuItem);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteMenuItem(DeleteMenuItemParams params) async {
    if (await networkInfo.isConnected) {
      try {
        await remoteDataSource.deleteMenuItem(id: params.id);
        return const Right(unit);
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }

  @override
  Future<Either<Failure, GetCompleteMenuResponse>> getCompleteMenu(NoParams params) async {
    if (await networkInfo.isConnected) {
      try {
        final response = await remoteDataSource.getCompleteMenu();

        // Convert Model to Entity
        final categories = response.categories.map((model) => model).toList();
        final subCategories = response.subCategories.map((model) => model).toList();
        final menuItems = response.menuItems.map((model) => model).toList();

        return Right(
          GetCompleteMenuResponse(
            categories: categories,
            subCategories: subCategories,
            menuItems: menuItems,
          ),
        );
      } catch (e) {
        return Left(handleRepositoryException(e));
      }
    } else {
      return const Left(NoInternetFailure());
    }
  }
}
