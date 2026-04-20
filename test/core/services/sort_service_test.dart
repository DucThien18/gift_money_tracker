import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/core/enums/sort_field.dart';
import 'package:gift_money_tracker/core/enums/sort_order.dart';
import 'package:gift_money_tracker/core/services/sort_service.dart';
import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';

void main() {
  const SortService sortService = SortService();

  final DateTime t1 = DateTime(2024, 1, 1);
  final DateTime t2 = DateTime(2024, 6, 1);
  final DateTime t3 = DateTime(2024, 12, 1);

  // Helper tạo GuestRecordEntity nhanh
  GuestRecordEntity makeRecord({
    required int id,
    required String fullName,
    String note = '',
    required int amount,
    required bool isDebtPaid,
    required DateTime createdAt,
  }) {
    return GuestRecordEntity(
      id: id,
      eventListId: 1,
      fullName: fullName,
      note: note,
      amount: amount,
      isDebtPaid: isDebtPaid,
      createdAt: createdAt,
      updatedAt: createdAt,
    );
  }

  final List<GuestRecordEntity> sampleRecords = [
    makeRecord(
      id: 1,
      fullName: 'Nguyễn Văn C',
      amount: 500000,
      isDebtPaid: false,
      createdAt: t2,
    ),
    makeRecord(
      id: 2,
      fullName: 'Trần Thị A',
      amount: 200000,
      isDebtPaid: true,
      createdAt: t1,
    ),
    makeRecord(
      id: 3,
      fullName: 'Lê Văn B',
      amount: 800000,
      isDebtPaid: false,
      createdAt: t3,
    ),
  ];

  // ---------------------------------------------------------------------------
  group('SortService.sortByString', () {
    test('sort ascending', () {
      final result = sortService.sortByString<String>(
        items: ['banana', 'apple', 'cherry'],
        selector: (s) => s,
        order: SortOrder.ascending,
      );
      expect(result, ['apple', 'banana', 'cherry']);
    });

    test('sort descending', () {
      final result = sortService.sortByString<String>(
        items: ['banana', 'apple', 'cherry'],
        selector: (s) => s,
        order: SortOrder.descending,
      );
      expect(result, ['cherry', 'banana', 'apple']);
    });

    test('không thay đổi list gốc (immutable)', () {
      final original = ['banana', 'apple'];
      sortService.sortByString<String>(
        items: original,
        selector: (s) => s,
        order: SortOrder.ascending,
      );
      expect(original, ['banana', 'apple']); // list gốc không đổi
    });
  });

  // ---------------------------------------------------------------------------
  group('SortService.sortByInt', () {
    test('sort ascending', () {
      final result = sortService.sortByInt<int>(
        items: [300, 100, 200],
        selector: (n) => n,
        order: SortOrder.ascending,
      );
      expect(result, [100, 200, 300]);
    });

    test('sort descending', () {
      final result = sortService.sortByInt<int>(
        items: [300, 100, 200],
        selector: (n) => n,
        order: SortOrder.descending,
      );
      expect(result, [300, 200, 100]);
    });
  });

  // ---------------------------------------------------------------------------
  group('SortService.sortByDateTime', () {
    test('sort ascending (cũ nhất trước)', () {
      final result = sortService.sortByDateTime<DateTime>(
        items: [t3, t1, t2],
        selector: (d) => d,
        order: SortOrder.ascending,
      );
      expect(result, [t1, t2, t3]);
    });

    test('sort descending (mới nhất trước)', () {
      final result = sortService.sortByDateTime<DateTime>(
        items: [t3, t1, t2],
        selector: (d) => d,
        order: SortOrder.descending,
      );
      expect(result, [t3, t2, t1]);
    });
  });

  // ---------------------------------------------------------------------------
  group('SortService.sortByBool', () {
    test('ascending: false trước, true sau', () {
      final result = sortService.sortByBool<bool>(
        items: [true, false, true, false],
        selector: (b) => b,
        order: SortOrder.ascending,
      );
      expect(result, [false, false, true, true]);
    });

    test('descending: true trước, false sau', () {
      final result = sortService.sortByBool<bool>(
        items: [true, false, true, false],
        selector: (b) => b,
        order: SortOrder.descending,
      );
      expect(result, [true, true, false, false]);
    });
  });

  // ---------------------------------------------------------------------------
  group('SortService.sortGuestRecords', () {
    test('sort theo fullName ascending', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.fullName,
        order: SortOrder.ascending,
      );
      // Lê < Nguyễn < Trần theo alphabet
      expect(result[0].fullName, 'Lê Văn B');
      expect(result[1].fullName, 'Nguyễn Văn C');
      expect(result[2].fullName, 'Trần Thị A');
    });

    test('sort theo fullName descending', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.fullName,
        order: SortOrder.descending,
      );
      expect(result[0].fullName, 'Trần Thị A');
      expect(result[2].fullName, 'Lê Văn B');
    });

    test('sort theo amount ascending', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.amount,
        order: SortOrder.ascending,
      );
      expect(result[0].amount, 200000);
      expect(result[1].amount, 500000);
      expect(result[2].amount, 800000);
    });

    test('sort theo amount descending', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.amount,
        order: SortOrder.descending,
      );
      expect(result[0].amount, 800000);
      expect(result[2].amount, 200000);
    });

    test('sort theo createdAt ascending (cũ nhất trước)', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.createdAt,
        order: SortOrder.ascending,
      );
      expect(result[0].createdAt, t1);
      expect(result[1].createdAt, t2);
      expect(result[2].createdAt, t3);
    });

    test('sort theo createdAt descending (mới nhất trước)', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.createdAt,
        order: SortOrder.descending,
      );
      expect(result[0].createdAt, t3);
      expect(result[2].createdAt, t1);
    });

    test('sort theo isDebtPaid ascending (chưa trả trước)', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.isDebtPaid,
        order: SortOrder.ascending,
      );
      // false (chưa trả) trước, true (đã trả) sau
      expect(result.first.isDebtPaid, isFalse);
      expect(result.last.isDebtPaid, isTrue);
    });

    test('sort theo isDebtPaid descending (đã trả trước)', () {
      final result = sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.isDebtPaid,
        order: SortOrder.descending,
      );
      expect(result.first.isDebtPaid, isTrue);
    });

    test('danh sách rỗng → trả về rỗng', () {
      final result = sortService.sortGuestRecords(
        records: [],
        field: SortField.amount,
        order: SortOrder.ascending,
      );
      expect(result, isEmpty);
    });

    test('không thay đổi list gốc (immutable)', () {
      final original = List<GuestRecordEntity>.from(sampleRecords);
      sortService.sortGuestRecords(
        records: sampleRecords,
        field: SortField.amount,
        order: SortOrder.ascending,
      );
      // Thứ tự list gốc không đổi
      expect(sampleRecords[0].id, original[0].id);
      expect(sampleRecords[1].id, original[1].id);
      expect(sampleRecords[2].id, original[2].id);
    });
  });
}
