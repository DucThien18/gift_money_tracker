import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/sort_field.dart';
import '../../../../core/enums/sort_order.dart';
import '../../../../core/services/search_service.dart';
import '../../../../core/services/sort_service.dart';
import '../../../guest_records/domain/entities/guest_record_entity.dart';
import '../../../guest_records/presentation/providers/guest_record_providers.dart';

// ---------------------------------------------------------------------------
// Service providers
// ---------------------------------------------------------------------------

/// Provider cho [SearchService] — stateless, const instance.
final searchServiceProvider = Provider<SearchService>((ref) {
  return const SearchService();
});

/// Provider cho [SortService] — stateless, const instance.
final sortServiceProvider = Provider<SortService>((ref) {
  return const SortService();
});

// ---------------------------------------------------------------------------
// SearchSortState
// ---------------------------------------------------------------------------

/// State chứa toàn bộ tham số search / sort / filter của màn hình guest records.
class SearchSortState {
  const SearchSortState({
    this.keyword = '',
    this.sortField = SortField.createdAt,
    this.sortOrder = SortOrder.descending,
    this.filterDebtPaid, // null = tất cả, true = đã trả, false = chưa trả
  });

  final String keyword;
  final SortField sortField;
  final SortOrder sortOrder;
  final bool? filterDebtPaid;

  SearchSortState copyWith({
    String? keyword,
    SortField? sortField,
    SortOrder? sortOrder,
    // Dùng Object? sentinel để phân biệt "set null" vs "không đổi"
    Object? filterDebtPaid = _sentinel,
  }) {
    return SearchSortState(
      keyword: keyword ?? this.keyword,
      sortField: sortField ?? this.sortField,
      sortOrder: sortOrder ?? this.sortOrder,
      filterDebtPaid: filterDebtPaid == _sentinel
          ? this.filterDebtPaid
          : filterDebtPaid as bool?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is SearchSortState &&
        other.keyword == keyword &&
        other.sortField == sortField &&
        other.sortOrder == sortOrder &&
        other.filterDebtPaid == filterDebtPaid;
  }

  @override
  int get hashCode =>
      Object.hash(keyword, sortField, sortOrder, filterDebtPaid);
}

// Sentinel object để phân biệt "không truyền" vs "truyền null"
const Object _sentinel = Object();

// ---------------------------------------------------------------------------
// SearchSortNotifier
// ---------------------------------------------------------------------------

/// Notifier quản lý [SearchSortState].
class SearchSortNotifier extends StateNotifier<SearchSortState> {
  SearchSortNotifier() : super(const SearchSortState());

  /// Cập nhật keyword tìm kiếm.
  void setKeyword(String keyword) {
    state = state.copyWith(keyword: keyword);
  }

  /// Xóa keyword tìm kiếm.
  void clearKeyword() {
    state = state.copyWith(keyword: '');
  }

  /// Đổi trường sort. Nếu đang sort cùng field → toggle order.
  void setSortField(SortField field) {
    if (state.sortField == field) {
      // Toggle ascending ↔ descending
      final SortOrder newOrder = state.sortOrder == SortOrder.ascending
          ? SortOrder.descending
          : SortOrder.ascending;
      state = state.copyWith(sortOrder: newOrder);
    } else {
      state = state.copyWith(sortField: field, sortOrder: SortOrder.ascending);
    }
  }

  /// Đặt thứ tự sort trực tiếp.
  void setSortOrder(SortOrder order) {
    state = state.copyWith(sortOrder: order);
  }

  /// Đặt filter trạng thái trả nợ.
  /// [null] = tất cả, [true] = đã trả, [false] = chưa trả.
  void setFilterDebtPaid(bool? value) {
    state = state.copyWith(filterDebtPaid: value);
  }

  /// Reset toàn bộ state về mặc định.
  void reset() {
    state = const SearchSortState();
  }
}

// ---------------------------------------------------------------------------
// Providers
// ---------------------------------------------------------------------------

/// Provider cho [SearchSortNotifier].
final searchSortProvider =
    StateNotifierProvider<SearchSortNotifier, SearchSortState>((ref) {
      return SearchSortNotifier();
    });

/// Derived provider: lấy danh sách [GuestRecordEntity] theo [eventListId],
/// sau đó áp dụng search → filter → sort từ [searchSortProvider].
///
/// Dùng `.family` để truyền [eventListId].
final filteredGuestRecordsProvider =
    FutureProvider.family<List<GuestRecordEntity>, int>((
      ref,
      int eventListId,
    ) async {
      // Lấy use case
      // Lấy state search/sort/filter
      final SearchSortState searchSortState = ref.watch(searchSortProvider);

      // Lấy services
      final SearchService searchService = ref.watch(searchServiceProvider);
      final SortService sortService = ref.watch(sortServiceProvider);

      // 1. Lấy dữ liệu gốc từ repository
      List<GuestRecordEntity> records = await ref.watch(
        guestRecordsProvider(eventListId).future,
      );

      // 2. Áp dụng search (filter theo keyword)
      if (searchSortState.keyword.isNotEmpty) {
        records = searchService.filterGuestRecords(
          records: records,
          keyword: searchSortState.keyword,
        );
      }

      // 3. Áp dụng filter trạng thái trả nợ
      if (searchSortState.filterDebtPaid != null) {
        records = records
            .where(
              (GuestRecordEntity r) =>
                  r.isDebtPaid == searchSortState.filterDebtPaid,
            )
            .toList();
      }

      // 4. Áp dụng sort
      records = sortService.sortGuestRecords(
        records: records,
        field: searchSortState.sortField,
        order: searchSortState.sortOrder,
      );

      return records;
    });
