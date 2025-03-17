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

enum TableStatus { pending, served, completed }

extension TableStatusExt on String {
  TableStatus toTableStatus() {
    switch (this) {
      case 'pending':
        return TableStatus.pending;
      case 'served':
        return TableStatus.served;
      case 'complete':
      default:
        return TableStatus.completed;
    }
  }
}
