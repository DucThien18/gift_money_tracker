import '../constants/excel_constants.dart';
import '../../features/excel_import/domain/entities/import_preview_row.dart';

/// Kết quả map header → column index sau khi detect từ dòng tiêu đề Excel
class ExcelColumnMap {
  const ExcelColumnMap({
    this.fullNameIndex,
    this.noteIndex,
    this.amountIndex,
    this.isDebtPaidIndex,
  });

  final int? fullNameIndex;
  final int? noteIndex;
  final int? amountIndex;
  final int? isDebtPaidIndex;

  /// Có tìm thấy cột họ tên không (bắt buộc)
  bool get hasFullName => fullNameIndex != null;

  /// Có tìm thấy cột số tiền không
  bool get hasAmount => amountIndex != null;
}

/// Model đơn giản dùng cho backward-compat với ExcelImportService cũ
class ExcelMappedRow {
  const ExcelMappedRow({
    required this.fullName,
    required this.note,
    required this.amount,
    required this.isDebtPaid,
  });

  final String fullName;
  final String note;
  final int amount;
  final bool isDebtPaid;
}

/// Utility class xử lý toàn bộ logic mapping dữ liệu từ Excel
class ExcelMapper {
  ExcelMapper._();

  // ── Column Detection ────────────────────────────────────────────────────────

  /// Detect column index từ danh sách header (dòng đầu tiên của sheet).
  /// So sánh không phân biệt hoa/thường và trim khoảng trắng.
  static ExcelColumnMap detectColumns(List<String> headers) {
    int? fullNameIndex;
    int? noteIndex;
    int? amountIndex;
    int? isDebtPaidIndex;

    for (int i = 0; i < headers.length; i++) {
      final String header = headers[i].trim().toLowerCase();

      if (fullNameIndex == null &&
          ExcelConstants.fullNameAliases.any(
            (alias) => alias.toLowerCase() == header,
          )) {
        fullNameIndex = i;
      } else if (noteIndex == null &&
          ExcelConstants.noteAliases.any(
            (alias) => alias.toLowerCase() == header,
          )) {
        noteIndex = i;
      } else if (amountIndex == null &&
          ExcelConstants.amountAliases.any(
            (alias) => alias.toLowerCase() == header,
          )) {
        amountIndex = i;
      } else if (isDebtPaidIndex == null &&
          ExcelConstants.debtPaidAliases.any(
            (alias) => alias.toLowerCase() == header,
          )) {
        isDebtPaidIndex = i;
      }
    }

    return ExcelColumnMap(
      fullNameIndex: fullNameIndex,
      noteIndex: noteIndex,
      amountIndex: amountIndex,
      isDebtPaidIndex: isDebtPaidIndex,
    );
  }

  // ── Amount Parser ───────────────────────────────────────────────────────────

  /// Parse chuỗi số tiền thành int (VND).
  /// Hỗ trợ:
  /// - Số nguyên thông thường: "500000", "1000000"
  /// - Dấu phẩy/chấm phân cách hàng nghìn: "500,000" / "500.000"
  /// - Hậu tố "k" (nghìn): "500k" → 500000
  /// - Hậu tố "tr" / "triệu": "1tr" / "1triệu" → 1000000
  /// - Hậu tố "m" (million): "1m" → 1000000
  /// Trả về null nếu không parse được.
  static int? parseAmount(String? raw) {
    if (raw == null) return null;
    final String cleaned = raw.trim().toLowerCase();
    if (cleaned.isEmpty) return null;

    // Xử lý hậu tố "triệu" hoặc "tr"
    if (cleaned.endsWith('triệu') || cleaned.endsWith('trieu')) {
      final String numPart = cleaned
          .replaceAll('triệu', '')
          .replaceAll('trieu', '')
          .trim();
      final double? val = _parseDouble(numPart);
      if (val != null) return (val * 1000000).round();
      return null;
    }

    if (cleaned.endsWith('tr')) {
      final String numPart = cleaned.replaceAll('tr', '').trim();
      final double? val = _parseDouble(numPart);
      if (val != null) return (val * 1000000).round();
      return null;
    }

    // Xử lý hậu tố "m" (million) — chỉ khi không phải số thập phân thông thường
    if (cleaned.endsWith('m') && !cleaned.contains('.')) {
      final String numPart = cleaned.replaceAll('m', '').trim();
      final double? val = _parseDouble(numPart);
      if (val != null) return (val * 1000000).round();
      return null;
    }

    // Xử lý hậu tố "k" (nghìn)
    if (cleaned.endsWith('k')) {
      final String numPart = cleaned.replaceAll('k', '').trim();
      final double? val = _parseDouble(numPart);
      if (val != null) return (val * 1000).round();
      return null;
    }

    // Số thông thường (có thể có dấu phẩy/chấm phân cách hàng nghìn)
    final double? val = _parseDouble(cleaned);
    if (val != null) return val.round();
    return null;
  }

  /// Parse chuỗi thành double, xử lý dấu phẩy/chấm phân cách hàng nghìn.
  static double? _parseDouble(String s) {
    if (s.isEmpty) return null;
    // Loại bỏ dấu phẩy và dấu chấm phân cách hàng nghìn
    // Nếu có cả dấu phẩy lẫn dấu chấm → dấu cuối là thập phân
    String normalized = s;
    final int commaCount = s.split(',').length - 1;
    final int dotCount = s.split('.').length - 1;

    if (commaCount > 0 && dotCount > 0) {
      // Ví dụ: "1,000.50" hoặc "1.000,50"
      // Xác định dấu thập phân là dấu xuất hiện cuối cùng
      final int lastComma = s.lastIndexOf(',');
      final int lastDot = s.lastIndexOf('.');
      if (lastComma > lastDot) {
        // "1.000,50" → dấu phẩy là thập phân
        normalized = s.replaceAll('.', '').replaceAll(',', '.');
      } else {
        // "1,000.50" → dấu chấm là thập phân
        normalized = s.replaceAll(',', '');
      }
    } else if (commaCount > 1) {
      // "1,000,000" → dấu phẩy là phân cách hàng nghìn
      normalized = s.replaceAll(',', '');
    } else if (dotCount > 1) {
      // "1.000.000" → dấu chấm là phân cách hàng nghìn
      normalized = s.replaceAll('.', '');
    } else if (commaCount == 1) {
      // "500,000" → có thể là phân cách hàng nghìn hoặc thập phân
      // Nếu phần sau dấu phẩy có đúng 3 chữ số → phân cách hàng nghìn
      final List<String> parts = s.split(',');
      if (parts[1].length == 3 && int.tryParse(parts[1]) != null) {
        normalized = s.replaceAll(',', '');
      } else {
        normalized = s.replaceAll(',', '.');
      }
    } else if (dotCount == 1) {
      // "500.000" → có thể là phân cách hàng nghìn hoặc thập phân
      final List<String> parts = s.split('.');
      if (parts[1].length == 3 && int.tryParse(parts[1]) != null) {
        normalized = s.replaceAll('.', '');
      }
      // else giữ nguyên (thập phân thông thường)
    }

    return double.tryParse(normalized);
  }

  // ── DebtPaid Parser ─────────────────────────────────────────────────────────

  /// Parse chuỗi trạng thái trả nợ thành bool.
  /// Trả về true nếu: "x", "có", "co", "yes", "true", "1", "đã trả", "da tra"
  /// Trả về false nếu: "", "không", "khong", "no", "false", "0", "chưa"
  /// Trả về null nếu không nhận ra.
  static bool? parseDebtPaid(String? raw) {
    if (raw == null) return null;
    final String cleaned = raw.trim().toLowerCase();
    if (cleaned.isEmpty) return false;

    const List<String> trueValues = <String>[
      'x',
      'có',
      'co',
      'yes',
      'true',
      '1',
      'đã trả',
      'da tra',
      'đã',
      'da',
      'rồi',
      'roi',
      'paid',
      'done',
      'v',
    ];
    const List<String> falseValues = <String>[
      'không',
      'khong',
      'no',
      'false',
      '0',
      'chưa',
      'chua',
      'chưa trả',
      'chua tra',
      'unpaid',
      '-',
      '',
    ];

    if (trueValues.contains(cleaned)) return true;
    if (falseValues.contains(cleaned)) return false;
    return null;
  }

  // ── Row Parser ──────────────────────────────────────────────────────────────

  /// Parse một dòng dữ liệu từ Excel thành `ImportPreviewRow`.
  /// [rowNumber]: số thứ tự dòng (bắt đầu từ 1, không tính header)
  /// [cells]: danh sách giá trị cell trong dòng đó
  /// [columnMap]: kết quả detect column từ header
  static ImportPreviewRow parseRow(
    int rowNumber,
    List<dynamic> cells,
    ExcelColumnMap columnMap,
  ) {
    // Lấy giá trị raw từ cell theo index
    final String? fullNameRaw = _getCellString(cells, columnMap.fullNameIndex);
    final String? noteRaw = _getCellString(cells, columnMap.noteIndex);
    final String? amountRaw = _getCellString(cells, columnMap.amountIndex);
    final String? isDebtPaidRaw = _getCellString(
      cells,
      columnMap.isDebtPaidIndex,
    );

    // Parse từng field
    final String? parsedFullName = fullNameRaw != null && fullNameRaw.isNotEmpty
        ? fullNameRaw
        : null;
    final String parsedNote = noteRaw?.trim() ?? '';
    final int? parsedAmount = parseAmount(amountRaw);
    final bool parsedIsDebtPaid = parseDebtPaid(isDebtPaidRaw) ?? false;

    return ImportPreviewRow(
      rowNumber: rowNumber,
      fullNameRaw: fullNameRaw,
      noteRaw: noteRaw,
      amountRaw: amountRaw,
      isDebtPaidRaw: isDebtPaidRaw,
      parsedFullName: parsedFullName,
      parsedNote: parsedNote,
      parsedAmount: parsedAmount,
      parsedIsDebtPaid: parsedIsDebtPaid,
      errors: const <String>[],
    );
  }

  /// Lấy giá trị string từ cell theo index, trả về null nếu index null hoặc out of range
  static String? _getCellString(List<dynamic> cells, int? index) {
    if (index == null || index >= cells.length) return null;
    final dynamic cell = cells[index];
    if (cell == null) return null;
    return cell.toString().trim();
  }

  // ── Legacy compat ───────────────────────────────────────────────────────────

  /// Backward-compatible method cho ExcelImportService cũ
  static ExcelMappedRow fromDynamicRow(Map<String, dynamic> row) {
    return ExcelMappedRow(
      fullName: (row['fullName'] ?? '').toString().trim(),
      note: (row['note'] ?? '').toString().trim(),
      amount: parseAmount((row['amount'] ?? '0').toString()) ?? 0,
      isDebtPaid: parseDebtPaid((row['isDebtPaid'] ?? '').toString()) ?? false,
    );
  }
}
