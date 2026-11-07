
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dealix_ai/main.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:dealix_ai/screens/splash/splash_screen.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Dealix AI app loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const DealixApp());

    // Verify that the app starts with SplashScreen.
    expect(find.byType(SplashScreen), findsOneWidget);
    expect(find.text('Loading...'), findsOneWidget);

    // Advance the startup delay and allow navigation to Login.
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();

    // Verify that SplashScreen has navigated away.
    expect(find.byType(SplashScreen), findsNothing);
    expect(find.byType(Scaffold), findsWidgets);
  });
}
