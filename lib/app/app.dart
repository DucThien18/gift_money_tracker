import 'package:flutter/material.dart';

import 'router/app_router.dart';
import 'theme/app_theme.dart';

class GiftMoneyTrackerApp extends StatelessWidget {
  const GiftMoneyTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nhật ký tiền mừng',
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.light,
      onGenerateRoute: AppRouter.onGenerateRoute,
      initialRoute: '/',
      debugShowCheckedModeBanner: false,
    );
  }
}
