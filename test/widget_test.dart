import 'package:flutter_test/flutter_test.dart';

import 'package:dealix_ai/main.dart';

void main() {
  testWidgets('Dealix AI app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const DealixAIApp());

    expect(find.text('Hello! 👋'), findsOneWidget);
    expect(find.text('Find the best deals for you'), findsOneWidget);
    expect(find.text('Recent Searches'), findsOneWidget);
    expect(find.text('Popular Deals'), findsOneWidget);
  });
}
