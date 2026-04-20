import 'package:flutter/material.dart';

import '../../features/event_lists/presentation/pages/event_lists_page.dart';
import '../../features/excel_import/presentation/pages/excel_import_page.dart';
import '../../features/guest_records/presentation/pages/guest_records_page.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case EventListsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const EventListsPage(),
          settings: settings,
        );
      case ExcelImportPage.routeName:
        final int eventListId = (settings.arguments as int?) ?? 1;
        return MaterialPageRoute<void>(
          builder: (_) => ExcelImportPage(eventListId: eventListId),
          settings: settings,
        );
      case GuestRecordsPage.routeName:
        final int eventListId = (settings.arguments as int?) ?? 1;
        return MaterialPageRoute<void>(
          builder: (_) => GuestRecordsPage(eventListId: eventListId),
          settings: settings,
        );
      default:
        return MaterialPageRoute<void>(
          builder: (_) => const EventListsPage(),
          settings: settings,
        );
    }
  }
}
