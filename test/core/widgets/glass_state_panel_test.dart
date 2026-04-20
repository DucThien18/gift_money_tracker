import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/core/widgets/shared/glass_panel.dart';
import 'package:gift_money_tracker/core/widgets/shared/glass_state_panel.dart';

void main() {
  testWidgets('GlassStatePanel hien thi noi dung va actions', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: GlassStatePanel(
            icon: Icons.inbox_rounded,
            title: 'Chua co du lieu',
            message: 'Hay tao muc dau tien de bat dau.',
            actions: <Widget>[
              FilledButton(
                onPressed: () {},
                child: const Text('Tao moi'),
              ),
            ],
          ),
        ),
      ),
    );

    expect(find.byType(GlassPanel), findsOneWidget);
    expect(find.text('Chua co du lieu'), findsOneWidget);
    expect(find.text('Hay tao muc dau tien de bat dau.'), findsOneWidget);
    expect(find.text('Tao moi'), findsOneWidget);
  });

  testWidgets('GlassStateView dong goi state panel cho full-page flow', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassStateView(
            icon: Icons.cloud_off_rounded,
            title: 'Khong tai duoc du lieu',
            message: 'Vui long thu lai sau.',
          ),
        ),
      ),
    );

    expect(find.byType(SingleChildScrollView), findsOneWidget);
    expect(find.byType(GlassPanel), findsOneWidget);
    expect(find.text('Khong tai duoc du lieu'), findsOneWidget);
    expect(find.text('Vui long thu lai sau.'), findsOneWidget);
  });
}
