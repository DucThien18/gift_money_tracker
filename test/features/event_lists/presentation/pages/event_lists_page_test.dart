import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:gift_money_tracker/app/router/app_router.dart';
import 'package:gift_money_tracker/core/enums/import_status.dart';
import 'package:gift_money_tracker/core/services/excel_import_service.dart';
import 'package:gift_money_tracker/core/utils/currency_formatter.dart';
import 'package:gift_money_tracker/features/event_lists/domain/entities/event_list_entity.dart';
import 'package:gift_money_tracker/features/event_lists/domain/repositories/event_list_repository.dart';
import 'package:gift_money_tracker/features/event_lists/presentation/pages/event_lists_page.dart';
import 'package:gift_money_tracker/features/event_lists/presentation/providers/event_list_providers.dart';
import 'package:gift_money_tracker/features/excel_import/domain/entities/import_preview_row.dart';
import 'package:gift_money_tracker/features/excel_import/domain/usecases/import_excel_usecase.dart';
import 'package:gift_money_tracker/features/excel_import/presentation/providers/excel_import_provider.dart';
import 'package:gift_money_tracker/features/guest_records/domain/entities/guest_record_entity.dart';
import 'package:gift_money_tracker/features/guest_records/domain/repositories/guest_record_repository.dart';
import 'package:gift_money_tracker/features/guest_records/presentation/pages/guest_records_page.dart';
import 'package:gift_money_tracker/features/guest_records/presentation/providers/guest_record_providers.dart';

void main() {
  testWidgets(
    'EventListsPage mo duoc GuestRecordsPage va tiep tuc vao ExcelImportPage',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
          EventListEntity(
            id: 2,
            code: 'EV-BIRTHDAY',
            name: 'Sinh nhat Minh',
            description: 'Ban than',
            eventDate: DateTime(2026, 5, 10),
            createdAt: DateTime(2026, 4, 3),
            updatedAt: DateTime(2026, 4, 3),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[
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
          ]);

      await _pumpEventApp(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
      );

      expect(find.text('Danh sach su kien'), findsOneWidget);
      expect(find.text('Dam cuoi Lan Anh'), findsOneWidget);

      await tester.tap(find.text('Dam cuoi Lan Anh'));
      await tester.pumpAndSettle();

      expect(find.text('Guest records'), findsOneWidget);
      expect(find.text('Them khach'), findsOneWidget);
      expect(find.text('Import Excel'), findsOneWidget);

      await tester.tap(_buttonByLabel('Import Excel'));
      await tester.pumpAndSettle();

      expect(find.text('Import Excel'), findsOneWidget);
      expect(find.text('Kiem tra preview va import vao su kien #1.'), findsOneWidget);
      expect(find.text('Chua co du lieu preview'), findsOneWidget);
    },
  );

  testWidgets(
    'GuestRecordsPage hien thi empty state khi su kien chua co guest record',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 2,
            code: 'EV-BIRTHDAY',
            name: 'Sinh nhat Minh',
            description: 'Ban than',
            eventDate: DateTime(2026, 5, 10),
            createdAt: DateTime(2026, 4, 3),
            updatedAt: DateTime(2026, 4, 3),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[]);

      await _pumpGuestPage(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
        eventListId: 2,
      );

      expect(find.text('Sinh nhat Minh'), findsOneWidget);
      expect(find.text('Chua co guest record'), findsOneWidget);
      expect(find.text('Them khach dau tien'), findsOneWidget);
      expect(find.text('Import Excel'), findsNWidgets(2));
    },
  );

  testWidgets(
    'EventListsPage tao su kien moi va mo detail cua su kien vua tao',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[]);

      await _pumpEventApp(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
      );

      await tester.tap(_buttonByLabel('Tao su kien'));
      await tester.pumpAndSettle();

      await tester.enterText(
        _textFieldByLabel('Ten su kien'),
        'Tan gia Hoang Gia',
      );
      await tester.enterText(
        _textFieldByLabel('Mo ta ngan'),
        'Hang xom than thiet',
      );
      await tester.tap(_buttonByLabel('Tao va mo'));
      await tester.pumpAndSettle();

      expect(find.text('Tan gia Hoang Gia'), findsOneWidget);
      expect(find.text('Guest records'), findsOneWidget);

      final List<EventListEntity> items = await eventRepository.getAll();
      expect(
        items.any((EventListEntity item) => item.name == 'Tan gia Hoang Gia'),
        isTrue,
      );
    },
  );

  testWidgets(
    'EventListsPage cap nhat dashboard va event overview sau khi them guest record',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[]);

      await _pumpEventApp(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
      );

      expect(find.text(CurrencyFormatter.formatVnd(0)), findsNWidgets(2));

      await tester.tap(find.text('Dam cuoi Lan Anh'));
      await tester.pumpAndSettle();

      await tester.tap(_buttonByLabel('Them khach'));
      await tester.pumpAndSettle();

      await tester.enterText(_textFieldByLabel('Ten khach'), 'Tran Anh');
      await tester.enterText(_textFieldByLabel('So tien mung'), '700000');
      await tester.enterText(_textFieldByLabel('Ghi chu'), 'Dong nghiep');
      await tester.tap(_buttonByLabel('Them khach').last);
      await tester.pumpAndSettle();

      expect(find.text('Tran Anh'), findsOneWidget);

      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text(CurrencyFormatter.formatVnd(0)), findsNothing);
      expect(find.text(CurrencyFormatter.formatVnd(700000)), findsNWidgets(2));

      final List<GuestRecordEntity> guests = await guestRepository
          .getByEventListId(1);
      expect(guests, hasLength(1));
      expect(guests.first.fullName, 'Tran Anh');
      expect(guests.first.amount, 700000);
    },
  );

  testWidgets(
    'EventListsPage import Excel cap nhat GuestRecordsPage va dashboard khi quay lai',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[]);
      final TestImportFlowNotifier importNotifier = TestImportFlowNotifier(
        guestRepository: guestRepository,
      );

      await _pumpEventApp(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
        extraOverrides: <Override>[
          excelImportProvider.overrideWith((ref) => importNotifier),
        ],
      );

      expect(find.text(CurrencyFormatter.formatVnd(0)), findsNWidgets(2));

      await tester.tap(find.text('Dam cuoi Lan Anh'));
      await tester.pumpAndSettle();

      await tester.tap(_buttonByLabel('Import Excel').first);
      await tester.pumpAndSettle();

      expect(find.text('1. Tran Anh'), findsOneWidget);
      expect(find.text('Xac nhan import'), findsOneWidget);

      await tester.tap(_buttonByLabel('Xac nhan import'));
      await tester.pumpAndSettle();

      expect(find.text('Import thanh cong'), findsOneWidget);
      expect(find.text('Quay lai su kien'), findsOneWidget);

      await tester.tap(_buttonByLabel('Quay lai su kien'));
      await tester.pumpAndSettle();

      expect(find.text('Tran Anh'), findsOneWidget);
      expect(find.text('Import tu Excel'), findsOneWidget);
      expect(
        find.text(CurrencyFormatter.formatVnd(650000)),
        findsAtLeastNWidgets(2),
      );

      await tester.tap(find.byIcon(Icons.arrow_back_rounded).first);
      await tester.pumpAndSettle();

      expect(find.text(CurrencyFormatter.formatVnd(0)), findsNothing);
      expect(find.text(CurrencyFormatter.formatVnd(650000)), findsNWidgets(2));

      final List<GuestRecordEntity> guests = await guestRepository
          .getByEventListId(1);
      expect(guests, hasLength(1));
      expect(guests.first.fullName, 'Tran Anh');
      expect(guests.first.note, 'Import tu Excel');
      expect(guests.first.amount, 650000);
    },
  );

  testWidgets(
    'EventListsPage xoa su kien va xoa luon guest records lien quan',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
          EventListEntity(
            id: 2,
            code: 'EV-BIRTHDAY',
            name: 'Sinh nhat Minh',
            description: 'Ban than',
            eventDate: DateTime(2026, 5, 10),
            createdAt: DateTime(2026, 4, 3),
            updatedAt: DateTime(2026, 4, 3),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[
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
          ]);

      await _pumpEventApp(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
      );

      await tester.tap(_eventPopupMenuButton().at(1));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoa su kien'));
      await tester.pumpAndSettle();
      await tester.tap(_buttonByLabel('Xoa'));
      await tester.pumpAndSettle();

      expect(find.text('Dam cuoi Lan Anh'), findsNothing);
      expect(find.text('Sinh nhat Minh'), findsOneWidget);

      final List<EventListEntity> items = await eventRepository.getAll();
      final List<GuestRecordEntity> relatedGuests = await guestRepository
          .getByEventListId(1);
      expect(items.any((EventListEntity item) => item.id == 1), isFalse);
      expect(relatedGuests, isEmpty);
    },
  );

  testWidgets(
    'EventListsPage chinh sua su kien tu menu hanh dong',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[]);

      await _pumpEventApp(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
      );

      await tester.tap(_eventPopupMenuButton().first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sua su kien'));
      await tester.pumpAndSettle();

      await tester.enterText(
        _textFieldByLabel('Ten su kien'),
        'Dam cuoi Lan Anh - Da doi lich',
      );
      await tester.enterText(
        _textFieldByLabel('Mo ta ngan'),
        'Da doi sang khach san moi',
      );
      await tester.tap(_buttonByLabel('Luu thay doi'));
      await tester.pumpAndSettle();

      expect(find.text('Dam cuoi Lan Anh - Da doi lich'), findsOneWidget);
      expect(find.text('Da doi sang khach san moi'), findsOneWidget);

      final EventListEntity? updated = await eventRepository.getById(1);
      expect(updated?.name, 'Dam cuoi Lan Anh - Da doi lich');
      expect(updated?.description, 'Da doi sang khach san moi');
    },
  );

  testWidgets(
    'GuestRecordsPage them guest record thu cong tu empty state',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 2,
            code: 'EV-BIRTHDAY',
            name: 'Sinh nhat Minh',
            description: 'Ban than',
            eventDate: DateTime(2026, 5, 10),
            createdAt: DateTime(2026, 4, 3),
            updatedAt: DateTime(2026, 4, 3),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[]);

      await _pumpGuestPage(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
        eventListId: 2,
      );

      await tester.tap(_buttonByLabel('Them khach dau tien'));
      await tester.pumpAndSettle();

      await tester.enterText(_textFieldByLabel('Ten khach'), 'Tran Anh');
      await tester.enterText(_textFieldByLabel('So tien mung'), '700000');
      await tester.enterText(_textFieldByLabel('Ghi chu'), 'Dong nghiep');
      await tester.tap(_buttonByLabel('Them khach').last);
      await tester.pumpAndSettle();

      expect(find.text('Tran Anh'), findsOneWidget);

      final List<GuestRecordEntity> guests = await guestRepository
          .getByEventListId(2);
      expect(guests, hasLength(1));
      expect(guests.first.note, 'Dong nghiep');
      expect(guests.first.amount, 700000);
    },
  );

  testWidgets(
    'GuestRecordsPage xoa guest record tu menu hanh dong',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[
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
          ]);

      await _pumpGuestPage(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
        eventListId: 1,
      );

      await tester.tap(find.byTooltip('Hanh dong').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Xoa'));
      await tester.pumpAndSettle();
      await tester.tap(_buttonByLabel('Xoa'));
      await tester.pumpAndSettle();

      expect(find.text('Chua co guest record'), findsOneWidget);

      final List<GuestRecordEntity> guests = await guestRepository
          .getByEventListId(1);
      expect(guests, isEmpty);
    },
  );

  testWidgets(
    'GuestRecordsPage chinh sua guest record tu menu hanh dong',
    (WidgetTester tester) async {
      final FakeEventListRepository eventRepository = FakeEventListRepository(
        <EventListEntity>[
          EventListEntity(
            id: 1,
            code: 'EV-WEDDING',
            name: 'Dam cuoi Lan Anh',
            description: 'Ho noi',
            eventDate: DateTime(2026, 4, 20),
            createdAt: DateTime(2026, 4, 1),
            updatedAt: DateTime(2026, 4, 2),
          ),
        ],
      );
      final FakeGuestRecordRepository guestRepository =
          FakeGuestRecordRepository(<GuestRecordEntity>[
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
          ]);

      await _pumpGuestPage(
        tester,
        eventRepository: eventRepository,
        guestRepository: guestRepository,
        eventListId: 1,
      );

      await tester.tap(find.byTooltip('Hanh dong').first);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Sua'));
      await tester.pumpAndSettle();

      await tester.enterText(_textFieldByLabel('Ten khach'), 'Nguyen Minh moi');
      await tester.enterText(_textFieldByLabel('So tien mung'), '900000');
      await tester.enterText(_textFieldByLabel('Ghi chu'), 'Dong nghiep than');
      await tester.tap(_buttonByLabel('Luu thay doi'));
      await tester.pumpAndSettle();

      expect(find.text('Nguyen Minh moi'), findsOneWidget);
      expect(find.text('Dong nghiep than'), findsOneWidget);

      final GuestRecordEntity? updated = await guestRepository.getById(1);
      expect(updated?.fullName, 'Nguyen Minh moi');
      expect(updated?.note, 'Dong nghiep than');
      expect(updated?.amount, 900000);
    },
  );
}

Future<void> _pumpEventApp(
  WidgetTester tester, {
  required EventListRepository eventRepository,
  required GuestRecordRepository guestRepository,
  List<Override> extraOverrides = const <Override>[],
}) async {
  tester.view.physicalSize = const Size(1440, 2560);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        eventListRepositoryProvider.overrideWithValue(eventRepository),
        guestRecordRepositoryProvider.overrideWithValue(guestRepository),
        ...extraOverrides,
      ],
      child: MaterialApp(
        initialRoute: EventListsPage.routeName,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> _pumpGuestPage(
  WidgetTester tester, {
  required EventListRepository eventRepository,
  required GuestRecordRepository guestRepository,
  required int eventListId,
}) async {
  tester.view.physicalSize = const Size(1440, 2560);
  tester.view.devicePixelRatio = 1;
  addTearDown(() {
    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });

  await tester.pumpWidget(
    ProviderScope(
      overrides: <Override>[
        eventListRepositoryProvider.overrideWithValue(eventRepository),
        guestRecordRepositoryProvider.overrideWithValue(guestRepository),
      ],
      child: MaterialApp(home: GuestRecordsPage(eventListId: eventListId)),
    ),
  );
  await tester.pumpAndSettle();
}

Finder _buttonByLabel(String label) {
  return find.ancestor(
    of: find.text(label),
    matching: find.byWidgetPredicate(
      (Widget widget) =>
          widget is ButtonStyleButton || widget is FloatingActionButton,
    ),
  );
}

Finder _textFieldByLabel(String label) {
  return find.byWidgetPredicate(
    (Widget widget) =>
        widget is TextField && widget.decoration?.labelText == label,
  );
}

Finder _eventPopupMenuButton() {
  return find.byWidgetPredicate(
    (Widget widget) => widget is PopupMenuButton<String>,
  );
}

class TestImportFlowNotifier extends ExcelImportNotifier {
  TestImportFlowNotifier({required GuestRecordRepository guestRepository})
    : _guestRepository = guestRepository,
      super(
        ImportExcelUseCase(
          excelImportService: const ExcelImportService(),
          guestRecordRepository: guestRepository,
        ),
      ) {
    state = ExcelImportState(
      status: ImportStatus.readyToImport,
      previewRows: <ImportPreviewRow>[
        ImportPreviewRow(
          rowNumber: 1,
          fullNameRaw: 'Tran Anh',
          noteRaw: 'Import tu Excel',
          amountRaw: '650000',
          isDebtPaidRaw: '',
          parsedFullName: 'Tran Anh',
          parsedNote: 'Import tu Excel',
          parsedAmount: 650000,
          parsedIsDebtPaid: false,
          errors: const <String>[],
        ),
      ],
      fileName: 'guest-records.xlsx',
      fileBytes: Uint8List.fromList(<int>[1, 2, 3]),
    );
  }

  final GuestRecordRepository _guestRepository;

  @override
  Future<void> confirmImport(int eventListId) async {
    state = state.copyWith(status: ImportStatus.importing, clearError: true);

    await _guestRepository.createMany(<GuestRecordEntity>[
      GuestRecordEntity(
        id: 0,
        eventListId: eventListId,
        fullName: 'Tran Anh',
        note: 'Import tu Excel',
        amount: 650000,
        isDebtPaid: false,
        createdAt: DateTime(2026, 4, 20, 9),
        updatedAt: DateTime(2026, 4, 20, 9),
      ),
    ]);

    state = state.copyWith(
      status: ImportStatus.success,
      importResult: const ImportResult(
        totalRows: 1,
        importedCount: 1,
        skippedCount: 0,
        errorCount: 0,
      ),
    );
  }
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
