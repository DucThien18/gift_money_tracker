import '../entities/event_list_entity.dart';

abstract class EventListRepository {
  Future<EventListEntity> create(EventListEntity entity);
  Future<List<EventListEntity>> getAll();
  Future<EventListEntity?> getById(int id);
  Future<EventListEntity> update(EventListEntity entity);
  Future<void> delete(int id);
}
