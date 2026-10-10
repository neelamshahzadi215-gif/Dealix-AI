import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_svg/flutter_svg.dart';

import 'package:dealix_ai/screens/auth/login_screen.dart';

void main() {
  testWidgets('login screen matches the reference layout and logo', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.text('Welcome back'), findsOneWidget);
    expect(
      find.text('Log in to see your watchlist and alerts'),
      findsOneWidget,
    );
    expect(find.byType(TextField), findsNWidgets(2));
    expect(find.text('Email or phone'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.byType(SvgPicture), findsOneWidget);
    expect(tester.getSize(find.byType(SvgPicture)), const Size(17, 17));
    expect(find.text("Don't have an account? "), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CustomPaint && widget.painter is BottomWavesPainter,
      ),
      findsOneWidget,
    );

    final loginButton = find.byType(ElevatedButton);
    expect(tester.getSize(loginButton).height, 43);
    final loginButtonWidget = tester.widget<ElevatedButton>(loginButton);
    expect(
      loginButtonWidget.style?.backgroundColor?.resolve(const {}),
      const Color(0xFF078F70),
    );
    expect(
      loginButtonWidget.style?.foregroundColor?.resolve(const {}),
      Colors.white,
    );

    final logo = tester.widget<Image>(find.byType(Image));
    expect((logo.image as AssetImage).assetName, 'lib/core/Assets/logo.jpeg');
    expect(tester.getSize(find.byType(Image)).width, 48);
    expect(tester.getSize(find.byType(Image)).height, 48);
  });
}
