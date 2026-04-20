import '../entities/guest_record_entity.dart';

abstract class GuestRecordRepository {
  Future<GuestRecordEntity> create(GuestRecordEntity entity);
  Future<List<GuestRecordEntity>> createMany(List<GuestRecordEntity> entities);
  Future<List<GuestRecordEntity>> getAll();
  Future<List<GuestRecordEntity>> getByEventListId(int eventListId);
  Future<GuestRecordEntity?> getById(int id);
  Future<GuestRecordEntity> update(GuestRecordEntity entity);
  Future<void> delete(int id);
  Future<void> deleteByEventListId(int eventListId);
}
