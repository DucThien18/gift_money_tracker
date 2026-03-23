class StringNormalizer {
  StringNormalizer._();

  static String normalizeForSearch(String input) {
    return input.toLowerCase().trim().replaceAll(RegExp(r'\s+'), ' ');
  }
}
