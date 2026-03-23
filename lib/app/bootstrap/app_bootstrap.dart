import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app.dart';

abstract final class AppBootstrap {
  static Widget createApp() {
    return const ProviderScope(child: GiftMoneyTrackerApp());
  }
}
