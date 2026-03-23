import '../utils/string_normalizer.dart';

class SearchService {
  const SearchService();

  bool matchesKeyword({
    required String keyword,
    required List<String> candidates,
  }) {
    final String normalizedKeyword = StringNormalizer.normalizeForSearch(
      keyword,
    );
    if (normalizedKeyword.isEmpty) {
      return true;
    }

    for (final String candidate in candidates) {
      final String normalizedCandidate = StringNormalizer.normalizeForSearch(
        candidate,
      );
      if (normalizedCandidate.contains(normalizedKeyword)) {
        return true;
      }
    }
    return false;
  }
}
