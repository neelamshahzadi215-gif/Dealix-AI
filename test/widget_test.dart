import 'package:flutter_test/flutter_test.dart';

import 'package:dealix_ai/main.dart';

void main() {
  testWidgets('Counter increments smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const DealixAI());

    // Verify that our counter starts at 0.
    expect(find.text('0'), findsOneWidget);
    expect(find.text('1'), findsNothing);

    expect(find.text('Hello! 👋'), findsOneWidget);
    expect(find.text('Find the best deals for you'), findsOneWidget);
    expect(find.text('Recent Searches'), findsOneWidget);
    expect(find.text('Popular Deals'), findsOneWidget);
  });
}
