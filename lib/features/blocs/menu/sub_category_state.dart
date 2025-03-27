part of 'sub_category_cubit.dart';

abstract class SubCategoryState extends Equatable {
  const SubCategoryState();

  @override
  List<Object?> get props => [];
}

class SubCategoryInitial extends SubCategoryState {}

class SubCategoryLoading extends SubCategoryState {}

class SubCategoryLoaded extends SubCategoryState {
  final List<SubcategoryEntity> subCategories;

  const SubCategoryLoaded({required this.subCategories});

  @override
  List<Object?> get props => [subCategories];
}

class SubCategoryError extends SubCategoryState {
  final Failure failure;

  const SubCategoryError({required this.failure});

  @override
  List<Object> get props => [failure];
}
