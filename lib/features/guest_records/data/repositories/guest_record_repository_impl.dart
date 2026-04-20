import '../../../../core/database/schemas/guest_record_isar_model.dart';
import '../../domain/entities/guest_record_entity.dart';
import '../../domain/repositories/guest_record_repository.dart';
import '../datasources/guest_record_local_datasource.dart';

class GuestRecordRepositoryImpl implements GuestRecordRepository {
  GuestRecordRepositoryImpl(this._localDatasource);

  final GuestRecordLocalDatasource _localDatasource;

  @override
  Future<GuestRecordEntity> create(GuestRecordEntity entity) async {
    final model = _toModel(entity);
    final saved = await _localDatasource.create(model);
    return _toEntity(saved);
  }

  @override
  Future<List<GuestRecordEntity>> createMany(
    List<GuestRecordEntity> entities,
  ) async {
    final models = entities.map(_toModel).toList();
    final saved = await _localDatasource.createMany(models);
    return saved.map(_toEntity).toList();
  }

  @override
  Future<List<GuestRecordEntity>> getAll() async {
    final models = await _localDatasource.getAll();
    return models.map(_toEntity).toList();
  }

  @override
  Future<List<GuestRecordEntity>> getByEventListId(int eventListId) async {
    final models = await _localDatasource.getByEventListId(eventListId);
    return models.map(_toEntity).toList();
  }

  @override
  Future<GuestRecordEntity?> getById(int id) async {
    final model = await _localDatasource.getById(id);
    if (model == null) return null;
    return _toEntity(model);
  }

  @override
  Future<GuestRecordEntity> update(GuestRecordEntity entity) async {
    final model = _toModel(entity);
    final updated = await _localDatasource.update(model);
    return _toEntity(updated);
  }

  @override
  Future<void> delete(int id) {
    return _localDatasource.delete(id);
  }

  @override
  Future<void> deleteByEventListId(int eventListId) {
    return _localDatasource.deleteByEventListId(eventListId);
  }

  GuestRecordIsarModel _toModel(GuestRecordEntity entity) {
    final model = GuestRecordIsarModel()
      ..id = entity.id
      ..eventListId = entity.eventListId
      ..fullName = entity.fullName
      ..note = entity.note
      ..amount = entity.amount
      ..isDebtPaid = entity.isDebtPaid
      ..createdAt = entity.createdAt
      ..updatedAt = entity.updatedAt;
    return model;
  }

  GuestRecordEntity _toEntity(GuestRecordIsarModel model) {
    return GuestRecordEntity(
      id: model.id,
      eventListId: model.eventListId,
      fullName: model.fullName,
      note: model.note,
      amount: model.amount,
      isDebtPaid: model.isDebtPaid,
      createdAt: model.createdAt,
      updatedAt: model.updatedAt,
    );
  }
}
