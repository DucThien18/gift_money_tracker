import '../../../event_lists/domain/entities/event_list_entity.dart';
import '../entities/guest_record_entity.dart';
import '../entities/guest_record_export_result.dart';
import '../services/guest_record_export_service.dart';

class ExportGuestRecordsCsvUsecase {
  const ExportGuestRecordsCsvUsecase(this._exportService);

  final GuestRecordExportService _exportService;

  Future<GuestRecordExportResult> call({
    required EventListEntity eventList,
    required List<GuestRecordEntity> records,
  }) {
    return _exportService.exportCsv(eventList: eventList, records: records);
  }
}
