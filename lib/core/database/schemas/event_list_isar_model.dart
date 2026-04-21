import 'package:isar/isar.dart';

part 'event_list_isar_model.g.dart';

@collection
class EventListIsarModel {
  EventListIsarModel();

  int id = 0;

  @Index(unique: true)
  late String code;

  @Index()
  late String name;

  DateTime? eventDate;
  String? description;
  @Index()
  bool isArchived = false;
  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
