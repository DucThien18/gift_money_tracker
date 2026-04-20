import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../../../core/database/isar_service.dart';
import '../../../../core/services/search_service.dart';
import '../../../guest_records/domain/entities/guest_record_entity.dart';
import '../../../guest_records/presentation/providers/guest_record_providers.dart';
import '../../data/datasources/event_list_local_datasource.dart';
import '../../data/repositories/event_list_repository_impl.dart';
import '../../domain/entities/event_list_entity.dart';
import '../../domain/repositories/event_list_repository.dart';
import '../../domain/usecases/create_event_list_usecase.dart';
import '../../domain/usecases/delete_event_list_usecase.dart';
import '../../domain/usecases/get_all_event_lists_usecase.dart';
import '../../domain/usecases/get_event_list_by_id_usecase.dart';
import '../../domain/usecases/update_event_list_usecase.dart';

final eventListLocalDatasourceProvider = Provider<EventListLocalDatasource>((
  ref,
) {
  final isar = ref.watch(isarServiceProvider);
  return EventListLocalDatasource(isar);
});

final eventListRepositoryProvider = Provider<EventListRepository>((ref) {
  final datasource = ref.watch(eventListLocalDatasourceProvider);
  return EventListRepositoryImpl(datasource);
});

final createEventListUsecaseProvider = Provider<CreateEventListUsecase>((ref) {
  final repository = ref.watch(eventListRepositoryProvider);
  return CreateEventListUsecase(repository);
});

final getAllEventListsUsecaseProvider = Provider<GetAllEventListsUsecase>((
  ref,
) {
  final repository = ref.watch(eventListRepositoryProvider);
  return GetAllEventListsUsecase(repository);
});

final getEventListByIdUsecaseProvider = Provider<GetEventListByIdUsecase>((
  ref,
) {
  final repository = ref.watch(eventListRepositoryProvider);
  return GetEventListByIdUsecase(repository);
});

final updateEventListUsecaseProvider = Provider<UpdateEventListUsecase>((ref) {
  final repository = ref.watch(eventListRepositoryProvider);
  return UpdateEventListUsecase(repository);
});

final deleteEventListUsecaseProvider = Provider<DeleteEventListUsecase>((ref) {
  final repository = ref.watch(eventListRepositoryProvider);
  return DeleteEventListUsecase(repository);
});

final eventListSearchQueryProvider = StateProvider<String>((ref) => '');

final eventListSearchServiceProvider = Provider<SearchService>((ref) {
  return const SearchService();
});

final allEventListsProvider = FutureProvider<List<EventListEntity>>((
  ref,
) async {
  final getAllEventLists = ref.watch(getAllEventListsUsecaseProvider);
  final List<EventListEntity> eventLists = await getAllEventLists();
  eventLists.sort((EventListEntity a, EventListEntity b) {
    final int updatedCompared = b.updatedAt.compareTo(a.updatedAt);
    if (updatedCompared != 0) {
      return updatedCompared;
    }
    return b.createdAt.compareTo(a.createdAt);
  });
  return eventLists;
});

final filteredEventListsProvider = FutureProvider<List<EventListEntity>>((
  ref,
) async {
  final String keyword = ref.watch(eventListSearchQueryProvider);
  final SearchService searchService = ref.watch(eventListSearchServiceProvider);
  final List<EventListEntity> eventLists = await ref.watch(
    allEventListsProvider.future,
  );
  return searchService.filterEventLists(
    eventLists: eventLists,
    keyword: keyword,
  );
});

final eventListDetailsProvider = FutureProvider.family<EventListEntity?, int>((
  ref,
  int eventListId,
) async {
  final getEventListById = ref.watch(getEventListByIdUsecaseProvider);
  return getEventListById(eventListId);
});

class EventListOverview {
  const EventListOverview({
    required this.guestCount,
    required this.totalAmount,
    required this.debtCount,
  });

  final int guestCount;
  final int totalAmount;
  final int debtCount;
}

class EventListDashboardSummary {
  const EventListDashboardSummary({
    required this.eventCount,
    required this.guestCount,
    required this.totalAmount,
  });

  final int eventCount;
  final int guestCount;
  final int totalAmount;
}

final eventListOverviewProvider = FutureProvider.family<EventListOverview, int>(
  (ref, int eventListId) async {
    final List<GuestRecordEntity> guestRecords = await ref.watch(
      guestRecordsProvider(eventListId).future,
    );

    final int totalAmount = guestRecords.fold<int>(
      0,
      (int sum, GuestRecordEntity record) => sum + record.amount,
    );
    final int debtCount = guestRecords
        .where((GuestRecordEntity record) => !record.isDebtPaid)
        .length;

    return EventListOverview(
      guestCount: guestRecords.length,
      totalAmount: totalAmount,
      debtCount: debtCount,
    );
  },
);

final eventListDashboardSummaryProvider =
    FutureProvider<EventListDashboardSummary>((ref) async {
      final List<EventListEntity> eventLists = await ref.watch(
        allEventListsProvider.future,
      );
      if (eventLists.isEmpty) {
        return const EventListDashboardSummary(
          eventCount: 0,
          guestCount: 0,
          totalAmount: 0,
        );
      }

      final Set<int> eventIds = eventLists
          .map((EventListEntity eventList) => eventList.id)
          .toSet();
      final List<GuestRecordEntity> guestRecords = await ref.watch(
        getAllGuestRecordsUsecaseProvider,
      )();

      int guestCount = 0;
      int totalAmount = 0;
      for (final GuestRecordEntity record in guestRecords) {
        if (!eventIds.contains(record.eventListId)) {
          continue;
        }
        guestCount += 1;
        totalAmount += record.amount;
      }

      return EventListDashboardSummary(
        eventCount: eventLists.length,
        guestCount: guestCount,
        totalAmount: totalAmount,
      );
    });

final eventListActionControllerProvider =
    StateNotifierProvider<EventListActionController, AsyncValue<void>>((ref) {
      return EventListActionController(ref);
    });

class EventListActionController extends StateNotifier<AsyncValue<void>> {
  EventListActionController(this.ref)
    : _uuid = const Uuid(),
      super(const AsyncData(null));

  final Ref ref;
  final Uuid _uuid;

  Future<EventListEntity> create({
    required String name,
    String? description,
    DateTime? eventDate,
  }) async {
    final String trimmedName = _validateName(name);

    state = const AsyncLoading();
    try {
      final DateTime now = DateTime.now();
      final createEventList = ref.read(createEventListUsecaseProvider);
      final created = await createEventList(
        EventListEntity(
          id: 0,
          code: 'EV-${_uuid.v4().split('-').first.toUpperCase()}',
          name: trimmedName,
          description: _normalizeDescription(description),
          eventDate: eventDate,
          createdAt: now,
          updatedAt: now,
        ),
      );

      _refreshCollections(created.id);
      state = const AsyncData(null);
      return created;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<EventListEntity> update({
    required EventListEntity eventList,
    required String name,
    String? description,
    DateTime? eventDate,
  }) async {
    final String trimmedName = _validateName(name);

    state = const AsyncLoading();
    try {
      final EventListEntity updated = await ref.read(updateEventListUsecaseProvider)(
        EventListEntity(
          id: eventList.id,
          code: eventList.code,
          name: trimmedName,
          description: _normalizeDescription(description),
          eventDate: eventDate,
          createdAt: eventList.createdAt,
          updatedAt: DateTime.now(),
        ),
      );

      _refreshCollections(updated.id);
      state = const AsyncData(null);
      return updated;
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  Future<void> delete(EventListEntity eventList) async {
    state = const AsyncLoading();
    try {
      await ref.read(deleteGuestRecordsByEventListIdUsecaseProvider)(
        eventList.id,
      );
      await ref.read(deleteEventListUsecaseProvider)(eventList.id);

      _refreshCollections(eventList.id);
      state = const AsyncData(null);
    } catch (error, stackTrace) {
      state = AsyncError(error, stackTrace);
      rethrow;
    }
  }

  void _refreshCollections(int eventListId) {
    ref.invalidate(allEventListsProvider);
    ref.invalidate(filteredEventListsProvider);
    ref.invalidate(eventListDetailsProvider(eventListId));
    ref.invalidate(eventListOverviewProvider(eventListId));
    ref.invalidate(eventListDashboardSummaryProvider);
    ref.invalidate(guestRecordsProvider(eventListId));
  }

  String _validateName(String name) {
    final String trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw ArgumentError('Ten su kien khong duoc de trong.');
    }
    return trimmedName;
  }

  String? _normalizeDescription(String? description) {
    final String? trimmed = description?.trim();
    if (trimmed == null || trimmed.isEmpty) {
      return null;
    }
    return trimmed;
  }
}
