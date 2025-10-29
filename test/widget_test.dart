
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/main.dart';

void main() {
  testWidgets('Renders HomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isFirstTime: false));

    // Verify that our counter starts at 0.
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
