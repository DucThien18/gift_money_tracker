import 'dart:convert';
import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';

import '../../../event_lists/domain/entities/event_list_entity.dart';
import '../../domain/entities/guest_record_entity.dart';
import '../../domain/entities/guest_record_export_result.dart';
import '../../domain/services/guest_record_export_service.dart';

typedef DirectoryResolver = Future<Directory?> Function();
typedef NowProvider = DateTime Function();

class GuestRecordCsvExportService implements GuestRecordExportService {
  GuestRecordCsvExportService({
    DirectoryResolver? externalDirectoryResolver,
    DirectoryResolver? applicationDirectoryResolver,
    NowProvider? nowProvider,
  }) : _externalDirectoryResolver =
           externalDirectoryResolver ?? getExternalStorageDirectory,
       _applicationDirectoryResolver =
           applicationDirectoryResolver ?? getApplicationDocumentsDirectory,
       _nowProvider = nowProvider ?? DateTime.now;

  final DirectoryResolver _externalDirectoryResolver;
  final DirectoryResolver _applicationDirectoryResolver;
  final NowProvider _nowProvider;

  @override
  Future<GuestRecordExportResult> exportCsv({
    required EventListEntity eventList,
    required List<GuestRecordEntity> records,
  }) async {
    final Directory directory = await _resolveDirectory();
    final DateTime exportedAt = _nowProvider();
    final String fileName = _buildFileName(eventList, exportedAt);
    final File file = File(
      '${directory.path}${Platform.pathSeparator}$fileName',
    );
    final String csv = buildCsvContent(eventList: eventList, records: records);
    await file.writeAsBytes(
      utf8.encode('\uFEFF$csv'),
      flush: true,
    );

    return GuestRecordExportResult(
      fileName: fileName,
      filePath: file.path,
      recordCount: records.length,
      exportedAt: exportedAt,
    );
  }

  String buildCsvContent({
    required EventListEntity eventList,
    required List<GuestRecordEntity> records,
  }) {
    final List<List<String>> rows = <List<String>>[
      <String>[
        'Mã sự kiện',
        'Tên sự kiện',
        'Ngày sự kiện',
        'STT',
        'Họ tên',
        'Ghi chú',
        'Số tiền',
        'Đã trả nợ',
        'Ngày tạo',
        'Cập nhật cuối',
      ],
    ];

    for (int index = 0; index < records.length; index += 1) {
      final GuestRecordEntity record = records[index];
      rows.add(<String>[
        eventList.code,
        eventList.name,
        _formatEventDate(eventList.eventDate),
        '${index + 1}',
        record.fullName,
        record.note,
        '${record.amount}',
        record.isDebtPaid ? 'Có' : 'Không',
        _formatDateTime(record.createdAt),
        _formatDateTime(record.updatedAt),
      ]);
    }

    return rows
        .map(
          (List<String> row) =>
              row.map(_escapeCsvField).join(','),
        )
        .join('\r\n');
  }

  Future<Directory> _resolveDirectory() async {
    final Directory? externalDirectory = await _externalDirectoryResolver();
    if (externalDirectory != null) {
      await externalDirectory.create(recursive: true);
      return externalDirectory;
    }

    final Directory? applicationDirectory = await _applicationDirectoryResolver();
    if (applicationDirectory == null) {
      throw StateError('Không tìm được thư mục để lưu file export.');
    }

    await applicationDirectory.create(recursive: true);
    return applicationDirectory;
  }

  String _buildFileName(EventListEntity eventList, DateTime exportedAt) {
    final String baseName = _sanitizeFileName(eventList.name);
    final String timestamp = DateFormat('yyyyMMdd_HHmmss').format(exportedAt);
    return 'nhat_ky_tien_mung_${baseName}_$timestamp.csv';
  }

  String _sanitizeFileName(String raw) {
    final String sanitized = raw
        .trim()
        .replaceAll(RegExp(r'\s+'), '_')
        .replaceAll(RegExp(r'[^A-Za-z0-9_\-]'), '');
    if (sanitized.isEmpty) {
      return 'su_kien';
    }
    return sanitized;
  }

  String _formatEventDate(DateTime? value) {
    if (value == null) {
      return '';
    }
    return DateFormat('dd/MM/yyyy').format(value);
  }

  String _formatDateTime(DateTime value) {
    return DateFormat('dd/MM/yyyy HH:mm').format(value);
  }

  String _escapeCsvField(String value) {
    if (value.contains('"') ||
        value.contains(',') ||
        value.contains('\n') ||
        value.contains('\r')) {
      final String escaped = value.replaceAll('"', '""');
      return '"$escaped"';
    }
    return value;
  }
}
