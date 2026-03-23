import 'package:flutter/material.dart';

import '../../features/event_lists/presentation/pages/event_lists_page.dart';

abstract final class AppRouter {
  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case EventListsPage.routeName:
        return MaterialPageRoute<void>(
          builder: (_) => const EventListsPage(),
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
