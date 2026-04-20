import '../repositories/event_list_repository.dart';

class DeleteEventListUsecase {
  DeleteEventListUsecase(this._repository);

  final EventListRepository _repository;

  Future<void> call(int id) {
    return _repository.delete(id);
  }
}
