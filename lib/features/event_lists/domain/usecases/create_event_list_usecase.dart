import '../entities/event_list_entity.dart';
import '../repositories/event_list_repository.dart';

class CreateEventListUsecase {
  CreateEventListUsecase(this._repository);

  final EventListRepository _repository;

  Future<EventListEntity> call(EventListEntity entity) {
    return _repository.create(entity);
  }
}
