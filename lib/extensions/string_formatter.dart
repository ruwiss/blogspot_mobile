extension StringFormatter on String {
  String capitalize() {
    return "${this[0].toUpperCase()}${substring(1).toLowerCase()}";
  }

  String formatUserName() {
    if (contains(' ')) {
      final splitted = split(' ');
      return '${splitted[0].capitalize()} ${splitted[1][0].toUpperCase()}';
    } else {
      return capitalize();
    }
  }

  String formatHtml() {
    return replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), '');
  }
}
