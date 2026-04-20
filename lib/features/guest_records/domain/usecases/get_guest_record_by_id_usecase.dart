import '../entities/guest_record_entity.dart';
import '../repositories/guest_record_repository.dart';

class GetGuestRecordByIdUsecase {
  GetGuestRecordByIdUsecase(this._repository);

  final GuestRecordRepository _repository;

  Future<GuestRecordEntity?> call(int id) {
    return _repository.getById(id);
  }
}
