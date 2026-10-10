import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:dealix_ai/core/theme/app_colors.dart';
import 'package:dealix_ai/screens/auth/login_screen.dart';
import 'package:dealix_ai/widgets/common/primary_button.dart';

void main() {
  testWidgets('login uses a teal shared primary button', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();

    expect(find.byType(PrimaryButton), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
    expect(tester.getSize(find.byType(PrimaryButton)).height, 52);

    final buttonContext = tester.element(find.byType(PrimaryButton));
    final style = ElevatedButtonTheme.of(buttonContext).style!;
    expect(style.backgroundColor?.resolve(const {}), AppColors.secondaryTeal);
  });
}
