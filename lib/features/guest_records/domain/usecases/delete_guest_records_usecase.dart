import '../repositories/guest_record_repository.dart';

class DeleteGuestRecordsUsecase {
  DeleteGuestRecordsUsecase(this._repository);

  final GuestRecordRepository _repository;

  Future<void> call(List<int> ids) {
    return _repository.deleteMany(ids);
  }
}
