import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';
import 'package:gift_money_tracker/features/guest_records/domain/repositories/guest_record_repository.dart';
import 'package:gift_money_tracker/features/guest_records/presentation/providers/guest_record_providers.dart';

void main() {
  late FakeGuestRecordRepository repository;
  late ProviderContainer container;

  setUp(() {
    repository = FakeGuestRecordRepository(<GuestRecordEntity>[
      GuestRecordEntity(
        id: 1,
        eventListId: 10,
        fullName: 'Nguyen Minh',
        note: 'Ban than',
        amount: 500000,
        isDebtPaid: false,
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      ),
    ]);

    container = ProviderContainer(
      overrides: <Override>[
        guestRecordRepositoryProvider.overrideWithValue(repository),
      ],
    );
    addTearDown(container.dispose);
  });

  test('guestRecordActionController create them guest record moi', () async {
    final GuestRecordActionController controller = container.read(
      guestRecordActionControllerProvider.notifier,
    );

    final GuestRecordEntity created = await controller.create(
      GuestRecordEntity(
        id: 0,
        eventListId: 10,
        fullName: 'Tran Anh',
        note: 'Dong nghiep',
        amount: 300000,
        isDebtPaid: true,
        createdAt: DateTime(2026, 4, 2),
        updatedAt: DateTime(2026, 4, 2),
      ),
    );

    final List<GuestRecordEntity> records = await container.read(
      guestRecordsProvider(10).future,
    );

    expect(created.id, 2);
    expect(records, hasLength(2));
    expect(
      records.any((GuestRecordEntity item) => item.fullName == 'Tran Anh'),
      isTrue,
    );
  });

  test('guestRecordActionController update cap nhat du lieu hien co', () async {
    final GuestRecordActionController controller = container.read(
      guestRecordActionControllerProvider.notifier,
    );

    await controller.update(
      GuestRecordEntity(
        id: 1,
        eventListId: 10,
        fullName: 'Nguyen Minh',
        note: 'Ban than da cap nhat',
        amount: 750000,
        isDebtPaid: true,
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 3),
      ),
    );

    final List<GuestRecordEntity> records = await container.read(
      guestRecordsProvider(10).future,
    );

    expect(records, hasLength(1));
    expect(records.first.amount, 750000);
    expect(records.first.isDebtPaid, isTrue);
    expect(records.first.note, 'Ban than da cap nhat');
  });

  test('guestRecordActionController delete xoa guest record', () async {
    final GuestRecordActionController controller = container.read(
      guestRecordActionControllerProvider.notifier,
    );

    await controller.delete(
      GuestRecordEntity(
        id: 1,
        eventListId: 10,
        fullName: 'Nguyen Minh',
        note: 'Ban than',
        amount: 500000,
        isDebtPaid: false,
        createdAt: DateTime(2026, 4, 1),
        updatedAt: DateTime(2026, 4, 1),
      ),
    );

    final List<GuestRecordEntity> records = await container.read(
      guestRecordsProvider(10).future,
    );

    expect(records, isEmpty);
  });
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
