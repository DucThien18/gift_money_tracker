import '../../../event_lists/domain/entities/event_list_entity.dart';
import '../entities/guest_record_entity.dart';
import '../entities/guest_record_export_result.dart';

abstract class GuestRecordExportService {
  Future<GuestRecordExportResult> exportCsv({
    required EventListEntity eventList,
    required List<GuestRecordEntity> records,
  });
}
