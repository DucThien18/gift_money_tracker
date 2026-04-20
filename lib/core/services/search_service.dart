import '../../features/event_lists/domain/entities/event_list_entity.dart';
import '../../features/guest_records/domain/entities/guest_record_entity.dart';
import '../utils/string_normalizer.dart';

class SearchService {
  const SearchService();

  /// Kiểm tra xem một item có khớp với keyword không.
  /// Tìm kiếm trong tất cả [candidates] (đã normalize).
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

  /// Filter danh sách [GuestRecordEntity] theo [keyword].
  /// Tìm kiếm trong: fullName, note.
  /// Nếu keyword rỗng → trả về toàn bộ danh sách.
  List<GuestRecordEntity> filterGuestRecords({
    required List<GuestRecordEntity> records,
    required String keyword,
  }) {
    final String normalizedKeyword = StringNormalizer.normalizeForSearch(
      keyword,
    );
    if (normalizedKeyword.isEmpty) {
      return records;
    }
    return records.where((GuestRecordEntity record) {
      return matchesKeyword(
        keyword: keyword,
        candidates: [record.fullName, record.note],
      );
    }).toList();
  }

  /// Filter danh sách [EventListEntity] theo [keyword].
  /// Tìm kiếm trong: name, code, description.
  /// Nếu keyword rỗng → trả về toàn bộ danh sách.
  List<EventListEntity> filterEventLists({
    required List<EventListEntity> eventLists,
    required String keyword,
  }) {
    final String normalizedKeyword = StringNormalizer.normalizeForSearch(
      keyword,
    );
    if (normalizedKeyword.isEmpty) {
      return eventLists;
    }
    return eventLists.where((EventListEntity eventList) {
      return matchesKeyword(
        keyword: keyword,
        candidates: [
          eventList.name,
          eventList.code,
          if (eventList.description != null) eventList.description!,
        ],
      );
    }).toList();
  }
}
