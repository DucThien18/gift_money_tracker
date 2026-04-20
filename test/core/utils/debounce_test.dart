import 'package:flutter_test/flutter_test.dart';
import 'package:gift_money_tracker/core/utils/debounce.dart';

void main() {
  testWidgets('Debounce chi chay action cuoi cung', (WidgetTester tester) async {
    int value = 0;
    final Debounce debounce = Debounce(
      delay: const Duration(milliseconds: 120),
    );
    addTearDown(debounce.dispose);

    debounce(() {
      value = 1;
    });
    await tester.pump(const Duration(milliseconds: 80));

    debounce(() {
      value = 2;
    });
    await tester.pump(const Duration(milliseconds: 119));

    expect(value, 0);

    await tester.pump(const Duration(milliseconds: 1));

    expect(value, 2);
  });

  testWidgets('Debounce cancel va dispose huy action dang cho', (
    WidgetTester tester,
  ) async {
    int called = 0;
    final Debounce debounce = Debounce(
      delay: const Duration(milliseconds: 120),
    );

    debounce(() {
      called += 1;
    });
    debounce.cancel();
    await tester.pump(const Duration(milliseconds: 150));

    expect(called, 0);

    debounce(() {
      called += 1;
    });
    debounce.dispose();
    await tester.pump(const Duration(milliseconds: 150));

    expect(called, 0);
  });
}
