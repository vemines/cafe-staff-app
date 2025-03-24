extension StringExt on String {
  String get capitalize {
    if (isEmpty || trim().isEmpty) return '';

    return split(' ').map((word) => word.upperCaseFirstLetter).join(' ');
  }

  String get upperCaseFirstLetter {
    if (isEmpty || trim().isEmpty) return '';

    return "${this[0].toUpperCase()}${substring(1)}";
  }
}
