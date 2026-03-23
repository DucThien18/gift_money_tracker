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

class ExcelMapper {
  ExcelMapper._();

  static ExcelMappedRow fromDynamicRow(Map<String, dynamic> row) {
    return ExcelMappedRow(
      fullName: (row['fullName'] ?? '').toString().trim(),
      note: (row['note'] ?? '').toString().trim(),
      amount: int.tryParse((row['amount'] ?? '0').toString()) ?? 0,
      isDebtPaid: row['isDebtPaid'] == true,
    );
  }
}
