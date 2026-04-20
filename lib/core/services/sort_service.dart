import '../../features/guest_records/domain/entities/guest_record_entity.dart';
import '../enums/sort_field.dart';
import '../enums/sort_order.dart';

class SortService {
  const SortService();

  /// Sort generic theo chuỗi String
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

  /// Sort generic theo số nguyên int
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

  /// Sort generic theo DateTime
  List<T> sortByDateTime<T>({
    required List<T> items,
    required DateTime Function(T item) selector,
    required SortOrder order,
  }) {
    final List<T> copied = List<T>.from(items);
    copied.sort((T a, T b) {
      final int compared = selector(a).compareTo(selector(b));
      return order == SortOrder.ascending ? compared : -compared;
    });
    return copied;
  }

  /// Sort generic theo bool (false < true khi ascending)
  List<T> sortByBool<T>({
    required List<T> items,
    required bool Function(T item) selector,
    required SortOrder order,
  }) {
    final List<T> copied = List<T>.from(items);
    copied.sort((T a, T b) {
      // false = 0, true = 1
      final int aVal = selector(a) ? 1 : 0;
      final int bVal = selector(b) ? 1 : 0;
      final int compared = aVal.compareTo(bVal);
      return order == SortOrder.ascending ? compared : -compared;
    });
    return copied;
  }

  /// Sort danh sách [GuestRecordEntity] theo [SortField] và [SortOrder].
  /// Đây là method chính dùng trong UI/provider.
  List<GuestRecordEntity> sortGuestRecords({
    required List<GuestRecordEntity> records,
    required SortField field,
    required SortOrder order,
  }) {
    switch (field) {
      case SortField.fullName:
        return sortByString<GuestRecordEntity>(
          items: records,
          selector: (GuestRecordEntity r) => r.fullName,
          order: order,
        );
      case SortField.note:
        return sortByString<GuestRecordEntity>(
          items: records,
          selector: (GuestRecordEntity r) => r.note,
          order: order,
        );
      case SortField.amount:
        return sortByInt<GuestRecordEntity>(
          items: records,
          selector: (GuestRecordEntity r) => r.amount,
          order: order,
        );
      case SortField.createdAt:
        return sortByDateTime<GuestRecordEntity>(
          items: records,
          selector: (GuestRecordEntity r) => r.createdAt,
          order: order,
        );
      case SortField.isDebtPaid:
        return sortByBool<GuestRecordEntity>(
          items: records,
          selector: (GuestRecordEntity r) => r.isDebtPaid,
          order: order,
        );
    }
  }
}
