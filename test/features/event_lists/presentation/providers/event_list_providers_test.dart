import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gift_money_tracker/features/event_lists/domain/entities/event_list_entity.dart';
import 'package:gift_money_tracker/features/event_lists/domain/repositories/event_list_repository.dart';
import 'package:gift_money_tracker/features/event_lists/presentation/providers/event_list_providers.dart';
import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';
import 'package:gift_money_tracker/features/guest_records/domain/repositories/guest_record_repository.dart';
import 'package:gift_money_tracker/features/guest_records/presentation/providers/guest_record_providers.dart';

void main() {
  late FakeEventListRepository eventRepository;
  late FakeGuestRecordRepository guestRepository;
  late ProviderContainer container;

  setUp(() {
    eventRepository = FakeEventListRepository(<EventListEntity>[
      EventListEntity(
        id: 1,
        code: 'EV-WEDDING',
        name: 'Dam cuoi Lan Anh',
        description: 'Ho noi',
        eventDate: DateTime(2026, 4, 8),
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 2),
      ),
      EventListEntity(
        id: 2,
        code: 'EV-BIRTHDAY',
        name: 'Sinh nhat Minh',
        description: 'Ban than',
        eventDate: DateTime(2026, 5, 10),
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      ),
      EventListEntity(
        id: 3,
        code: 'EV-ARCHIVED',
        name: 'Le ky niem cu',
        description: 'Da luu tru',
        eventDate: DateTime(2026, 3, 10),
        isArchived: true,
        createdAt: DateTime(2026, 3, 1),
        updatedAt: DateTime(2026, 3, 5),
      ),
    ]);

    guestRepository = FakeGuestRecordRepository(<GuestRecordEntity>[
      GuestRecordEntity(
        id: 1,
        eventListId: 1,
        fullName: 'Nguyen Minh',
        note: 'Ban than',
        amount: 500000,
        isDebtPaid: false,
        createdAt: DateTime(2026, 4, 2),
        updatedAt: DateTime(2026, 4, 2),
      ),
      GuestRecordEntity(
        id: 2,
        eventListId: 1,
        fullName: 'Tran Anh',
        note: 'Dong nghiep',
        amount: 300000,
        isDebtPaid: true,
        createdAt: DateTime(2026, 4, 3),
        updatedAt: DateTime(2026, 4, 3),
      ),
      GuestRecordEntity(
        id: 3,
        eventListId: 2,
        fullName: 'Pham Hoa',
        note: 'Hang xom',
        amount: 200000,
        isDebtPaid: false,
        createdAt: DateTime(2026, 4, 4),
        updatedAt: DateTime(2026, 4, 4),
      ),
      GuestRecordEntity(
        id: 4,
        eventListId: 3,
        fullName: 'Le Cu',
        note: 'Luu tru',
        amount: 900000,
        isDebtPaid: true,
        createdAt: DateTime(2026, 3, 4),
        updatedAt: DateTime(2026, 3, 4),
      ),
    ]);

    container = ProviderContainer(
      overrides: <Override>[
        eventListRepositoryProvider.overrideWithValue(eventRepository),
        guestRecordRepositoryProvider.overrideWithValue(guestRepository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('filteredEventListsProvider loc theo keyword', () async {
    container.read(eventListSearchQueryProvider.notifier).state = 'Lan Anh';

    final List<EventListEntity> result = await container.read(
      filteredEventListsProvider.future,
    );

    expect(result, hasLength(1));
    expect(result.first.name, 'Dam cuoi Lan Anh');
  });

  test('visibleEventListsProvider mac dinh an su kien da luu tru', () async {
    final List<EventListEntity> result = await container.read(
      visibleEventListsProvider.future,
    );

    expect(result.map((EventListEntity item) => item.id), <int>[1, 2]);
  });

  test('filteredEventListsProvider hien ca su kien da luu tru khi bat toggle', () async {
    container.read(eventListShowArchivedProvider.notifier).state = true;

    final List<EventListEntity> result = await container.read(
      filteredEventListsProvider.future,
    );

    expect(result.map((EventListEntity item) => item.id), <int>[1, 2, 3]);
  });

  test('eventListDashboardSummaryProvider tong hop dung so lieu', () async {
    final EventListDashboardSummary summary = await container.read(
      eventListDashboardSummaryProvider.future,
    );

    expect(summary.eventCount, 2);
    expect(summary.guestCount, 3);
    expect(summary.totalAmount, 1000000);
  });

  test('eventListActionController archive va restore cap nhat trang thai', () async {
    final EventListActionController controller = container.read(
      eventListActionControllerProvider.notifier,
    );
    final EventListEntity original = await container.read(
      eventListDetailsProvider(1).future,
    ) as EventListEntity;

    final EventListEntity archived = await controller.archive(original);
    final List<EventListEntity> visibleAfterArchive = await container.read(
      visibleEventListsProvider.future,
    );

    expect(archived.isArchived, isTrue);
    expect(
      visibleAfterArchive.any((EventListEntity item) => item.id == archived.id),
      isFalse,
    );

    container.read(eventListShowArchivedProvider.notifier).state = true;
    final List<EventListEntity> withArchived = await container.read(
      filteredEventListsProvider.future,
    );
    expect(
      withArchived.firstWhere((EventListEntity item) => item.id == 1).isArchived,
      isTrue,
    );

    final EventListEntity restored = await controller.restore(archived);
    final List<EventListEntity> visibleAfterRestore = await container.read(
      visibleEventListsProvider.future,
    );

    expect(restored.isArchived, isFalse);
    expect(
      visibleAfterRestore.any((EventListEntity item) => item.id == restored.id),
      isTrue,
    );
  });

  test('eventListActionController update cap nhat thong tin su kien', () async {
    final EventListActionController controller = container.read(
      eventListActionControllerProvider.notifier,
    );

    final EventListEntity original = await container.read(
      eventListDetailsProvider(1).future,
    ) as EventListEntity;

    final EventListEntity updated = await controller.update(
      eventList: original,
      name: 'Dam cuoi Lan Anh - Da doi lich',
      description: '',
      eventDate: null,
    );

    final EventListEntity? refreshed = await container.read(
      eventListDetailsProvider(1).future,
    );

    expect(updated.name, 'Dam cuoi Lan Anh - Da doi lich');
    expect(updated.description, isNull);
    expect(updated.eventDate, isNull);
    expect(refreshed?.name, 'Dam cuoi Lan Anh - Da doi lich');
    expect(refreshed?.description, isNull);
    expect(refreshed?.eventDate, isNull);
  });

  test('eventListActionController create va delete cap nhat du lieu', () async {
    final EventListActionController controller = container.read(
      eventListActionControllerProvider.notifier,
    );

    final EventListEntity created = await controller.create(
      name: 'Tan gia Hoang Gia',
      description: 'Hang xom',
      eventDate: DateTime(2026, 6, 1),
    );
    final List<EventListEntity> afterCreate = await container.read(
      allEventListsProvider.future,
    );

    expect(
      afterCreate.any((EventListEntity item) => item.id == created.id),
      isTrue,
    );

    await controller.delete(
      afterCreate.firstWhere((EventListEntity item) => item.id == 1),
    );

    final List<EventListEntity> afterDelete = await container.read(
      allEventListsProvider.future,
    );
    final List<GuestRecordEntity> remainingGuests = await guestRepository
        .getByEventListId(1);

    expect(afterDelete.any((EventListEntity item) => item.id == 1), isFalse);
    expect(remainingGuests, isEmpty);
  });
}

class FakeEventListRepository implements EventListRepository {
  FakeEventListRepository(List<EventListEntity> seed)
    : _items = List<EventListEntity>.from(seed);

  final List<EventListEntity> _items;

  @override
  Future<EventListEntity> create(EventListEntity entity) async {
    final int nextId = _items.isEmpty
        ? 1
        : _items.map((EventListEntity item) => item.id).reduce(_maxInt) + 1;
    final EventListEntity saved = entity.copyWith(id: nextId);
    _items.add(saved);
    return saved;
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((EventListEntity item) => item.id == id);
  }

  @override
  Future<List<EventListEntity>> getAll() async =>
      List<EventListEntity>.from(_items);

  @override
  Future<EventListEntity?> getById(int id) async {
    for (final EventListEntity item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<EventListEntity> update(EventListEntity entity) async {
    final int index = _items.indexWhere(
      (EventListEntity item) => item.id == entity.id,
    );
    _items[index] = entity;
    return entity;
  }
}

class FakeGuestRecordRepository implements GuestRecordRepository {
  FakeGuestRecordRepository(List<GuestRecordEntity> seed)
    : _items = List<GuestRecordEntity>.from(seed);

  final List<GuestRecordEntity> _items;

  @override
  Future<GuestRecordEntity> create(GuestRecordEntity entity) async {
    final int nextId = _items.isEmpty
        ? 1
        : _items.map((GuestRecordEntity item) => item.id).reduce(_maxInt) + 1;
    final GuestRecordEntity saved = entity.copyWith(id: nextId);
    _items.add(saved);
    return saved;
  }

  @override
  Future<List<GuestRecordEntity>> createMany(
    List<GuestRecordEntity> entities,
  ) async {
    final List<GuestRecordEntity> saved = <GuestRecordEntity>[];
    for (final GuestRecordEntity entity in entities) {
      saved.add(await create(entity));
    }
    return saved;
  }

  @override
  Future<List<GuestRecordEntity>> getAll() async {
    return List<GuestRecordEntity>.from(_items);
  }

  @override
  Future<void> delete(int id) async {
    _items.removeWhere((GuestRecordEntity item) => item.id == id);
  }

  @override
  Future<void> deleteMany(List<int> ids) async {
    _items.removeWhere((GuestRecordEntity item) => ids.contains(item.id));
  }

  @override
  Future<void> deleteByEventListId(int eventListId) async {
    _items.removeWhere(
      (GuestRecordEntity item) => item.eventListId == eventListId,
    );
  }

  @override
  Future<GuestRecordEntity?> getById(int id) async {
    for (final GuestRecordEntity item in _items) {
      if (item.id == id) {
        return item;
      }
    }
    return null;
  }

  @override
  Future<List<GuestRecordEntity>> getByEventListId(int eventListId) async {
    return _items
        .where((GuestRecordEntity item) => item.eventListId == eventListId)
        .toList();
  }

  @override
  Future<GuestRecordEntity> update(GuestRecordEntity entity) async {
    final int index = _items.indexWhere(
      (GuestRecordEntity item) => item.id == entity.id,
    );
    _items[index] = entity;
    return entity;
  }
}

int _maxInt(int left, int right) => left > right ? left : right;
