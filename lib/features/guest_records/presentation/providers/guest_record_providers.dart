import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/database/isar_service.dart';
import '../../data/datasources/guest_record_local_datasource.dart';
import '../../data/repositories/guest_record_repository_impl.dart';
import '../../domain/entities/guest_record_entity.dart';
import '../../domain/repositories/guest_record_repository.dart';
import '../../domain/usecases/create_guest_record_usecase.dart';
import '../../domain/usecases/delete_guest_record_usecase.dart';
import '../../domain/usecases/delete_guest_records_by_event_list_id_usecase.dart';
import '../../domain/usecases/get_all_guest_records_usecase.dart';
import '../../domain/usecases/get_guest_record_by_id_usecase.dart';
import '../../domain/usecases/get_guest_records_by_event_list_id_usecase.dart';
import '../../domain/usecases/update_guest_record_usecase.dart';

final guestRecordLocalDatasourceProvider = Provider<GuestRecordLocalDatasource>(
  (ref) {
    final isar = ref.watch(isarServiceProvider);
    return GuestRecordLocalDatasource(isar);
  },
);

final guestRecordRepositoryProvider = Provider<GuestRecordRepository>((ref) {
  final datasource = ref.watch(guestRecordLocalDatasourceProvider);
  return GuestRecordRepositoryImpl(datasource);
});

final createGuestRecordUsecaseProvider = Provider<CreateGuestRecordUsecase>((
  ref,
) {
  final repository = ref.watch(guestRecordRepositoryProvider);
  return CreateGuestRecordUsecase(repository);
});

final getGuestRecordsByEventListIdUsecaseProvider =
    Provider<GetGuestRecordsByEventListIdUsecase>((ref) {
      final repository = ref.watch(guestRecordRepositoryProvider);
      return GetGuestRecordsByEventListIdUsecase(repository);
    });

final getAllGuestRecordsUsecaseProvider = Provider<GetAllGuestRecordsUsecase>((
  ref,
) {
  final repository = ref.watch(guestRecordRepositoryProvider);
  return GetAllGuestRecordsUsecase(repository);
});

final getGuestRecordByIdUsecaseProvider = Provider<GetGuestRecordByIdUsecase>((
  ref,
) {
  final repository = ref.watch(guestRecordRepositoryProvider);
  return GetGuestRecordByIdUsecase(repository);
});

final updateGuestRecordUsecaseProvider = Provider<UpdateGuestRecordUsecase>((
  ref,
) {
  final repository = ref.watch(guestRecordRepositoryProvider);
  return UpdateGuestRecordUsecase(repository);
});

final deleteGuestRecordUsecaseProvider = Provider<DeleteGuestRecordUsecase>((
  ref,
) {
  final repository = ref.watch(guestRecordRepositoryProvider);
  return DeleteGuestRecordUsecase(repository);
});

final deleteGuestRecordsByEventListIdUsecaseProvider =
    Provider<DeleteGuestRecordsByEventListIdUsecase>((ref) {
      final repository = ref.watch(guestRecordRepositoryProvider);
      return DeleteGuestRecordsByEventListIdUsecase(repository);
    });

final guestRecordsProvider =
    FutureProvider.family<List<GuestRecordEntity>, int>((ref, int eventListId) {
      final getGuestRecords = ref.watch(
        getGuestRecordsByEventListIdUsecaseProvider,
      );
      return getGuestRecords(eventListId);
    });

final guestRecordActionControllerProvider =
    StateNotifierProvider<GuestRecordActionController, AsyncValue<void>>((ref) {
      return GuestRecordActionController(ref);
    });

class GuestRecordActionController extends StateNotifier<AsyncValue<void>> {
  GuestRecordActionController(this.ref) : super(const AsyncData(null));

  final Ref ref;

  Future<GuestRecordEntity> create(GuestRecordEntity entity) async {
    state = const AsyncLoading();
    try {
      final GuestRecordEntity created = await ref
          .read(createGuestRecordUsecaseProvider)(entity);
      _refreshCollections(created.eventListId);
      state = const AsyncData(null);
      return created;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<GuestRecordEntity> update(GuestRecordEntity entity) async {
    state = const AsyncLoading();
    try {
      final GuestRecordEntity updated = await ref
          .read(updateGuestRecordUsecaseProvider)(entity);
      _refreshCollections(updated.eventListId);
      state = const AsyncData(null);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(GuestRecordEntity entity) async {
    state = const AsyncLoading();
    try {
      await ref.read(deleteGuestRecordUsecaseProvider)(entity.id);
      _refreshCollections(entity.eventListId);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _refreshCollections(int eventListId) {
    ref.invalidate(guestRecordsProvider(eventListId));
  }
}
