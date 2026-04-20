import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'package:gift_money_tracker/core/enums/import_status.dart';
import 'package:gift_money_tracker/core/errors/import_exception.dart';
import 'package:gift_money_tracker/features/excel_import/domain/entities/import_preview_row.dart';
import 'package:gift_money_tracker/features/excel_import/domain/usecases/import_excel_usecase.dart';
import 'package:gift_money_tracker/features/excel_import/presentation/providers/excel_import_provider.dart';

// ── Mocks ────────────────────────────────────────────────────────────────────
class MockImportExcelUseCase extends Mock implements ImportExcelUseCase {}

/// FilePicker là PlatformInterface → phải dùng MockPlatformInterfaceMixin
/// để bypass kiểm tra token của plugin_platform_interface
class MockFilePicker extends Mock
    with MockPlatformInterfaceMixin
    implements FilePicker {}

// ── Testable subclass để expose state setter ──────────────────────────────────
/// StateNotifier.state là @protected, dùng subclass để set state trong test
class TestableExcelImportNotifier extends ExcelImportNotifier {
  TestableExcelImportNotifier(super.useCase);

  // ignore: use_setters_to_change_properties
  void setTestState(ExcelImportState newState) {
    state = newState;
  }
}

// ── Fakes ─────────────────────────────────────────────────────────────────────
class FakeImportResult extends Fake implements ImportResult {}

// ── Helpers ──────────────────────────────────────────────────────────────────
ImportPreviewRow _validRow(int rowNum, String name) => ImportPreviewRow(
  rowNumber: rowNum,
  fullNameRaw: name,
  noteRaw: '',
  amountRaw: '100000',
  isDebtPaidRaw: '',
  parsedFullName: name,
  parsedNote: '',
  parsedAmount: 100000,
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

void main() {
  setUpAll(() {
    // mocktail yêu cầu đăng ký fallback value cho các type custom
    registerFallbackValue(Uint8List(0)); // dùng trong execute(bytes: any())
    registerFallbackValue(FileType.any); // dùng trong pickFiles(type: any())
    registerFallbackValue(FakeImportResult()); // dùng nếu cần
  });

  late MockImportExcelUseCase mockUseCase;
  late TestableExcelImportNotifier notifier;
  late MockFilePicker mockFilePicker;

  setUp(() {
    mockUseCase = MockImportExcelUseCase();
    notifier = TestableExcelImportNotifier(mockUseCase);
    mockFilePicker = MockFilePicker();
    FilePicker.platform = mockFilePicker;
  });

  tearDown(() {
    notifier.dispose();
  });

  // ── ExcelImportState computed properties ───────────────────────────────────
  group('ExcelImportState — computed properties', () {
    test('initial state đúng', () {
      expect(notifier.state.status, ImportStatus.idle);
      expect(notifier.state.previewRows, isEmpty);
      expect(notifier.state.hasPreview, false);
      expect(notifier.state.canConfirmImport, false);
      expect(notifier.state.validCount, 0);
      expect(notifier.state.errorCount, 0);
      expect(notifier.state.totalCount, 0);
      expect(notifier.state.fileName, null);
      expect(notifier.state.fileBytes, null);
      expect(notifier.state.importResult, null);
      expect(notifier.state.errorMessage, null);
    });

    test('validCount đếm đúng rows hợp lệ', () {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.readyToImport,
          previewRows: [_validRow(1, 'A'), _invalidRow(2), _validRow(3, 'C')],
        ),
      );
      expect(notifier.state.validCount, 2);
      expect(notifier.state.errorCount, 1);
      expect(notifier.state.totalCount, 3);
    });

    test('canConfirmImport = true khi readyToImport + validCount > 0', () {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.readyToImport,
          previewRows: [_validRow(1, 'A')],
          fileBytes: Uint8List.fromList([1, 2, 3]),
        ),
      );
      expect(notifier.state.canConfirmImport, true);
    });

    test('canConfirmImport = false khi status != readyToImport', () {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.idle,
          previewRows: [_validRow(1, 'A')],
          fileBytes: Uint8List.fromList([1, 2, 3]),
        ),
      );
      expect(notifier.state.canConfirmImport, false);
    });

    test('canConfirmImport = false khi validCount = 0', () {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.readyToImport,
          previewRows: [_invalidRow(1)],
          fileBytes: Uint8List.fromList([1, 2, 3]),
        ),
      );
      expect(notifier.state.canConfirmImport, false);
    });

    test('hasPreview = true khi có previewRows', () {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.readyToImport,
          previewRows: [_validRow(1, 'A')],
        ),
      );
      expect(notifier.state.hasPreview, true);
    });
  });

  // ── reset() ────────────────────────────────────────────────────────────────
  group('ExcelImportNotifier.reset', () {
    test('reset() → state về initial hoàn toàn', () {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.failed,
          errorMessage: 'lỗi test',
          previewRows: [_validRow(1, 'A')],
          fileName: 'test.xlsx',
          fileBytes: Uint8List.fromList([1, 2, 3]),
        ),
      );

      notifier.reset();

      expect(notifier.state.status, ImportStatus.idle);
      expect(notifier.state.errorMessage, null);
      expect(notifier.state.previewRows, isEmpty);
      expect(notifier.state.fileName, null);
      expect(notifier.state.fileBytes, null);
      expect(notifier.state.importResult, null);
    });

    test('reset() từ success state → về idle', () {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.success,
          importResult: const ImportResult(
            totalRows: 5,
            importedCount: 5,
            skippedCount: 0,
            errorCount: 0,
          ),
        ),
      );

      notifier.reset();
      expect(notifier.state.status, ImportStatus.idle);
      expect(notifier.state.importResult, null);
    });
  });

  // ── confirmImport() ────────────────────────────────────────────────────────
  group('ExcelImportNotifier.confirmImport', () {
    test(
      'canConfirmImport = false (idle) → không gọi useCase.execute()',
      () async {
        await notifier.confirmImport(1);
        verifyNever(
          () => mockUseCase.execute(
            eventListId: any(named: 'eventListId'),
            bytes: any(named: 'bytes'),
          ),
        );
      },
    );

    test(
      'canConfirmImport = false (validCount=0) → không gọi useCase.execute()',
      () async {
        notifier.setTestState(
          ExcelImportState(
            status: ImportStatus.readyToImport,
            previewRows: [_invalidRow(1)],
            fileBytes: Uint8List.fromList([1, 2, 3]),
          ),
        );

        await notifier.confirmImport(1);
        verifyNever(
          () => mockUseCase.execute(
            eventListId: any(named: 'eventListId'),
            bytes: any(named: 'bytes'),
          ),
        );
      },
    );

    test('fileBytes = null → không gọi useCase.execute()', () async {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.readyToImport,
          previewRows: [_validRow(1, 'A')],
          fileBytes: null,
        ),
      );

      await notifier.confirmImport(1);
      verifyNever(
        () => mockUseCase.execute(
          eventListId: any(named: 'eventListId'),
          bytes: any(named: 'bytes'),
        ),
      );
    });

    test('thành công → status = success, importResult được set', () async {
      final bytes = Uint8List.fromList([1, 2, 3, 4, 5]);
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.readyToImport,
          previewRows: [_validRow(1, 'A'), _validRow(2, 'B')],
          fileBytes: bytes,
          fileName: 'data.xlsx',
        ),
      );

      when(() => mockUseCase.execute(eventListId: 1, bytes: bytes)).thenAnswer(
        (_) async => const ImportResult(
          totalRows: 2,
          importedCount: 2,
          skippedCount: 0,
          errorCount: 0,
        ),
      );

      await notifier.confirmImport(1);

      expect(notifier.state.status, ImportStatus.success);
      expect(notifier.state.importResult?.importedCount, 2);
      expect(notifier.state.importResult?.totalRows, 2);
      expect(notifier.state.errorMessage, null);
    });

    test(
      'ImportException → status = failed, errorMessage = message của exception',
      () async {
        final bytes = Uint8List.fromList([1, 2, 3]);
        notifier.setTestState(
          ExcelImportState(
            status: ImportStatus.readyToImport,
            previewRows: [_validRow(1, 'A')],
            fileBytes: bytes,
            fileName: 'bad.xlsx',
          ),
        );

        when(
          () => mockUseCase.execute(eventListId: 1, bytes: bytes),
        ).thenThrow(const ImportException('File không hợp lệ'));

        await notifier.confirmImport(1);

        expect(notifier.state.status, ImportStatus.failed);
        expect(notifier.state.errorMessage, 'File không hợp lệ');
      },
    );

    test(
      'lỗi không xác định → status = failed, errorMessage chứa "Import thất bại"',
      () async {
        final bytes = Uint8List.fromList([1, 2, 3]);
        notifier.setTestState(
          ExcelImportState(
            status: ImportStatus.readyToImport,
            previewRows: [_validRow(1, 'A')],
            fileBytes: bytes,
            fileName: 'test.xlsx',
          ),
        );

        when(
          () => mockUseCase.execute(eventListId: 1, bytes: bytes),
        ).thenThrow(Exception('Lỗi bất ngờ'));

        await notifier.confirmImport(1);

        expect(notifier.state.status, ImportStatus.failed);
        expect(notifier.state.errorMessage, contains('Import thất bại'));
      },
    );
  });

  // ── pickAndPreviewFile() ───────────────────────────────────────────────────
  group('ExcelImportNotifier.pickAndPreviewFile', () {
    test('user cancel (result = null) → status = idle', () async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenAnswer((_) async => null);

      await notifier.pickAndPreviewFile();

      expect(notifier.state.status, ImportStatus.idle);
    });

    test('user cancel sau khi da co preview cu → xoa state tam truoc do', () async {
      notifier.setTestState(
        ExcelImportState(
          status: ImportStatus.readyToImport,
          previewRows: [_validRow(1, 'A')],
          fileName: 'old.xlsx',
          fileBytes: Uint8List.fromList([1, 2, 3]),
          importResult: const ImportResult(
            totalRows: 1,
            importedCount: 1,
            skippedCount: 0,
            errorCount: 0,
          ),
          errorMessage: 'loi cu',
        ),
      );

      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenAnswer((_) async => null);

      await notifier.pickAndPreviewFile();

      expect(notifier.state.status, ImportStatus.idle);
      expect(notifier.state.previewRows, isEmpty);
      expect(notifier.state.fileName, null);
      expect(notifier.state.fileBytes, null);
      expect(notifier.state.importResult, null);
      expect(notifier.state.errorMessage, null);
    });

    test(
      'file hợp lệ → status = readyToImport, previewRows + fileName được set',
      () async {
        final bytes = Uint8List.fromList([10, 20, 30, 40, 50]);
        final rows = [_validRow(1, 'Nguyễn Văn A'), _validRow(2, 'Trần Thị B')];

        when(
          () => mockFilePicker.pickFiles(
            type: any(named: 'type'),
            allowedExtensions: any(named: 'allowedExtensions'),
            withData: any(named: 'withData'),
          ),
        ).thenAnswer(
          (_) async => FilePickerResult([
            PlatformFile(name: 'data.xlsx', size: 5, bytes: bytes),
          ]),
        );

        when(() => mockUseCase.previewFile(bytes)).thenReturn(rows);

        await notifier.pickAndPreviewFile();

        expect(notifier.state.status, ImportStatus.readyToImport);
        expect(notifier.state.previewRows.length, 2);
        expect(notifier.state.fileName, 'data.xlsx');
        expect(notifier.state.fileBytes, bytes);
      },
    );

    test('bytes = null → status = failed, errorMessage được set', () async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenAnswer(
        (_) async => FilePickerResult([
          PlatformFile(name: 'empty.xlsx', size: 0, bytes: null),
        ]),
      );

      await notifier.pickAndPreviewFile();

      expect(notifier.state.status, ImportStatus.failed);
      expect(notifier.state.errorMessage, isNotNull);
    });

    test('ImportException trong previewFile → status = failed', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);

      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenAnswer(
        (_) async => FilePickerResult([
          PlatformFile(name: 'bad.xlsx', size: 3, bytes: bytes),
        ]),
      );

      when(
        () => mockUseCase.previewFile(bytes),
      ).thenThrow(const ImportException('Không tìm thấy cột họ tên'));

      await notifier.pickAndPreviewFile();

      expect(notifier.state.status, ImportStatus.failed);
      expect(notifier.state.errorMessage, 'Không tìm thấy cột họ tên');
    });

    test('lỗi không xác định trong pickFiles → status = failed', () async {
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenThrow(Exception('Lỗi hệ thống'));

      await notifier.pickAndPreviewFile();

      expect(notifier.state.status, ImportStatus.failed);
      expect(notifier.state.errorMessage, isNotNull);
    });

    test('sau khi pick thành công, error cũ bị xoá', () async {
      // Set state có lỗi cũ
      notifier.setTestState(
        ExcelImportState(status: ImportStatus.failed, errorMessage: 'lỗi cũ'),
      );

      final bytes = Uint8List.fromList([1, 2, 3]);
      when(
        () => mockFilePicker.pickFiles(
          type: any(named: 'type'),
          allowedExtensions: any(named: 'allowedExtensions'),
          withData: any(named: 'withData'),
        ),
      ).thenAnswer(
        (_) async => FilePickerResult([
          PlatformFile(name: 'new.xlsx', size: 3, bytes: bytes),
        ]),
      );

      when(
        () => mockUseCase.previewFile(bytes),
      ).thenReturn([_validRow(1, 'A')]);

      await notifier.pickAndPreviewFile();

      expect(notifier.state.status, ImportStatus.readyToImport);
      expect(notifier.state.errorMessage, null);
    });
  });
}
