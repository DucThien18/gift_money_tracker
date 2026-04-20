import 'package:isar/isar.dart';

part 'guest_record_isar_model.g.dart';

@collection
class GuestRecordIsarModel {
  GuestRecordIsarModel();

  int id = 0;

  @Index()
  late int eventListId;

  @Index()
  late String fullName;

  String note = '';
  int amount = 0;

  @Index()
  bool isDebtPaid = false;

  DateTime createdAt = DateTime.now();
  DateTime updatedAt = DateTime.now();
}
