import '../../domain/entities/event_list_entity.dart';
import '../../domain/repositories/event_list_repository.dart';
import '../datasources/event_list_local_datasource.dart';
import '../../../../core/database/schemas/event_list_isar_model.dart';

class EventListRepositoryImpl implements EventListRepository {
  EventListRepositoryImpl(this._localDatasource);

  final EventListLocalDatasource _localDatasource;

  @override
  Future<EventListEntity> create(EventListEntity entity) async {
    final model = _toModel(entity);
    final saved = await _localDatasource.create(model);
    return _toEntity(saved);
  }

  @override
  Future<List<EventListEntity>> getAll() async {
    final models = await _localDatasource.getAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<EventListEntity?> getById(int id) async {
    final model = await _localDatasource.getById(id);
    if (model == null) return null;
    return _toEntity(model);
  }

  @override
  Future<EventListEntity> update(EventListEntity entity) async {
    final model = _toModel(entity);
    final updated = await _localDatasource.update(model);
    return _toEntity(updated);
  }

  @override
  Future<void> delete(int id) {
    return _localDatasource.delete(id);
  }

  EventListIsarModel _toModel(EventListEntity entity) {
    final model = EventListIsarModel()
      ..id = entity.id
      ..code = entity.code
      ..name = entity.name
      ..eventDate = entity.eventDate
      ..description = entity.description
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }

  EventListEntity _toEntity(EventListIsarModel model) {
    return EventListEntity(
      id: model.id,
      code: model.code,
      name: model.name,
      eventDate: model.eventDate,
      description: model.description,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
