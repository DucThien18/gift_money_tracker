import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gift_money_tracker/core/errors/import_exception.dart';
import 'package:gift_money_tracker/core/services/excel_import_service.dart';
import 'package:gift_money_tracker/features/excel_import/domain/entities/import_preview_row.dart';
import 'package:gift_money_tracker/features/excel_import/domain/usecases/import_excel_usecase.dart';
import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';
import 'package:gift_money_tracker/features/guest_records/domain/repositories/guest_record_repository.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────
class MockGuestRecordRepository extends Mock implements GuestRecordRepository {}

class MockExcelImportService extends Mock implements ExcelImportService {}

// ── Fakes (cần cho registerFallbackValue với mocktail) ───────────────────────
class FakeGuestRecordEntity extends Fake implements GuestRecordEntity {}

// ── Helpers ──────────────────────────────────────────────────────────────────
ImportPreviewRow _validRow(int rowNum, String name, int amount) =>
    ImportPreviewRow(
      rowNumber: rowNum,
      fullNameRaw: name,
      noteRaw: 'ghi chú',
      amountRaw: amount.toString(),
      isDebtPaidRaw: '',
      parsedFullName: name,
      parsedNote: 'ghi chú',
      parsedAmount: amount,
      parsedIsDebtPaid: false,
      errors: const [],
    );

ImportPreviewRow _invalidRow(int rowNum) => ImportPreviewRow(
  rowNumber: rowNum,
  fullNameRaw: '',
  noteRaw: '',
  amountRaw: '',
  isDebtPaidRaw: '',
  parsedFullName: null,
  parsedNote: '',
  parsedAmount: null,
  parsedIsDebtPaid: false,
  errors: const ['Họ tên không được để trống'],
);

GuestRecordEntity _entityFrom(ImportPreviewRow row, int eventListId) =>
    GuestRecordEntity(
      id: 0,
      eventListId: eventListId,
      fullName: row.parsedFullName!,
      note: row.parsedNote ?? '',
      amount: row.parsedAmount ?? 0,
      isDebtPaid: row.parsedIsDebtPaid ?? false,
      createdAt: DateTime(2024),
      updatedAt: DateTime(2024),
    );

void main() {
  setUpAll(() {
    // mocktail yêu cầu đăng ký fallback value cho các type custom
    registerFallbackValue(FakeGuestRecordEntity());
    registerFallbackValue(<GuestRecordEntity>[]);
  });

  late MockGuestRecordRepository mockRepo;
  late MockExcelImportService mockService;
  late ImportExcelUseCase useCase;

  // Bytes giả — service đã được mock nên không cần Excel thực
  final Uint8List fakeBytes = Uint8List.fromList([1, 2, 3, 4, 5]);

  setUp(() {
    mockRepo = MockGuestRecordRepository();
    mockService = MockExcelImportService();
    useCase = ImportExcelUseCase(
      excelImportService: mockService,
      guestRecordRepository: mockRepo,
    );
    // Stub createMany() mặc định: trả về danh sách entity được truyền vào
    when(() => mockRepo.createMany(any())).thenAnswer(
      (inv) async => inv.positionalArguments[0] as List<GuestRecordEntity>,
    );
  });

  // ── execute() ──────────────────────────────────────────────────────────────
  group('ImportExcelUseCase.execute', () {
    test(
      '2 rows hợp lệ → importedCount=2, errorCount=0, skippedCount=0',
      () async {
        final rows = [
          _validRow(1, 'Nguyễn Văn A', 500000),
          _validRow(2, 'Trần Thị B', 200000),
        ];
        final entities = rows.map((r) => _entityFrom(r, 1)).toList();

        when(() => mockService.parseFile(fakeBytes)).thenReturn(rows);
        when(() => mockService.validateRows(rows)).thenReturn(rows);
        when(
          () => mockService.toGuestRecordEntities(rows, 1),
        ).thenReturn(entities);
        when(() => mockService.countErrors(rows)).thenReturn(0);

        final result = await useCase.execute(eventListId: 1, bytes: fakeBytes);

        expect(result.totalRows, 2);
        expect(result.importedCount, 2);
        expect(result.errorCount, 0);
        expect(result.skippedCount, 0);
        verify(() => mockRepo.createMany(entities)).called(1);
      },
    );

    test('1 valid + 1 invalid → importedCount=1, errorCount=1', () async {
      final parsed = [_validRow(1, 'Nguyễn Văn A', 100000), _invalidRow(2)];
      final entities = [_entityFrom(_validRow(1, 'Nguyễn Văn A', 100000), 1)];

      when(() => mockService.parseFile(fakeBytes)).thenReturn(parsed);
      when(() => mockService.validateRows(parsed)).thenReturn(parsed);
      when(
        () => mockService.toGuestRecordEntities(parsed, 1),
      ).thenReturn(entities);
      when(() => mockService.countErrors(parsed)).thenReturn(1);

      final result = await useCase.execute(eventListId: 1, bytes: fakeBytes);

      expect(result.totalRows, 2);
      expect(result.importedCount, 1);
      expect(result.errorCount, 1);
      verify(() => mockRepo.createMany(entities)).called(1);
    });

    test(
      'parseFile trả về rỗng → ném ImportException, không gọi createMany()',
      () async {
        when(() => mockService.parseFile(fakeBytes)).thenReturn([]);

        expect(
          () => useCase.execute(eventListId: 1, bytes: fakeBytes),
          throwsA(isA<ImportException>()),
        );
        verifyNever(() => mockRepo.createMany(any()));
      },
    );

    test(
      '3 rows hợp lệ → createMany() được gọi đúng 1 lần với đủ 3 rows',
      () async {
        final rows = [
          _validRow(1, 'A', 100000),
          _validRow(2, 'B', 200000),
          _validRow(3, 'C', 300000),
        ];
        final entities = rows.map((r) => _entityFrom(r, 5)).toList();

        when(() => mockService.parseFile(fakeBytes)).thenReturn(rows);
        when(() => mockService.validateRows(rows)).thenReturn(rows);
        when(
          () => mockService.toGuestRecordEntities(rows, 5),
        ).thenReturn(entities);
        when(() => mockService.countErrors(rows)).thenReturn(0);

        await useCase.execute(eventListId: 5, bytes: fakeBytes);
        verify(() => mockRepo.createMany(entities)).called(1);
      },
    );

    test(
      'tất cả rows invalid → importedCount=0, createMany() không được gọi',
      () async {
        final rows = [_invalidRow(1), _invalidRow(2)];

        when(() => mockService.parseFile(fakeBytes)).thenReturn(rows);
        when(() => mockService.validateRows(rows)).thenReturn(rows);
        when(() => mockService.toGuestRecordEntities(rows, 1)).thenReturn([]);
        when(() => mockService.countErrors(rows)).thenReturn(2);

        final result = await useCase.execute(eventListId: 1, bytes: fakeBytes);

        expect(result.importedCount, 0);
        expect(result.errorCount, 2);
        verifyNever(() => mockRepo.createMany(any()));
      },
    );

    test('skippedCount không âm', () async {
      final rows = [_validRow(1, 'A', 100000)];
      final entities = [_entityFrom(rows[0], 1)];

      when(() => mockService.parseFile(fakeBytes)).thenReturn(rows);
      when(() => mockService.validateRows(rows)).thenReturn(rows);
      when(
        () => mockService.toGuestRecordEntities(rows, 1),
      ).thenReturn(entities);
      when(() => mockService.countErrors(rows)).thenReturn(0);

      final result = await useCase.execute(eventListId: 1, bytes: fakeBytes);
      expect(result.skippedCount, greaterThanOrEqualTo(0));
    });

    test('ImportResult.toString() chứa thông tin tóm tắt', () async {
      final rows = [_validRow(1, 'A', 100000)];
      final entities = [_entityFrom(rows[0], 1)];

      when(() => mockService.parseFile(fakeBytes)).thenReturn(rows);
      when(() => mockService.validateRows(rows)).thenReturn(rows);
      when(
        () => mockService.toGuestRecordEntities(rows, 1),
      ).thenReturn(entities);
      when(() => mockService.countErrors(rows)).thenReturn(0);

      final result = await useCase.execute(eventListId: 1, bytes: fakeBytes);
      expect(result.toString(), contains('total'));
      expect(result.toString(), contains('imported'));
    });
  });

  // ── previewFile() ──────────────────────────────────────────────────────────
  group('ImportExcelUseCase.previewFile', () {
    test('trả về danh sách rows đã validate', () {
      final parsed = [_validRow(1, 'A', 100000)];
      final validated = [_validRow(1, 'A', 100000)];

      when(() => mockService.parseFile(fakeBytes)).thenReturn(parsed);
      when(() => mockService.validateRows(parsed)).thenReturn(validated);

      final result = useCase.previewFile(fakeBytes);
      expect(result, validated);
    });

    test('file rỗng → trả về danh sách rỗng', () {
      when(() => mockService.parseFile(fakeBytes)).thenReturn([]);
      when(() => mockService.validateRows([])).thenReturn([]);

      final result = useCase.previewFile(fakeBytes);
      expect(result, isEmpty);
    });

    test('gọi parseFile và validateRows đúng thứ tự', () {
      final parsed = [_validRow(1, 'A', 100000)];

      when(() => mockService.parseFile(fakeBytes)).thenReturn(parsed);
      when(() => mockService.validateRows(parsed)).thenReturn(parsed);

      useCase.previewFile(fakeBytes);

      verifyInOrder([
        () => mockService.parseFile(fakeBytes),
        () => mockService.validateRows(parsed),
      ]);
    });

    test('nhiều rows mix valid/invalid → trả về đúng danh sách', () {
      final parsed = [
        _validRow(1, 'A', 100000),
        _invalidRow(2),
        _validRow(3, 'C', 300000),
      ];

      when(() => mockService.parseFile(fakeBytes)).thenReturn(parsed);
      when(() => mockService.validateRows(parsed)).thenReturn(parsed);

      final result = useCase.previewFile(fakeBytes);
      expect(result.length, 3);
      expect(result.where((r) => r.isValid).length, 2);
      expect(result.where((r) => r.hasErrors).length, 1);
    });
  });
}
