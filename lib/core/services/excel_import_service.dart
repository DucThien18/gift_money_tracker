import 'dart:typed_data';

import 'package:excel/excel.dart';

import '../errors/import_exception.dart';
import '../utils/excel_mapper.dart';
import '../../features/excel_import/domain/entities/import_preview_row.dart';
import '../../features/guest_records/domain/entities/guest_record_entity.dart';

/// Service xử lý toàn bộ pipeline import Excel:
/// 1. parseFile: đọc bytes → detect columns → parse từng row
/// 2. validateRows: validate dữ liệu đã parse → đánh dấu lỗi
/// 3. toGuestRecordEntities: chuyển row hợp lệ → GuestRecordEntity
class ExcelImportService {
  const ExcelImportService();

  // ── 1. Parse File ───────────────────────────────────────────────────────────

  /// Đọc file Excel từ bytes, detect columns từ header row, parse từng dòng dữ liệu.
  /// Ném [ImportException] nếu file không hợp lệ hoặc không tìm thấy cột bắt buộc.
  List<ImportPreviewRow> parseFile(Uint8List bytes) {
    late final Excel excel;
    try {
      excel = Excel.decodeBytes(bytes);
    } catch (_) {
      throw const ImportException(
        'Không thể đọc file Excel. File có thể bị hỏng hoặc không đúng định dạng .xlsx',
      );
    }

    // Lấy sheet đầu tiên
    final String? sheetName = excel.tables.keys.isNotEmpty
        ? excel.tables.keys.first
        : null;
    if (sheetName == null) {
      throw const ImportException('File Excel không có sheet nào');
    }

    final Sheet? sheet = excel.tables[sheetName];
    if (sheet == null || sheet.rows.isEmpty) {
      throw const ImportException('Sheet Excel trống, không có dữ liệu');
    }

    final List<List<Data?>> rows = sheet.rows;

    // Dòng đầu tiên là header
    final List<String> headers = rows.first
        .map((cell) => cell?.value?.toString() ?? '')
        .toList();

    final ExcelColumnMap columnMap = ExcelMapper.detectColumns(headers);

    if (!columnMap.hasFullName) {
      throw ImportException(
        'Không tìm thấy cột Họ tên trong file. '
        'Tên cột hợp lệ: ${_joinAliases(["Họ tên", "Tên", "Full Name"])}',
      );
    }

    // Parse từng dòng dữ liệu (bỏ qua dòng header)
    final List<ImportPreviewRow> result = <ImportPreviewRow>[];
    for (int i = 1; i < rows.length; i++) {
      final List<dynamic> cells = rows[i].map((cell) => cell?.value).toList();

      // Bỏ qua dòng hoàn toàn trống
      if (_isEmptyRow(cells)) continue;

      final ImportPreviewRow row = ExcelMapper.parseRow(i, cells, columnMap);
      result.add(row);
    }

    return result;
  }

  // ── 2. Validate Rows ────────────────────────────────────────────────────────

  /// Validate danh sách rows đã parse, trả về list mới với errors được điền vào.
  /// Các rule validation:
  /// - fullName không được rỗng
  /// - amount phải >= 0 (nếu có cột amount)
  /// - amount không được null nếu cột amount tồn tại và có giá trị raw
  List<ImportPreviewRow> validateRows(List<ImportPreviewRow> rows) {
    return rows.map(_validateRow).toList();
  }

  ImportPreviewRow _validateRow(ImportPreviewRow row) {
    final List<String> errors = <String>[];

    // Validate fullName
    if (row.parsedFullName == null || row.parsedFullName!.trim().isEmpty) {
      errors.add('Dòng ${row.rowNumber}: Họ tên không được để trống');
    }

    // Validate amount: nếu có raw nhưng không parse được
    if (row.amountRaw != null &&
        row.amountRaw!.isNotEmpty &&
        row.parsedAmount == null) {
      errors.add(
        'Dòng ${row.rowNumber}: Số tiền "${row.amountRaw}" không hợp lệ',
      );
    }

    // Validate amount: không được âm
    if (row.parsedAmount != null && row.parsedAmount! < 0) {
      errors.add('Dòng ${row.rowNumber}: Số tiền không được âm');
    }

    if (errors.isEmpty) return row;
    return row.copyWith(errors: errors);
  }

  // ── 3. Convert to Entities ──────────────────────────────────────────────────

  /// Chuyển danh sách rows hợp lệ thành [GuestRecordEntity] sẵn sàng insert vào DB.
  /// Chỉ lấy các row có `isValid == true`.
  /// [eventListId]: ID của EventList sẽ import vào.
  List<GuestRecordEntity> toGuestRecordEntities(
    List<ImportPreviewRow> rows,
    int eventListId,
  ) {
    final DateTime now = DateTime.now();
    return rows.where((row) => row.isValid).map((row) {
      final String fullName = row.parsedFullName!.trim();
      final String note = row.parsedNote ?? '';
      return GuestRecordEntity(
        id: 0, // Isar sẽ tự assign ID khi insert
        eventListId: eventListId,
        fullName: fullName,
        note: note,
        amount: row.parsedAmount ?? 0,
        isDebtPaid: row.parsedIsDebtPaid ?? false,
        createdAt: now,
        updatedAt: now,
      );
    }).toList();
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  /// Kiểm tra dòng có hoàn toàn trống không
  bool _isEmptyRow(List<dynamic> cells) {
    return cells.every((cell) {
      if (cell == null) return true;
      final String s = cell.toString().trim();
      return s.isEmpty;
    });
  }

  String _joinAliases(List<String> aliases) => aliases.join(', ');

  // ── Summary Helpers ─────────────────────────────────────────────────────────

  /// Đếm số row hợp lệ
  int countValid(List<ImportPreviewRow> rows) =>
      rows.where((r) => r.isValid).length;

  /// Đếm số row có lỗi
  int countErrors(List<ImportPreviewRow> rows) =>
      rows.where((r) => r.hasErrors).length;

  // ── Legacy compat ───────────────────────────────────────────────────────────

  /// Backward-compatible method
  List<ExcelMappedRow> mapRows(List<Map<String, dynamic>> rows) {
    return rows.map(ExcelMapper.fromDynamicRow).toList();
  }
}
