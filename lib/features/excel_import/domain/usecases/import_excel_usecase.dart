import 'dart:typed_data';

import '../../../../core/errors/import_exception.dart';
import '../../../../core/services/excel_import_service.dart';
import '../../../../features/guest_records/domain/entities/guest_record_entity.dart';
import '../../../../features/guest_records/domain/repositories/guest_record_repository.dart';
import '../entities/import_preview_row.dart';

/// Kết quả sau khi thực hiện import Excel vào DB
class ImportResult {
  const ImportResult({
    required this.totalRows,
    required this.importedCount,
    required this.skippedCount,
    required this.errorCount,
  });

  /// Tổng số dòng đọc được từ file (không tính header)
  final int totalRows;

  /// Số dòng đã import thành công vào DB
  final int importedCount;

  /// Số dòng bị bỏ qua (trống hoặc không hợp lệ)
  final int skippedCount;

  /// Số dòng có lỗi validation
  final int errorCount;

  @override
  String toString() =>
      'ImportResult(total: $totalRows, imported: $importedCount, '
      'skipped: $skippedCount, errors: $errorCount)';
}

/// Use case thực hiện toàn bộ pipeline import Excel:
/// 1. Parse file bytes → danh sách ImportPreviewRow
/// 2. Validate rows → đánh dấu lỗi
/// 3. Batch insert các row hợp lệ vào DB
/// 4. Trả về [ImportResult] tóm tắt kết quả
class ImportExcelUseCase {
  const ImportExcelUseCase({
    required this.excelImportService,
    required this.guestRecordRepository,
  });

  final ExcelImportService excelImportService;
  final GuestRecordRepository guestRecordRepository;

  /// Thực hiện import file Excel vào event list có [eventListId].
  /// [bytes]: nội dung file .xlsx dưới dạng Uint8List
  /// Ném [ImportException] nếu file không hợp lệ.
  Future<ImportResult> execute({
    required int eventListId,
    required Uint8List bytes,
  }) async {
    // 1. Parse file
    final List<ImportPreviewRow> parsed = excelImportService.parseFile(bytes);

    if (parsed.isEmpty) {
      throw const ImportException('File Excel không có dữ liệu (ngoài header)');
    }

    // 2. Validate
    final List<ImportPreviewRow> validated = excelImportService.validateRows(
      parsed,
    );

    // 3. Convert valid rows → entities
    final List<GuestRecordEntity> entities = excelImportService
        .toGuestRecordEntities(validated, eventListId);

    // 4. Batch insert trong một lần ghi DB
    if (entities.isNotEmpty) {
      await guestRecordRepository.createMany(entities);
    }

    // 5. Tính toán kết quả
    final int errorCount = excelImportService.countErrors(validated);
    final int importedCount = entities.length;
    final int skippedCount = parsed.length - importedCount - errorCount;

    return ImportResult(
      totalRows: parsed.length,
      importedCount: importedCount,
      skippedCount: skippedCount < 0 ? 0 : skippedCount,
      errorCount: errorCount,
    );
  }

  /// Chỉ parse + validate, không insert vào DB.
  /// Dùng cho màn hình preview trước khi xác nhận import.
  List<ImportPreviewRow> previewFile(Uint8List bytes) {
    final List<ImportPreviewRow> parsed = excelImportService.parseFile(bytes);
    return excelImportService.validateRows(parsed);
  }
}
