import 'package:dio/dio.dart';

import '/core/constants/api_endpoints.dart';
import '/core/constants/api_map.dart';
import '/core/errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/sub_category_model.dart';
import '../usecases/menu/get_complete_menu_usecase.dart';

abstract class MenuRemoteDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel> createCategory({required String name});
  Future<CategoryModel> updateCategory({required String id, String? name, bool? isActive});
  Future<void> deleteCategory({required String id});

  Future<List<SubCategoryModel>> getAllSubCategories();
  Future<SubCategoryModel> createSubCategory({
    required String name,
    required String categoryId,
    required List<String> items,
  });
  Future<SubCategoryModel> updateSubCategory({
    required String id,
    String? name,
    String? categoryId,
    List<String>? items,
    bool? isActive,
  });
  Future<void> deleteSubCategory({required String id});

  Future<List<MenuItemModel>> getAllMenuItems();
  Future<MenuItemModel> createMenuItem({
    required String name,
    required String subCategory,
    required double price,
  });
  Future<MenuItemModel> updateMenuItem({
    required String id,
    String? name,
    String? subCategoryId,
    double? price,
    bool? isActive,
  });
  Future<void> deleteMenuItem({required String id});
  Future<GetCompleteMenuResponse> getCompleteMenu();
}

class MenuRemoteDataSourceImpl implements MenuRemoteDataSource {
  final Dio dio;

  MenuRemoteDataSourceImpl({required this.dio});

  @override
  Future<List<CategoryModel>> getAllCategories() async {
    try {
      final response = await dio.get(ApiEndpoints.categories);
      return (response.data as List).map((item) => CategoryModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.getAllCategories');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<GetCompleteMenuResponse> getCompleteMenu() async {
    try {
      final response = await dio.get(ApiEndpoints.completeMenu);
      final categories =
          (response.data['categories'] as List)
              .map((item) => CategoryModel.fromJson(item))
              .toList();
      final subCategories =
          (response.data['subCategories'] as List)
              .map((item) => SubCategoryModel.fromJson(item))
              .toList();
      final menuItems =
          (response.data['menuItems'] as List).map((item) => MenuItemModel.fromJson(item)).toList();
      return GetCompleteMenuResponse(
        categories: categories,
        subCategories: subCategories,
        menuItems: menuItems,
      );
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.getCompleteMenu');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<CategoryModel> createCategory({required String name}) async {
    try {
      final response = await dio.post(
        ApiEndpoints.categories,
        data: {CategoryApiMap.name: name, CategoryApiMap.isActive: false},
      );
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.createCategory');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<CategoryModel> updateCategory({required String id, String? name, bool? isActive}) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData[CategoryApiMap.name] = name;
      if (name != null) updateData[CategoryApiMap.name] = name;
      if (isActive != null) updateData[CategoryApiMap.isActive] = isActive;

      final response = await dio.patch(ApiEndpoints.singleCategory(id), data: updateData);
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.updateCategory');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleCategory(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.deleteCategory');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<SubCategoryModel>> getAllSubCategories() async {
    try {
      final response = await dio.get(ApiEndpoints.subcategories);
      return (response.data as List).map((item) => SubCategoryModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.getAllSubCategories');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<SubCategoryModel> createSubCategory({
    required String name,
    required String categoryId,
    required List<String> items,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.subcategories,
        data: {
          SubCategoryApiMap.name: name,
          SubCategoryApiMap.category: categoryId,
          SubCategoryApiMap.items: items,
          SubCategoryApiMap.isActive: false,
        },
      );
      return SubCategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.createSubCategory');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<SubCategoryModel> updateSubCategory({
    required String id,
    String? name,
    String? categoryId,
    List<String>? items,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData[SubCategoryApiMap.name] = name;
      if (categoryId != null) updateData[SubCategoryApiMap.category] = categoryId;
      if (items != null) updateData[SubCategoryApiMap.items] = items;
      if (isActive != null) updateData[SubCategoryApiMap.isActive] = isActive;

      final response = await dio.patch(ApiEndpoints.singleSubcategory(id), data: updateData);
      return SubCategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.updateSubCategory');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteSubCategory({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleSubcategory(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.deleteSubCategory');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<MenuItemModel>> getAllMenuItems() async {
    try {
      final response = await dio.get(ApiEndpoints.menuItems);
      return (response.data as List).map((item) => MenuItemModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.getAllMenuItems');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<MenuItemModel> createMenuItem({
    required String name,
    required String subCategory,
    required double price,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.menuItems,
        data: {
          MenuItemApiMap.name: name,
          MenuItemApiMap.subCategory: subCategory,
          MenuItemApiMap.price: price,
          MenuItemApiMap.isActive: false,
        },
      );
      return MenuItemModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.createMenuItem');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<MenuItemModel> updateMenuItem({
    required String id,
    String? name,
    String? subCategoryId,
    double? price,
    bool? isActive,
  }) async {
    try {
      final updateData = <String, dynamic>{};
      if (name != null) updateData[MenuItemApiMap.name] = name;
      if (subCategoryId != null) updateData[MenuItemApiMap.subCategory] = subCategoryId;
      if (price != null) updateData[MenuItemApiMap.price] = price;
      if (isActive != null) updateData[MenuItemApiMap.isActive] = isActive;

      final response = await dio.patch(ApiEndpoints.singleMenuItem(id), data: updateData);
      return MenuItemModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.updateMenuItem');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteMenuItem({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleMenuItem(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'MenuRemoteDataSource.deleteMenuItem');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
