import '../entities/event_list_entity.dart';
import '../repositories/event_list_repository.dart';

class GetAllEventListsUsecase {
  GetAllEventListsUsecase(this._repository);

  final EventListRepository _repository;

  Future<List<EventListEntity>> call() {
    return _repository.getAll();
  }
}
