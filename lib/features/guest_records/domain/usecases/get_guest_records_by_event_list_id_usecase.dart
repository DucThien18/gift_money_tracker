import '../entities/guest_record_entity.dart';
import '../repositories/guest_record_repository.dart';

class GetGuestRecordsByEventListIdUsecase {
  GetGuestRecordsByEventListIdUsecase(this._repository);

  final GuestRecordRepository _repository;

  Future<List<GuestRecordEntity>> call(int eventListId) {
    return _repository.getByEventListId(eventListId);
  }
}
