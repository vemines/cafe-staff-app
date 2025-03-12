enum PaginationOrder { desc, asc }

extension PaginationOrderEnumExt on PaginationOrder? {
  String getString() {
    if (this == null) return 'desc';

    switch (this!) {
      case PaginationOrder.desc:
        return 'desc';
      case PaginationOrder.asc:
        return 'asc';
    }
  }
}
