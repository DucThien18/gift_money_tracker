import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/enums/import_status.dart';
import '../../../../core/errors/import_exception.dart';
import '../../../../core/services/excel_import_service.dart';
import '../../../../features/guest_records/presentation/providers/guest_record_providers.dart';
import '../../domain/entities/import_preview_row.dart';
import '../../domain/usecases/import_excel_usecase.dart';

// ── Provider cho ExcelImportService ────────────────────────────────────────────
final excelImportServiceProvider = Provider<ExcelImportService>(
  (_) => const ExcelImportService(),
);

// ── Provider cho ImportExcelUseCase ────────────────────────────────────────────
final importExcelUseCaseProvider = Provider<ImportExcelUseCase>((ref) {
  return ImportExcelUseCase(
    excelImportService: ref.watch(excelImportServiceProvider),
    guestRecordRepository: ref.watch(guestRecordRepositoryProvider),
  );
});

// ── State ───────────────────────────────────────────────────────────────────────

/// State quản lý toàn bộ luồng import Excel
class ExcelImportState {
  const ExcelImportState({
    this.status = ImportStatus.idle,
    this.previewRows = const <ImportPreviewRow>[],
    this.fileName,
    this.fileBytes,
    this.importResult,
    this.errorMessage,
  });

  final ImportStatus status;

  /// Danh sách rows đã parse + validate (dùng cho màn hình preview)
  final List<ImportPreviewRow> previewRows;

  /// Tên file đã chọn
  final String? fileName;

  /// Bytes của file đã chọn (giữ lại để dùng khi confirm import)
  final Uint8List? fileBytes;

  /// Kết quả sau khi import thành công
  final ImportResult? importResult;

  /// Thông báo lỗi nếu có
  final String? errorMessage;

  // ── Computed ──────────────────────────────────────────────────────────────

  int get validCount => previewRows.where((r) => r.isValid).length;
  int get errorCount => previewRows.where((r) => r.hasErrors).length;
  int get totalCount => previewRows.length;
  bool get hasPreview => previewRows.isNotEmpty;
  bool get canConfirmImport =>
      status == ImportStatus.readyToImport && validCount > 0;

  ExcelImportState copyWith({
    ImportStatus? status,
    List<ImportPreviewRow>? previewRows,
    String? fileName,
    Uint8List? fileBytes,
    ImportResult? importResult,
    String? errorMessage,
    bool clearError = false,
    bool clearResult = false,
    bool clearFile = false,
  }) {
    return ExcelImportState(
      status: status ?? this.status,
      previewRows: previewRows ?? this.previewRows,
      fileName: clearFile ? null : (fileName ?? this.fileName),
      fileBytes: clearFile ? null : (fileBytes ?? this.fileBytes),
      importResult: clearResult ? null : (importResult ?? this.importResult),
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

// ── Notifier ────────────────────────────────────────────────────────────────────

class ExcelImportNotifier extends StateNotifier<ExcelImportState> {
  ExcelImportNotifier(this._useCase) : super(const ExcelImportState());

  final ImportExcelUseCase _useCase;

  /// Bước 1: Mở file picker, đọc file, parse + validate, hiển thị preview
  Future<void> pickAndPreviewFile() async {
    state = state.copyWith(
      status: ImportStatus.parsing,
      previewRows: const <ImportPreviewRow>[],
      clearError: true,
      clearResult: true,
      clearFile: true,
    );

    try {
      // Mở file picker
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: <String>['xlsx', 'xls'],
        withData: true,
      );

      if (result == null || result.files.isEmpty) {
        // User huỷ chọn file
        state = const ExcelImportState();
        return;
      }

      final PlatformFile file = result.files.first;
      final Uint8List? bytes = file.bytes;

      if (bytes == null || bytes.isEmpty) {
        state = state.copyWith(
          status: ImportStatus.failed,
          errorMessage: 'Không thể đọc nội dung file. Vui lòng thử lại.',
        );
        return;
      }

      // Parse + validate (preview, không insert DB)
      state = state.copyWith(status: ImportStatus.validating);
      final List<ImportPreviewRow> rows = _useCase.previewFile(bytes);

      state = state.copyWith(
        status: ImportStatus.readyToImport,
        previewRows: rows,
        fileName: file.name,
        fileBytes: bytes,
      );
    } on ImportException catch (e) {
      state = state.copyWith(
        status: ImportStatus.failed,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.failed,
        errorMessage: 'Lỗi không xác định: ${e.toString()}',
      );
    }
  }

  /// Bước 2: Xác nhận import — batch insert các row hợp lệ vào DB
  Future<void> confirmImport(int eventListId) async {
    if (!state.canConfirmImport) return;
    final Uint8List? bytes = state.fileBytes;
    if (bytes == null) return;

    state = state.copyWith(status: ImportStatus.importing, clearError: true);

    try {
      final ImportResult result = await _useCase.execute(
        eventListId: eventListId,
        bytes: bytes,
      );

      state = state.copyWith(
        status: ImportStatus.success,
        importResult: result,
      );
    } on ImportException catch (e) {
      state = state.copyWith(
        status: ImportStatus.failed,
        errorMessage: e.message,
      );
    } catch (e) {
      state = state.copyWith(
        status: ImportStatus.failed,
        errorMessage: 'Import thất bại: ${e.toString()}',
      );
    }
  }

  /// Reset về trạng thái ban đầu
  void reset() {
    state = const ExcelImportState();
  }
}

// ── Provider ────────────────────────────────────────────────────────────────────

final excelImportProvider =
    StateNotifierProvider.autoDispose<ExcelImportNotifier, ExcelImportState>((
      ref,
    ) {
      return ExcelImportNotifier(ref.watch(importExcelUseCaseProvider));
    });
