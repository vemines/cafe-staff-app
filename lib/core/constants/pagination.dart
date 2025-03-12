class PaginationStorage {
  int currentPage;
  int limit;
  bool hasMore;

  PaginationStorage({this.currentPage = 1, this.limit = 5, this.hasMore = true});

  PaginationStorage copyWith({int? currentPage, int? limit, bool? hasMore}) {
    return PaginationStorage(
      currentPage: currentPage ?? this.currentPage,
      limit: limit ?? this.limit,
      hasMore: hasMore ?? this.hasMore,
    );
  }
}
