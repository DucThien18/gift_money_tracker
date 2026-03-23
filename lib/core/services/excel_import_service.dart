import '../utils/excel_mapper.dart';

class ExcelImportService {
  const ExcelImportService();

  List<ExcelMappedRow> mapRows(List<Map<String, dynamic>> rows) {
    return rows.map(ExcelMapper.fromDynamicRow).toList();
  }
}
