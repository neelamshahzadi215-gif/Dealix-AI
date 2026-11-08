import 'package:dealix_ai/core/routes/app_router.dart';
import 'package:dealix_ai/screens/home/home_screen.dart';
import 'package:dealix_ai/screens/profile/profile_screen.dart';
import 'package:dealix_ai/widgets/common/dealix_main_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('loads profile details and approved profile rows', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));

    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.pumpAndSettle();

    expect(find.text('Profile'), findsWidgets);
    expect(find.text('Dealix User'), findsOneWidget);
    expect(find.text('user@example.com'), findsOneWidget);
    expect(find.text('Bahawalpur'), findsOneWidget);
    expect(find.text('PKR'), findsOneWidget);
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Alerts'), findsOneWidget);
    expect(find.text('Scan'), findsOneWidget);
    expect(find.text('Saved'), findsOneWidget);
    expect(find.text('Previous Searches'), findsOneWidget);
    expect(find.text('Saved Products'), findsOneWidget);
    expect(find.text('Send Feedback'), findsOneWidget);
    expect(find.text('Notifications'), findsOneWidget);
    expect(find.text('Activity Statistics'), findsNothing);
    expect(find.text('Change Password'), findsNothing);
    expect(find.text('Privacy Policy'), findsNothing);
    expect(find.text('Terms & Conditions'), findsNothing);
    expect(find.text('About Dealix-AI'), findsNothing);
    final bottomNav = tester.widget<DealixMainBottomNav>(
      find.byType(DealixMainBottomNav),
    );
    expect(bottomNav.selectedItem, DealixMainNavItem.profile);
    expect(
      tester
          .widget<Switch>(find.byKey(const ValueKey('notifications_switch')))
          .value,
      isTrue,
    );
  });

  testWidgets('notification toggle updates locally', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    final notificationSwitch = find.byKey(
      const ValueKey('notifications_switch'),
    );
    await tester.tap(notificationSwitch);
    await tester.pump();

    expect(tester.widget<Switch>(notificationSwitch).value, isFalse);
  });

  testWidgets('feedback and logout show the appropriate messages', (
    tester,
  ) async {
    await tester.pumpWidget(const MaterialApp(home: ProfileScreen()));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Send Feedback'));
    await tester.pumpAndSettle();
    expect(
      find.text(
        'Feedback submission is not available yet. Thanks for helping us improve Dealix-AI.',
      ),
      findsOneWidget,
    );
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Saved Products'));
    await tester.pump();
    expect(find.text('Saved products are not available yet.'), findsOneWidget);
    tester
        .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
        .hideCurrentSnackBar();
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Log out'));
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.pumpAndSettle();
    expect(find.text('Log out?'), findsNothing);

    await tester.ensureVisible(find.text('Log out'));
    await tester.tap(find.text('Log out'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Continue'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(
      find.text(
        "You're using Dealix-AI as a guest. There is no account to log out yet.",
      ),
      findsOneWidget,
    );
  });

  testWidgets('Home opens Profile and back navigation returns Home', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        initialRoute: AppRouter.home,
        onGenerateRoute: AppRouter.onGenerateRoute,
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Profile').last);
    await tester.pumpAndSettle();
    expect(find.byType(ProfileScreen), findsOneWidget);
    expect(find.text('Dealix User'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('Previous Searches opens the existing Search route', (
    tester,
  ) async {
    final observer = _RouteObserver();
    await tester.pumpWidget(
      MaterialApp(
        home: const ProfileScreen(),
        onGenerateRoute: AppRouter.onGenerateRoute,
        navigatorObservers: [observer],
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Previous Searches'));
    await tester.pump();

    expect(observer.lastPushedRoute, AppRouter.search);
    tester.state<NavigatorState>(find.byType(Navigator)).pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  });
}

class _RouteObserver extends NavigatorObserver {
  String? lastPushedRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushedRoute = route.settings.name;
  }
}
