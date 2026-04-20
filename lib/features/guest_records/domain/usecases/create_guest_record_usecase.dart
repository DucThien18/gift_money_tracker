import '../entities/guest_record_entity.dart';
import '../repositories/guest_record_repository.dart';

class CreateGuestRecordUsecase {
  CreateGuestRecordUsecase(this._repository);

  final GuestRecordRepository _repository;

  Future<GuestRecordEntity> call(GuestRecordEntity entity) {
    return _repository.create(entity);
  }
}
