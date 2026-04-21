import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:gift_money_tracker/core/enums/import_status.dart';
import 'package:gift_money_tracker/features/excel_import/domain/entities/import_preview_row.dart';
import 'package:gift_money_tracker/features/excel_import/domain/usecases/import_excel_usecase.dart';
import 'package:gift_money_tracker/features/excel_import/presentation/pages/excel_import_page.dart';
import 'package:gift_money_tracker/features/excel_import/presentation/providers/excel_import_provider.dart';

class MockImportExcelUseCase extends Mock implements ImportExcelUseCase {}

class TestExcelImportNotifier extends ExcelImportNotifier {
  TestExcelImportNotifier({
    required ImportExcelUseCase useCase,
    required ExcelImportState initialState,
  }) : super(useCase) {
    state = initialState;
  }

  void setTestState(ExcelImportState newState) {
    state = newState;
  }
}

ImportPreviewRow _validRow(
  int rowNumber,
  String fullName, {
  String note = '',
  int amount = 500000,
  bool isDebtPaid = false,
}) {
  return ImportPreviewRow(
    rowNumber: rowNumber,
    fullNameRaw: fullName,
    noteRaw: note,
    amountRaw: '$amount',
    isDebtPaidRaw: isDebtPaid ? 'x' : '',
    parsedFullName: fullName,
    parsedNote: note,
    parsedAmount: amount,
    parsedIsDebtPaid: isDebtPaid,
    errors: const <String>[],
  );
}

Future<void> _pumpPage(
  WidgetTester tester,
  TestExcelImportNotifier notifier,
) async {
  tester.view.physicalSize = const Size(1440, 2560);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        excelImportProvider.overrideWith((ref) => notifier),
      ],
      child: const MaterialApp(home: ExcelImportPage(eventListId: 42)),
    ),
  );
  await tester.pump();
}

Finder _buttonByLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (Widget widget) => widget is ButtonStyleButton,
    ),
  );
}

void main() {
  late MockImportExcelUseCase mockUseCase;

  setUp(() {
    mockUseCase = MockImportExcelUseCase();
  });

  testWidgets('ExcelImportPage idle hien thi placeholder va khoa confirm', (
    WidgetTester tester,
  ) async {
    final TestExcelImportNotifier notifier = TestExcelImportNotifier(
      useCase: mockUseCase,
      initialState: const ExcelImportState(),
    );

    await _pumpPage(tester, notifier);

    expect(find.text('Import Excel'), findsOneWidget);
    expect(
      find.text('Kiểm tra preview va import vào sự kiện #42.'),
      findsOneWidget,
    );
    expect(find.text('Chưa có dữ liệu preview'), findsOneWidget);
    expect(find.text('Chọn file Excel'), findsOneWidget);

    final ButtonStyleButton confirmButton = tester.widget<ButtonStyleButton>(
      _buttonByLabel('Xác nhận thêm'),
    );
    expect(confirmButton.onPressed, isNull);
  });

  testWidgets('ExcelImportPage reset xoa preview cu va tro ve idle state', (
    WidgetTester tester,
  ) async {
    final Uint8List bytes = Uint8List.fromList(<int>[1, 2, 3]);
    final TestExcelImportNotifier notifier = TestExcelImportNotifier(
      useCase: mockUseCase,
      initialState: ExcelImportState(
        status: ImportStatus.readyToImport,
        previewRows: <ImportPreviewRow>[
          _validRow(1, 'Nguyen Van A', note: 'Ban than', amount: 700000),
        ],
        fileName: 'khach-moi.xlsx',
        fileBytes: bytes,
      ),
    );

    await _pumpPage(tester, notifier);

    expect(find.text('File: khach-moi.xlsx'), findsOneWidget);
    expect(find.text('1. Nguyen Van A'), findsOneWidget);
    expect(_buttonByLabel('Làm mới'), findsOneWidget);

    await tester.tap(_buttonByLabel('Làm mới'));
    await tester.pumpAndSettle();

    expect(find.text('Chưa có dữ liệu preview'), findsOneWidget);
    expect(find.text('File: khach-moi.xlsx'), findsNothing);
    expect(find.text('1. Nguyen Van A'), findsNothing);

    final ButtonStyleButton confirmButton = tester.widget<ButtonStyleButton>(
      _buttonByLabel('Xác nhận thêm'),
    );
    expect(confirmButton.onPressed, isNull);
  });

  testWidgets('ExcelImportPage confirm import chuyen sang success state', (
    WidgetTester tester,
  ) async {
    final Uint8List bytes = Uint8List.fromList(<int>[9, 8, 7, 6]);
    final TestExcelImportNotifier notifier = TestExcelImportNotifier(
      useCase: mockUseCase,
      initialState: ExcelImportState(
        status: ImportStatus.readyToImport,
        previewRows: <ImportPreviewRow>[
          _validRow(1, 'Nguyen Van A', amount: 500000),
          _validRow(2, 'Tran Thi B', amount: 300000, isDebtPaid: true),
        ],
        fileName: 'import.xlsx',
        fileBytes: bytes,
      ),
    );

    when(
      () => mockUseCase.execute(eventListId: 42, bytes: bytes),
    ).thenAnswer(
      (_) async => const ImportResult(
        totalRows: 2,
        importedCount: 2,
        skippedCount: 0,
        errorCount: 0,
      ),
    );

    await _pumpPage(tester, notifier);

    await tester.tap(_buttonByLabel('Xác nhận thêm'));
    await tester.pump();
    await tester.pumpAndSettle();

    expect(find.text('Import thành công'), findsOneWidget);
    expect(
      find.text('Đã thêm thành công 2/2 dòng hợp lệ vào sự kiện.'),
      findsOneWidget,
    );
    expect(find.text('Quay lại'), findsOneWidget);

    verify(() => mockUseCase.execute(eventListId: 42, bytes: bytes)).called(1);
  });
}
