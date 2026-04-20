import 'package:equatable/equatable.dart';

/// Model staging cho mỗi dòng dữ liệu đọc từ file Excel trước khi import vào DB.
/// Lưu cả dữ liệu thô (raw) lẫn dữ liệu đã parse, cùng danh sách lỗi nếu có.
class ImportPreviewRow extends Equatable {
  const ImportPreviewRow({
    required this.rowNumber,
    this.fullNameRaw,
    this.noteRaw,
    this.amountRaw,
    this.isDebtPaidRaw,
    this.parsedFullName,
    this.parsedNote,
    this.parsedAmount,
    this.parsedIsDebtPaid,
    this.errors = const <String>[],
  });

  /// Số thứ tự dòng trong file Excel (bắt đầu từ 1, không tính header)
  final int rowNumber;

  // ── Dữ liệu thô từ file Excel ──────────────────────────────────────────────
  final String? fullNameRaw;
  final String? noteRaw;
  final String? amountRaw;
  final String? isDebtPaidRaw;

  // ── Dữ liệu đã parse ───────────────────────────────────────────────────────
  final String? parsedFullName;
  final String? parsedNote;
  final int? parsedAmount;
  final bool? parsedIsDebtPaid;

  /// Danh sách lỗi validation của dòng này (rỗng = hợp lệ)
  final List<String> errors;

  /// Dòng này có hợp lệ để import không
  bool get isValid =>
      errors.isEmpty && parsedFullName != null && parsedFullName!.isNotEmpty;

  /// Dòng này có lỗi không
  bool get hasErrors => errors.isNotEmpty;

  ImportPreviewRow copyWith({
    int? rowNumber,
    String? fullNameRaw,
    String? noteRaw,
    String? amountRaw,
    String? isDebtPaidRaw,
    String? parsedFullName,
    String? parsedNote,
    int? parsedAmount,
    bool? parsedIsDebtPaid,
    List<String>? errors,
  }) {
    return ImportPreviewRow(
      rowNumber: rowNumber ?? this.rowNumber,
      fullNameRaw: fullNameRaw ?? this.fullNameRaw,
      noteRaw: noteRaw ?? this.noteRaw,
      amountRaw: amountRaw ?? this.amountRaw,
      isDebtPaidRaw: isDebtPaidRaw ?? this.isDebtPaidRaw,
      parsedFullName: parsedFullName ?? this.parsedFullName,
      parsedNote: parsedNote ?? this.parsedNote,
      parsedAmount: parsedAmount ?? this.parsedAmount,
      parsedIsDebtPaid: parsedIsDebtPaid ?? this.parsedIsDebtPaid,
      errors: errors ?? this.errors,
    );
  }

  @override
  List<Object?> get props => [
    rowNumber,
    fullNameRaw,
    noteRaw,
    amountRaw,
    isDebtPaidRaw,
    parsedFullName,
    parsedNote,
    parsedAmount,
    parsedIsDebtPaid,
    errors,
  ];
}
