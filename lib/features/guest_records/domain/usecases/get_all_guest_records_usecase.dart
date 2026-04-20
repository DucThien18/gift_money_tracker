import '../entities/guest_record_entity.dart';
import '../repositories/guest_record_repository.dart';

class GetAllGuestRecordsUsecase {
  GetAllGuestRecordsUsecase(this._repository);

  final GuestRecordRepository _repository;

  Future<List<GuestRecordEntity>> call() {
    return _repository.getAll();
  }
}
