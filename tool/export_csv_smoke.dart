import 'dart:convert';
import 'dart:io';

import 'package:gift_money_tracker/features/event_lists/domain/entities/event_list_entity.dart';
import 'package:gift_money_tracker/features/guest_records/data/services/guest_record_csv_export_service.dart';
import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';

Future<void> main() async {
  final Directory tempDirectory = await Directory.systemTemp.createTemp(
    'gift_money_export_smoke_',
  );

  try {
    final GuestRecordCsvExportService service = GuestRecordCsvExportService(
      externalDirectoryResolver: () async => tempDirectory,
      applicationDirectoryResolver: () async => tempDirectory,
      nowProvider: () => DateTime(2026, 4, 21, 14, 0, 0),
    );

    final EventListEntity eventList = EventListEntity(
      id: 1,
      code: 'EV-SMOKE',
      name: 'Dam cuoi Lan Anh',
      eventDate: DateTime(2026, 4, 20),
      createdAt: DateTime(2026, 4, 1),
      updatedAt: DateTime(2026, 4, 2),
    );
    final List<GuestRecordEntity> records = <GuestRecordEntity>[
      GuestRecordEntity(
        id: 1,
        eventListId: 1,
        fullName: 'Tran Anh',
        note: 'Dong nghiep',
        amount: 650000,
        isDebtPaid: true,
        createdAt: DateTime(2026, 4, 20, 9),
        updatedAt: DateTime(2026, 4, 20, 9, 10),
      ),
      GuestRecordEntity(
        id: 2,
        eventListId: 1,
        fullName: 'Nguyen "Minh"',
        note: 'Ban than, cap 3',
        amount: 500000,
        isDebtPaid: false,
        createdAt: DateTime(2026, 4, 20, 10),
        updatedAt: DateTime(2026, 4, 20, 10, 15),
      ),
    ];

    final String csv = service.buildCsvContent(
      eventList: eventList,
      records: records,
    );
    if (!csv.contains('Mã sự kiện,Tên sự kiện')) {
      throw StateError('CSV header khong dung.');
    }
    if (!csv.contains('"Nguyen ""Minh"""')) {
      throw StateError('CSV chua escape quote dung.');
    }
    if (!csv.contains('"Ban than, cap 3"')) {
      throw StateError('CSV chua escape comma dung.');
    }

    final result = await service.exportCsv(eventList: eventList, records: records);
    final File file = File(result.filePath);
    if (!await file.exists()) {
      throw StateError('File export khong ton tai.');
    }

    final List<int> bytes = await file.readAsBytes();
    final List<int> bom = bytes.take(3).toList();
    if (bom.length != 3 || bom[0] != 0xEF || bom[1] != 0xBB || bom[2] != 0xBF) {
      throw StateError('File export khong co UTF-8 BOM.');
    }

    final String content = utf8.decode(bytes.skip(3).toList());
    if (!content.contains('Tran Anh') || !content.contains('650000')) {
      throw StateError('Noi dung file export khong dung.');
    }

    stdout.writeln('EXPORT_CSV_SMOKE_OK');
  } finally {
    if (await tempDirectory.exists()) {
      await tempDirectory.delete(recursive: true);
    }
  }
}
