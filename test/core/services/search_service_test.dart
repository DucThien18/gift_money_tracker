import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/core/services/search_service.dart';
import 'package:gift_money_tracker/features/event_lists/domain/entities/event_list_entity.dart';
import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';

void main() {
  const SearchService searchService = SearchService();

  // Helper tạo GuestRecordEntity nhanh
  GuestRecordEntity makeRecord({
    int id = 1,
    String fullName = '',
    String note = '',
    bool isDebtPaid = false,
    int amount = 0,
  }) {
    final now = DateTime(2024, 1, 1);
    return GuestRecordEntity(
      id: id,
      eventListId: 1,
      fullName: fullName,
      note: note,
      amount: amount,
      isDebtPaid: isDebtPaid,
      createdAt: now,
      updatedAt: now,
    );
  }

  // Helper tạo EventListEntity nhanh
  EventListEntity makeEventList({
    int id = 1,
    String name = '',
    String code = '',
    String? description,
  }) {
    final now = DateTime(2024, 1, 1);
    return EventListEntity(
      id: id,
      code: code,
      name: name,
      description: description,
      createdAt: now,
      updatedAt: now,
    );
  }

  // ---------------------------------------------------------------------------
  group('SearchService.matchesKeyword', () {
    test('keyword rỗng → luôn trả về true', () {
      expect(
        searchService.matchesKeyword(keyword: '', candidates: ['abc']),
        isTrue,
      );
    });

    test('keyword khớp chính xác', () {
      expect(
        searchService.matchesKeyword(
          keyword: 'nguyen',
          candidates: ['nguyen van a'],
        ),
        isTrue,
      );
    });

    test('keyword khớp một phần', () {
      expect(
        searchService.matchesKeyword(
          keyword: 'van',
          candidates: ['nguyen van a'],
        ),
        isTrue,
      );
    });

    test('keyword không khớp → false', () {
      expect(
        searchService.matchesKeyword(
          keyword: 'xyz',
          candidates: ['nguyen van a'],
        ),
        isFalse,
      );
    });

    test('tìm kiếm không phân biệt hoa/thường', () {
      expect(
        searchService.matchesKeyword(
          keyword: 'NGUYEN',
          candidates: ['Nguyễn Văn A'],
        ),
        isTrue,
      );
    });

    test('tìm kiếm không phân biệt dấu tiếng Việt', () {
      expect(
        searchService.matchesKeyword(
          keyword: 'nguyen',
          candidates: ['Nguyễn Văn A'],
        ),
        isTrue,
      );
      expect(
        searchService.matchesKeyword(
          keyword: 'Nguyễn',
          candidates: ['Nguyen Van A'],
        ),
        isTrue,
      );
    });

    test('khớp trong bất kỳ candidate nào', () {
      expect(
        searchService.matchesKeyword(
          keyword: 'tien cuoi',
          candidates: ['Nguyễn Văn A', 'tiền cưới'],
        ),
        isTrue,
      );
    });
  });

  // ---------------------------------------------------------------------------
  group('SearchService.filterGuestRecords', () {
    final List<GuestRecordEntity> records = [
      makeRecord(id: 1, fullName: 'Nguyễn Văn A', note: 'tiền mừng'),
      makeRecord(id: 2, fullName: 'Trần Thị B', note: 'quà cưới'),
      makeRecord(id: 3, fullName: 'Lê Văn C', note: 'tiền cưới'),
    ];

    test('keyword rỗng → trả về toàn bộ danh sách', () {
      final result = searchService.filterGuestRecords(
        records: records,
        keyword: '',
      );
      expect(result.length, 3);
    });

    test('tìm theo fullName', () {
      final result = searchService.filterGuestRecords(
        records: records,
        keyword: 'nguyen',
      );
      expect(result.length, 1);
      expect(result.first.fullName, 'Nguyễn Văn A');
    });

    test('tìm theo note', () {
      final result = searchService.filterGuestRecords(
        records: records,
        keyword: 'cuoi',
      );
      expect(result.length, 2); // "quà cưới" và "tiền cưới"
    });

    test('tìm không phân biệt dấu tiếng Việt', () {
      final result = searchService.filterGuestRecords(
        records: records,
        keyword: 'tien',
      );
      expect(result.length, 2); // "tiền mừng" và "tiền cưới"
    });

    test('keyword không khớp → danh sách rỗng', () {
      final result = searchService.filterGuestRecords(
        records: records,
        keyword: 'xyz123',
      );
      expect(result, isEmpty);
    });

    test('danh sách rỗng → trả về rỗng', () {
      final result = searchService.filterGuestRecords(
        records: [],
        keyword: 'nguyen',
      );
      expect(result, isEmpty);
    });
  });

  // ---------------------------------------------------------------------------
  group('SearchService.filterEventLists', () {
    final List<EventListEntity> eventLists = [
      makeEventList(id: 1, name: 'Đám cưới Anh', code: 'DC001'),
      makeEventList(
        id: 2,
        name: 'Sinh nhật Bình',
        code: 'SN002',
        description: 'tiệc sinh nhật 30 tuổi',
      ),
      makeEventList(id: 3, name: 'Tân gia Cường', code: 'TG003'),
    ];

    test('keyword rỗng → trả về toàn bộ', () {
      final result = searchService.filterEventLists(
        eventLists: eventLists,
        keyword: '',
      );
      expect(result.length, 3);
    });

    test('tìm theo name', () {
      final result = searchService.filterEventLists(
        eventLists: eventLists,
        keyword: 'cuoi',
      );
      expect(result.length, 1);
      expect(result.first.name, 'Đám cưới Anh');
    });

    test('tìm theo code', () {
      final result = searchService.filterEventLists(
        eventLists: eventLists,
        keyword: 'SN002',
      );
      expect(result.length, 1);
      expect(result.first.code, 'SN002');
    });

    test('tìm theo description', () {
      final result = searchService.filterEventLists(
        eventLists: eventLists,
        keyword: 'sinh nhat',
      );
      expect(result.length, 1);
      expect(result.first.name, 'Sinh nhật Bình');
    });

    test('keyword không khớp → rỗng', () {
      final result = searchService.filterEventLists(
        eventLists: eventLists,
        keyword: 'xyz999',
      );
      expect(result, isEmpty);
    });
  });
}
