import 'package:isar/isar.dart';

import '../../../../core/database/schemas/event_list_isar_model.dart';

class EventListLocalDatasource {
  EventListLocalDatasource(this._isar);

  final Isar _isar;

  Future<EventListIsarModel> create(EventListIsarModel model) async {
    final now = DateTime.now();
    model.createdAt = now;
    model.updatedAt = now;
    await Future<void>.sync(() {
      _isar.write((isar) {
        if (model.id <= 0) {
          model.id = isar.eventListIsarModels.autoIncrement();
        }
        isar.eventListIsarModels.put(model);
      });
    });
    return model;
  }

  Future<List<EventListIsarModel>> getAll() async {
    return _isar.read(
      (isar) => isar.eventListIsarModels.where().sortByCreatedAtDesc().findAll(),
    );
  }

  Future<EventListIsarModel?> getById(int id) async {
    return _isar.read((isar) => isar.eventListIsarModels.get(id));
  }

  Future<EventListIsarModel> update(EventListIsarModel model) async {
    model.updatedAt = DateTime.now();
    await Future<void>.sync(() {
      _isar.write((isar) {
        isar.eventListIsarModels.put(model);
      });
    });
    return model;
  }

  Future<void> delete(int id) async {
    await Future<void>.sync(() {
      _isar.write((isar) {
        isar.eventListIsarModels.delete(id);
      });
    });
  }
}
