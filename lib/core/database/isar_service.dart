import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/db_constants.dart';
import 'schemas/event_list_isar_model.dart';
import 'schemas/guest_record_isar_model.dart';

class IsarService {
  IsarService._();

  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.openAsync(
      schemas: <IsarGeneratedSchema>[
        EventListIsarModelSchema,
        GuestRecordIsarModelSchema,
      ],
      directory: dir.path,
      name: DbConstants.dbName,
    );
  }
}

final isarServiceProvider = Provider<Isar>((ref) {
  throw UnimplementedError(
    'isarServiceProvider cần được override trong ProviderScope.',
  );
});
