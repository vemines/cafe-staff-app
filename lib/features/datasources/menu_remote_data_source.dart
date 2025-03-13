// lib/features/data/datasources/remote/menu_remote_data_source.dart
import 'package:dio/dio.dart';

import '../../../../../core/constants/api_endpoints.dart';
import '../../../../../core/errors/exceptions.dart';
import '../models/category_model.dart';
import '../models/menu_item_model.dart';
import '../models/sub_category_model.dart';
import '../usecases/menu/get_complete_menu_usecase.dart';

abstract class MenuRemoteDataSource {
  Future<List<CategoryModel>> getAllCategories();
  Future<CategoryModel> createCategory({required String name});
  Future<CategoryModel> updateCategory({required String id, required String name});
  Future<void> deleteCategory({required String id});

  Future<List<SubCategoryModel>> getAllSubCategories({
    required int page,
    required int limit,
    String? categoryId,
  });
  Future<SubCategoryModel> createSubCategory({
    required String name,
    required String categoryId,
    required List<String> items,
  });
  Future<SubCategoryModel> updateSubCategory({
    required String id,
    required String name,
    required String categoryId,
    required List<String> items,
  });
  Future<void> deleteSubCategory({required String id});

  Future<List<MenuItemModel>> getAllMenuItems({
    required int page,
    required int limit,
    String? subcategoryId,
  });
  Future<MenuItemModel> createMenuItem({
    required String name,
    required String subCategory,
    required double price,
    required bool isAvailable,
  });
  Future<MenuItemModel> updateMenuItem({
    required String id,
    required String name,
    required String subCategoryId,
    required double price,
    required bool isAvailable,
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
      handleDioException(e, s, 'getAllCategories()');
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
      handleDioException(e, s, 'getCompleteMenu()');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<CategoryModel> createCategory({required String name}) async {
    try {
      final response = await dio.post(ApiEndpoints.categories, data: {'name': name});
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'createCategory({required String name})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<CategoryModel> updateCategory({required String id, required String name}) async {
    try {
      final response = await dio.patch(ApiEndpoints.singleCategory(id), data: {'name': name});
      return CategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(e, s, 'updateCategory({required String id, required String name})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteCategory({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleCategory(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'deleteCategory({required String id})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<SubCategoryModel>> getAllSubCategories({
    required int page,
    required int limit,
    String? categoryId,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.subcategories,
        queryParameters: {'page': page, 'limit': limit, 'category': categoryId},
      );
      return (response.data as List).map((item) => SubCategoryModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'getAllSubCategories({required int page, required int limit, String? categoryId})',
      );
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
        data: {'name': name, 'category': categoryId, 'items': items},
      );
      return SubCategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'createSubCategory({required String name, required String categoryId, required List<String> items})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<SubCategoryModel> updateSubCategory({
    required String id,
    required String name,
    required String categoryId,
    required List<String> items,
  }) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.singleSubcategory(id),
        data: {'name': name, 'category': categoryId, 'items': items},
      );
      return SubCategoryModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'updateSubCategory({required String id, required String name, required String categoryId, required List<String> items})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteSubCategory({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleSubcategory(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'deleteSubCategory({required String id})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<List<MenuItemModel>> getAllMenuItems({
    required int page,
    required int limit,
    String? subcategoryId,
  }) async {
    try {
      final response = await dio.get(
        ApiEndpoints.menuItems,
        queryParameters: {'page': page, 'limit': limit, 'subCategory': subcategoryId},
      );
      return (response.data as List).map((item) => MenuItemModel.fromJson(item)).toList();
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'getAllMenuItems({required int page, required int limit, String? subcategoryId})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<MenuItemModel> createMenuItem({
    required String name,
    required String subCategory,
    required double price,
    required bool isAvailable,
  }) async {
    try {
      final response = await dio.post(
        ApiEndpoints.menuItems,
        data: {
          'name': name,
          'subCategory': subCategory,
          'price': price,
          'isAvailable': isAvailable,
        },
      );
      return MenuItemModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'createMenuItem({required String name, required String subCategory, required double price, required bool isAvailable})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<MenuItemModel> updateMenuItem({
    required String id,
    required String name,
    required String subCategoryId,
    required double price,
    required bool isAvailable,
  }) async {
    try {
      final response = await dio.patch(
        ApiEndpoints.singleMenuItem(id),
        data: {
          'name': name,
          'subCategory': subCategoryId,
          'price': price,
          'isAvailable': isAvailable,
        },
      );
      return MenuItemModel.fromJson(response.data);
    } on DioException catch (e, s) {
      handleDioException(
        e,
        s,
        'updateMenuItem({required String id, required String name, required String subCategoryId, required double price, required bool isAvailable})',
      );
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }

  @override
  Future<void> deleteMenuItem({required String id}) async {
    try {
      await dio.delete(ApiEndpoints.singleMenuItem(id));
    } on DioException catch (e, s) {
      handleDioException(e, s, 'deleteMenuItem({required String id})');
    } catch (e, s) {
      throw ServerException(message: e.toString(), stackTrace: s);
    }
  }
}
