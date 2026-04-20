import '../entities/event_list_entity.dart';
import '../repositories/event_list_repository.dart';

class GetEventListByIdUsecase {
  GetEventListByIdUsecase(this._repository);

  final EventListRepository _repository;

  Future<EventListEntity?> call(int id) {
    return _repository.getById(id);
  }
}
