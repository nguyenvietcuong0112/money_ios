
import 'package:flutter_test/flutter_test.dart';
import 'package:money_manager/main.dart';

void main() {
  testWidgets('Renders MyHomePage', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp(isFirstTime: false));

    // Verify that our counter starts at 0.
    expect(find.byType(MyHomePage), findsOneWidget);
  });
}
