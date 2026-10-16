import 'package:dealix_ai/screens/auth/login_screen.dart';
import 'package:dealix_ai/screens/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('signup screen shows fields and validates required values', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    expect(find.text('Create Account'), findsOneWidget);
    expect(find.text('Full Name'), findsOneWidget);
    expect(find.text('Email Address'), findsOneWidget);
    expect(find.text('Password'), findsOneWidget);
    expect(find.text('Confirm Password'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(4));

    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Please enter your full name.'), findsOneWidget);
    expect(find.text('Please enter your email address.'), findsOneWidget);
    expect(find.text('Please enter a password.'), findsOneWidget);
    expect(find.text('Please confirm your password.'), findsOneWidget);
  });

  testWidgets('signup validates email, password length, and password match', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    final fields = find.byType(TextFormField);
    await tester.enterText(fields.at(0), 'Dealix User');
    await tester.enterText(fields.at(1), 'invalid-email');
    await tester.enterText(fields.at(2), 'short');
    await tester.enterText(fields.at(3), 'different');

    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(find.text('Enter a valid email address.'), findsOneWidget);
    expect(
      find.text('Password must be at least 8 characters.'),
      findsOneWidget,
    );
    expect(find.text('Passwords do not match.'), findsOneWidget);

    await tester.enterText(fields.at(1), 'user@example.com');
    await tester.enterText(fields.at(2), 'dealixpass8');
    await tester.enterText(fields.at(3), 'dealixpass8');
    await tester.ensureVisible(find.text('Create Account'));
    await tester.tap(find.text('Create Account'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Account creation is UI only — authentication is not connected.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('password visibility toggles and Login opens LoginScreen', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: SignupScreen()));

    expect(find.byTooltip('Show Password'), findsOneWidget);
    expect(find.byTooltip('Show Confirm Password'), findsOneWidget);

    await tester.tap(find.byTooltip('Show Password'));
    await tester.pump();
    await tester.tap(find.byTooltip('Show Confirm Password'));
    await tester.pump();

    expect(find.byTooltip('Hide Password'), findsOneWidget);
    expect(find.byTooltip('Hide Confirm Password'), findsOneWidget);

    await tester.ensureVisible(find.text('Login'));
    await tester.tap(find.text('Login'));
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
  });
}
