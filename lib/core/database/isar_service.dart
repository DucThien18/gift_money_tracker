import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';

import '../constants/db_constants.dart';

class IsarService {
  IsarService._();

  static Future<Isar> open() async {
    final dir = await getApplicationDocumentsDirectory();
    return Isar.open(
      <CollectionSchema>[],
      directory: dir.path,
      name: DbConstants.dbName,
    );
  }
}
