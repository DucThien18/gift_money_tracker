import '../repositories/guest_record_repository.dart';

class DeleteGuestRecordUsecase {
  DeleteGuestRecordUsecase(this._repository);

  final GuestRecordRepository _repository;

  Future<void> call(int id) {
    return _repository.delete(id);
  }
}
