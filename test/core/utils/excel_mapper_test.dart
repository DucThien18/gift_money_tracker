import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/core/utils/excel_mapper.dart';
import 'package:gift_money_tracker/features/excel_import/domain/entities/import_preview_row.dart';

void main() {
  // ── parseAmount ─────────────────────────────────────────────────────────────
  group('ExcelMapper.parseAmount', () {
    test('null → null', () {
      expect(ExcelMapper.parseAmount(null), isNull);
    });

    test('chuỗi rỗng → null', () {
      expect(ExcelMapper.parseAmount(''), isNull);
    });

    test('số nguyên thông thường', () {
      expect(ExcelMapper.parseAmount('500000'), 500000);
    });

    test('số có dấu phẩy phân cách hàng nghìn: "500,000"', () {
      expect(ExcelMapper.parseAmount('500,000'), 500000);
    });

    test('số có dấu chấm phân cách hàng nghìn: "500.000"', () {
      expect(ExcelMapper.parseAmount('500.000'), 500000);
    });

    test('số có nhiều dấu phẩy: "1,000,000"', () {
      expect(ExcelMapper.parseAmount('1,000,000'), 1000000);
    });

    test('số có nhiều dấu chấm: "1.000.000"', () {
      expect(ExcelMapper.parseAmount('1.000.000'), 1000000);
    });

    test('hậu tố k (nghìn): "500k"', () {
      expect(ExcelMapper.parseAmount('500k'), 500000);
    });

    test('hậu tố k với số thập phân: "1.5k"', () {
      expect(ExcelMapper.parseAmount('1.5k'), 1500);
    });

    test('hậu tố tr (triệu): "1tr"', () {
      expect(ExcelMapper.parseAmount('1tr'), 1000000);
    });

    test('hậu tố tr với số thập phân: "1.5tr"', () {
      expect(ExcelMapper.parseAmount('1.5tr'), 1500000);
    });

    test('hậu tố triệu: "2triệu"', () {
      expect(ExcelMapper.parseAmount('2triệu'), 2000000);
    });

    test('hậu tố m (million): "2m"', () {
      expect(ExcelMapper.parseAmount('2m'), 2000000);
    });

    test('chuỗi không phải số → null', () {
      expect(ExcelMapper.parseAmount('abc'), isNull);
    });

    test('số 0', () {
      expect(ExcelMapper.parseAmount('0'), 0);
    });

    test('khoảng trắng xung quanh được trim: " 500000 "', () {
      expect(ExcelMapper.parseAmount(' 500000 '), 500000);
    });
  });

  // ── parseDebtPaid ───────────────────────────────────────────────────────────
  group('ExcelMapper.parseDebtPaid', () {
    test('null → null', () {
      expect(ExcelMapper.parseDebtPaid(null), isNull);
    });

    test('chuỗi rỗng → false', () {
      expect(ExcelMapper.parseDebtPaid(''), false);
    });

    test('"x" → true', () {
      expect(ExcelMapper.parseDebtPaid('x'), true);
    });

    test('"X" (hoa) → true', () {
      expect(ExcelMapper.parseDebtPaid('X'), true);
    });

    test('"có" → true', () {
      expect(ExcelMapper.parseDebtPaid('có'), true);
    });

    test('"yes" → true', () {
      expect(ExcelMapper.parseDebtPaid('yes'), true);
    });

    test('"true" → true', () {
      expect(ExcelMapper.parseDebtPaid('true'), true);
    });

    test('"1" → true', () {
      expect(ExcelMapper.parseDebtPaid('1'), true);
    });

    test('"không" → false', () {
      expect(ExcelMapper.parseDebtPaid('không'), false);
    });

    test('"no" → false', () {
      expect(ExcelMapper.parseDebtPaid('no'), false);
    });

    test('"false" → false', () {
      expect(ExcelMapper.parseDebtPaid('false'), false);
    });

    test('"0" → false', () {
      expect(ExcelMapper.parseDebtPaid('0'), false);
    });

    test('"chưa" → false', () {
      expect(ExcelMapper.parseDebtPaid('chưa'), false);
    });

    test('chuỗi không nhận ra → null', () {
      expect(ExcelMapper.parseDebtPaid('maybe'), isNull);
    });
  });

  // ── detectColumns ───────────────────────────────────────────────────────────
  group('ExcelMapper.detectColumns', () {
    test('detect đủ 4 cột với tên tiếng Việt', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns([
        'Họ tên',
        'Ghi chú',
        'Số tiền',
        'Trả nợ',
      ]);
      expect(map.fullNameIndex, 0);
      expect(map.noteIndex, 1);
      expect(map.amountIndex, 2);
      expect(map.isDebtPaidIndex, 3);
    });

    test('detect đủ 4 cột với tên tiếng Anh', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns([
        'Full Name',
        'Note',
        'Amount',
        'Debt Paid',
      ]);
      expect(map.fullNameIndex, 0);
      expect(map.noteIndex, 1);
      expect(map.amountIndex, 2);
      expect(map.isDebtPaidIndex, 3);
    });

    test('detect không phân biệt hoa/thường', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns([
        'HỌ TÊN',
        'GHI CHÚ',
        'SỐ TIỀN',
        'TRẢ NỢ',
      ]);
      expect(map.fullNameIndex, 0);
      expect(map.noteIndex, 1);
      expect(map.amountIndex, 2);
      expect(map.isDebtPaidIndex, 3);
    });

    test('detect cột "Tên" (alias ngắn)', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns(['Tên', 'Số tiền']);
      expect(map.fullNameIndex, 0);
      expect(map.amountIndex, 1);
    });

    test('không tìm thấy cột → index null', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns(['Col A', 'Col B']);
      expect(map.fullNameIndex, isNull);
      expect(map.noteIndex, isNull);
      expect(map.amountIndex, isNull);
      expect(map.isDebtPaidIndex, isNull);
    });

    test('hasFullName = true khi tìm thấy cột họ tên', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns(['Họ tên']);
      expect(map.hasFullName, true);
    });

    test('hasFullName = false khi không tìm thấy', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns(['Col A']);
      expect(map.hasFullName, false);
    });

    test('cột thứ tự bất kỳ vẫn detect đúng', () {
      final ExcelColumnMap map = ExcelMapper.detectColumns([
        'Trả nợ',
        'Số tiền',
        'Ghi chú',
        'Họ tên',
      ]);
      expect(map.isDebtPaidIndex, 0);
      expect(map.amountIndex, 1);
      expect(map.noteIndex, 2);
      expect(map.fullNameIndex, 3);
    });
  });

  // ── parseRow ────────────────────────────────────────────────────────────────
  group('ExcelMapper.parseRow', () {
    late ExcelColumnMap columnMap;

    setUp(() {
      columnMap = const ExcelColumnMap(
        fullNameIndex: 0,
        noteIndex: 1,
        amountIndex: 2,
        isDebtPaidIndex: 3,
      );
    });

    test('parse row đầy đủ dữ liệu', () {
      final ImportPreviewRow row = ExcelMapper.parseRow(1, [
        'Nguyễn Văn A',
        'Bạn thân',
        '500000',
        'x',
      ], columnMap);
      expect(row.rowNumber, 1);
      expect(row.parsedFullName, 'Nguyễn Văn A');
      expect(row.parsedNote, 'Bạn thân');
      expect(row.parsedAmount, 500000);
      expect(row.parsedIsDebtPaid, true);
      expect(row.errors, isEmpty);
    });

    test('parse row thiếu ghi chú → parsedNote rỗng', () {
      final ImportPreviewRow row = ExcelMapper.parseRow(2, [
        'Trần Thị B',
        null,
        '200000',
        '',
      ], columnMap);
      expect(row.parsedFullName, 'Trần Thị B');
      expect(row.parsedNote, '');
      expect(row.parsedAmount, 200000);
      expect(row.parsedIsDebtPaid, false);
    });

    test('parse row thiếu họ tên → parsedFullName null', () {
      final ImportPreviewRow row = ExcelMapper.parseRow(3, [
        '',
        'Ghi chú',
        '100000',
        '',
      ], columnMap);
      expect(row.parsedFullName, isNull);
    });

    test('parse row với số tiền dạng "1tr"', () {
      final ImportPreviewRow row = ExcelMapper.parseRow(4, [
        'Lê Văn C',
        '',
        '1tr',
        '',
      ], columnMap);
      expect(row.parsedAmount, 1000000);
    });

    test('parse row với cells ít hơn số cột → không crash', () {
      final ImportPreviewRow row = ExcelMapper.parseRow(5, [
        'Nguyễn D',
      ], columnMap);
      expect(row.parsedFullName, 'Nguyễn D');
      expect(row.parsedNote, '');
      expect(row.parsedAmount, isNull);
      expect(row.parsedIsDebtPaid, false);
    });

    test('rowNumber được gán đúng', () {
      final ImportPreviewRow row = ExcelMapper.parseRow(99, [
        'Test',
      ], const ExcelColumnMap(fullNameIndex: 0));
      expect(row.rowNumber, 99);
    });
  });
}
