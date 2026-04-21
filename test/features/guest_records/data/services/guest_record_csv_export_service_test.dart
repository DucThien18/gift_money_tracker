import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/features/event_lists/domain/entities/event_list_entity.dart';
import 'package:gift_money_tracker/features/guest_records/data/services/guest_record_csv_export_service.dart';
import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';

void main() {
  group('GuestRecordCsvExportService', () {
    test('buildCsvContent tao header va escape du lieu dung', () {
      final GuestRecordCsvExportService service = GuestRecordCsvExportService(
        externalDirectoryResolver: () async => Directory.systemTemp,
        applicationDirectoryResolver: () async => Directory.systemTemp,
        nowProvider: () => DateTime(2026, 4, 21, 10, 30),
      );

      final String csv = service.buildCsvContent(
        eventList: EventListEntity(
          id: 1,
          code: 'EV-WEDDING',
          name: 'Dam cuoi, Lan Anh',
          eventDate: DateTime(2026, 4, 20),
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime(2026, 4, 2),
        ),
        records: <GuestRecordEntity>[
          GuestRecordEntity(
            id: 1,
            eventListId: 1,
            fullName: 'Nguyen "Minh"',
            note: 'Ban than, cap 3',
            amount: 500000,
            isDebtPaid: false,
            createdAt: DateTime(2026, 4, 20, 8, 0),
            updatedAt: DateTime(2026, 4, 20, 9, 0),
          ),
        ],
      );

      expect(csv, contains('Mã sự kiện,Tên sự kiện,Ngày sự kiện,STT,Họ tên'));
      expect(csv, contains('"Dam cuoi, Lan Anh"'));
      expect(csv, contains('"Nguyen ""Minh"""'));
      expect(csv, contains('"Ban than, cap 3"'));
      expect(csv, contains('500000'));
      expect(csv, contains('Không'));
    });

    test('exportCsv ghi file voi UTF-8 BOM va tra ve ket qua', () async {
      final Directory tempDirectory = await Directory.systemTemp.createTemp(
        'gift_money_export_test_',
      );
      addTearDown(() async {
        if (await tempDirectory.exists()) {
          await tempDirectory.delete(recursive: true);
        }
      });

      final GuestRecordCsvExportService service = GuestRecordCsvExportService(
        externalDirectoryResolver: () async => tempDirectory,
        applicationDirectoryResolver: () async => tempDirectory,
        nowProvider: () => DateTime(2026, 4, 21, 10, 30, 45),
      );

      final result = await service.exportCsv(
        eventList: EventListEntity(
          id: 1,
          code: 'EV-WEDDING',
          name: 'Dam cuoi Lan Anh',
          eventDate: DateTime(2026, 4, 20),
          createdAt: DateTime(2026, 4, 1),
          updatedAt: DateTime(2026, 4, 2),
        ),
        records: <GuestRecordEntity>[
          GuestRecordEntity(
            id: 1,
            eventListId: 1,
            fullName: 'Tran Anh',
            note: 'Dong nghiep',
            amount: 650000,
            isDebtPaid: true,
            createdAt: DateTime(2026, 4, 20, 9, 0),
            updatedAt: DateTime(2026, 4, 20, 9, 15),
          ),
        ],
      );

      final File exportedFile = File(result.filePath);
      final List<int> bytes = await exportedFile.readAsBytes();
      final String content = utf8.decode(bytes.skip(3).toList());

      expect(await exportedFile.exists(), isTrue);
      expect(bytes.take(3).toList(), <int>[0xEF, 0xBB, 0xBF]);
      expect(result.fileName, 'nhat_ky_tien_mung_Dam_cuoi_Lan_Anh_20260421_103045.csv');
      expect(result.recordCount, 1);
      expect(content, contains('Tran Anh'));
      expect(content, contains('650000'));
      expect(content, contains('Có'));
    });
  });
}
