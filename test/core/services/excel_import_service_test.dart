import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/core/services/excel_import_service.dart';
import 'package:gift_money_tracker/features/excel_import/domain/entities/import_preview_row.dart';

void main() {
  late ExcelImportService service;

  setUp(() {
    service = const ExcelImportService();
  });

  // ── validateRows ────────────────────────────────────────────────────────────
  group('ExcelImportService.validateRows', () {
    test('row hợp lệ đầy đủ → không có lỗi', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          fullNameRaw: 'Nguyễn Văn A',
          amountRaw: '500000',
          parsedFullName: 'Nguyễn Văn A',
          parsedAmount: 500000,
          parsedIsDebtPaid: false,
        ),
      ];
      final List<ImportPreviewRow> result = service.validateRows(rows);
      expect(result.first.errors, isEmpty);
      expect(result.first.isValid, true);
    });

    test('row thiếu họ tên → có lỗi', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 2,
          fullNameRaw: '',
          parsedFullName: null,
          parsedAmount: 100000,
        ),
      ];
      final List<ImportPreviewRow> result = service.validateRows(rows);
      expect(result.first.hasErrors, true);
      expect(result.first.errors.first, contains('Họ tên'));
    });

    test('row có amount raw nhưng parse thất bại → có lỗi', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 3,
          fullNameRaw: 'Trần B',
          parsedFullName: 'Trần B',
          amountRaw: 'abc_invalid',
          parsedAmount: null,
        ),
      ];
      final List<ImportPreviewRow> result = service.validateRows(rows);
      expect(result.first.hasErrors, true);
      expect(result.first.errors.first, contains('Số tiền'));
    });

    test('row có amount âm → có lỗi', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 4,
          fullNameRaw: 'Lê C',
          parsedFullName: 'Lê C',
          amountRaw: '-100000',
          parsedAmount: -100000,
        ),
      ];
      final List<ImportPreviewRow> result = service.validateRows(rows);
      expect(result.first.hasErrors, true);
      expect(result.first.errors.first, contains('âm'));
    });

    test('row không có amount raw → không lỗi amount', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 5,
          fullNameRaw: 'Phạm D',
          parsedFullName: 'Phạm D',
          amountRaw: null,
          parsedAmount: null,
        ),
      ];
      final List<ImportPreviewRow> result = service.validateRows(rows);
      expect(result.first.errors, isEmpty);
    });

    test('nhiều rows — mix valid và invalid', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          fullNameRaw: 'Nguyễn A',
          parsedFullName: 'Nguyễn A',
          parsedAmount: 500000,
        ),
        const ImportPreviewRow(
          rowNumber: 2,
          fullNameRaw: '',
          parsedFullName: null,
        ),
        const ImportPreviewRow(
          rowNumber: 3,
          fullNameRaw: 'Trần B',
          parsedFullName: 'Trần B',
          amountRaw: 'xyz',
          parsedAmount: null,
        ),
      ];
      final List<ImportPreviewRow> result = service.validateRows(rows);
      expect(result[0].isValid, true);
      expect(result[1].hasErrors, true);
      expect(result[2].hasErrors, true);
    });

    test('danh sách rỗng → trả về rỗng', () {
      final List<ImportPreviewRow> result = service.validateRows([]);
      expect(result, isEmpty);
    });
  });

  // ── toGuestRecordEntities ───────────────────────────────────────────────────
  group('ExcelImportService.toGuestRecordEntities', () {
    test('chỉ lấy row hợp lệ', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          parsedFullName: 'Nguyễn A',
          parsedNote: 'Bạn thân',
          parsedAmount: 500000,
          parsedIsDebtPaid: false,
        ),
        const ImportPreviewRow(
          rowNumber: 2,
          parsedFullName: null, // invalid
          errors: ['Họ tên không được để trống'],
        ),
      ];
      final entities = service.toGuestRecordEntities(rows, 1);
      expect(entities.length, 1);
      expect(entities.first.fullName, 'Nguyễn A');
    });

    test('entity được gán đúng eventListId', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          parsedFullName: 'Trần B',
          parsedAmount: 200000,
          parsedIsDebtPaid: true,
        ),
      ];
      final entities = service.toGuestRecordEntities(rows, 42);
      expect(entities.first.eventListId, 42);
    });

    test('entity id = 0 (Isar tự assign)', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          parsedFullName: 'Lê C',
          parsedAmount: 100000,
        ),
      ];
      final entities = service.toGuestRecordEntities(rows, 1);
      expect(entities.first.id, 0);
    });

    test('amount null → entity amount = 0', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          parsedFullName: 'Phạm D',
          parsedAmount: null,
        ),
      ];
      final entities = service.toGuestRecordEntities(rows, 1);
      expect(entities.first.amount, 0);
    });

    test('isDebtPaid null → entity isDebtPaid = false', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          parsedFullName: 'Hoàng E',
          parsedIsDebtPaid: null,
        ),
      ];
      final entities = service.toGuestRecordEntities(rows, 1);
      expect(entities.first.isDebtPaid, false);
    });

    test('note null → entity note = rỗng', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          parsedFullName: 'Vũ F',
          parsedNote: null,
        ),
      ];
      final entities = service.toGuestRecordEntities(rows, 1);
      expect(entities.first.note, '');
    });

    test('danh sách rỗng → trả về rỗng', () {
      final entities = service.toGuestRecordEntities([], 1);
      expect(entities, isEmpty);
    });

    test('tất cả row invalid → trả về rỗng', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(
          rowNumber: 1,
          parsedFullName: null,
          errors: ['Họ tên không được để trống'],
        ),
        const ImportPreviewRow(
          rowNumber: 2,
          parsedFullName: '',
          errors: ['Họ tên không được để trống'],
        ),
      ];
      final entities = service.toGuestRecordEntities(rows, 1);
      expect(entities, isEmpty);
    });
  });

  // ── countValid / countErrors ────────────────────────────────────────────────
  group('ExcelImportService.countValid / countErrors', () {
    test('đếm đúng số row hợp lệ và lỗi', () {
      final List<ImportPreviewRow> rows = [
        const ImportPreviewRow(rowNumber: 1, parsedFullName: 'A'),
        const ImportPreviewRow(
          rowNumber: 2,
          parsedFullName: null,
          errors: ['lỗi'],
        ),
        const ImportPreviewRow(rowNumber: 3, parsedFullName: 'B'),
      ];
      expect(service.countValid(rows), 2);
      expect(service.countErrors(rows), 1);
    });
  });
}
