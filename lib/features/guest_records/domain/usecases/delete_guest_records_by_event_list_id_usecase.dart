import '../repositories/guest_record_repository.dart';

class DeleteGuestRecordsByEventListIdUsecase {
  DeleteGuestRecordsByEventListIdUsecase(this._repository);

  final GuestRecordRepository _repository;

  Future<void> call(int eventListId) {
    return _repository.deleteByEventListId(eventListId);
  }
}
