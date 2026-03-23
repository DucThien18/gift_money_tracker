import '../enums/sort_order.dart';

class SortService {
  const SortService();

  List<T> sortByString<T>({
    required List<T> items,
    required String Function(T item) selector,
    required SortOrder order,
  }) {
    final List<T> copied = List<T>.from(items);
    copied.sort((T a, T b) {
      final int compared = selector(a).compareTo(selector(b));
      return order == SortOrder.ascending ? compared : -compared;
    });
    return copied;
  }

  List<T> sortByInt<T>({
    required List<T> items,
    required int Function(T item) selector,
    required SortOrder order,
  }) {
    final List<T> copied = List<T>.from(items);
    copied.sort((T a, T b) {
      final int compared = selector(a).compareTo(selector(b));
      return order == SortOrder.ascending ? compared : -compared;
    });
    return copied;
  }
}
