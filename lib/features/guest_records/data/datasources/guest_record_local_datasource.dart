import 'package:isar/isar.dart';

import '../../../../core/database/schemas/guest_record_isar_model.dart';

class GuestRecordLocalDatasource {
  GuestRecordLocalDatasource(this._isar);

  final Isar _isar;

  Future<GuestRecordIsarModel> create(GuestRecordIsarModel model) async {
    final now = DateTime.now();
    model.createdAt = now;
    model.updatedAt = now;

    await Future<void>.sync(() {
      _isar.write((isar) {
        if (model.id <= 0) {
          model.id = isar.guestRecordIsarModels.autoIncrement();
        }
        isar.guestRecordIsarModels.put(model);
      });
    });
    return model;
  }

  Future<List<GuestRecordIsarModel>> createMany(
    List<GuestRecordIsarModel> models,
  ) async {
    if (models.isEmpty) return const <GuestRecordIsarModel>[];

    final now = DateTime.now();
    for (final model in models) {
      model.createdAt = now;
      model.updatedAt = now;
    }

    await Future<void>.sync(() {
      _isar.write((isar) {
        for (final model in models) {
          if (model.id <= 0) {
            model.id = isar.guestRecordIsarModels.autoIncrement();
          }
        }
        isar.guestRecordIsarModels.putAll(models);
      });
    });
    return models;
  }

  Future<List<GuestRecordIsarModel>> getByEventListId(int eventListId) async {
    return _isar.read(
      (isar) => isar.guestRecordIsarModels
          .where()
          .eventListIdEqualTo(eventListId)
          .sortByCreatedAtDesc()
          .findAll(),
    );
  }

  Future<List<GuestRecordIsarModel>> getAll() async {
    return _isar.read(
      (isar) => isar.guestRecordIsarModels.where().sortByCreatedAtDesc().findAll(),
    );
  }

  Future<GuestRecordIsarModel?> getById(int id) async {
    return _isar.read((isar) => isar.guestRecordIsarModels.get(id));
  }

  Future<GuestRecordIsarModel> update(GuestRecordIsarModel model) async {
    model.updatedAt = DateTime.now();
    await Future<void>.sync(() {
      _isar.write((isar) {
        isar.guestRecordIsarModels.put(model);
      });
    });
    return model;
  }

  Future<void> delete(int id) async {
    await Future<void>.sync(() {
      _isar.write((isar) {
        isar.guestRecordIsarModels.delete(id);
      });
    });
  }

  Future<void> deleteMany(List<int> ids) async {
    if (ids.isEmpty) {
      return;
    }

    await Future<void>.sync(() {
      _isar.write((isar) {
        isar.guestRecordIsarModels.deleteAll(ids);
      });
    });
  }

  Future<void> deleteByEventListId(int eventListId) async {
    await Future<void>.sync(() {
      _isar.write((isar) {
        final records = isar.guestRecordIsarModels
            .where()
            .eventListIdEqualTo(eventListId)
            .findAll();
        final ids = records.map((e) => e.id).toList();
        if (ids.isNotEmpty) {
          isar.guestRecordIsarModels.deleteAll(ids);
        }
      });
    });
  }
}
