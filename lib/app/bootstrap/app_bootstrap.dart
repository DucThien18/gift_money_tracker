import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/database/isar_service.dart';
import '../app.dart';

abstract final class AppBootstrap {
  static Future<Widget> createApp() async {
    final isar = await IsarService.open();
    return ProviderScope(
      overrides: [isarServiceProvider.overrideWithValue(isar)],
      child: const GiftMoneyTrackerApp(),
    );
  }
}
