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
