
import 'package:dealix_ai/core/routes/app_router.dart';
import 'package:dealix_ai/screens/profile/profile_screen.dart';
import 'package:dealix_ai/screens/search/search_screen.dart';
import 'package:dealix_ai/widgets/common/dealix_main_bottom_nav.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets(
    'Search bottom navigation uses shared navigation and Home stack',
    (tester) async {
      final observer = _RouteObserver();

      await tester.pumpWidget(_buildApp(observer));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Search'));

      // Allow the product-loading future to complete.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      await tester.pump();

      final searchScreen = find.byType(SearchScreen);

      expect(searchScreen, findsOneWidget);
      expect(
        find.descendant(
          of: searchScreen,
          matching: find.byType(CircularProgressIndicator),
        ),
        findsNothing,
        reason: 'SearchScreen is still loading after the bounded pump.',
      );

      _tapNavigation(tester, DealixMainNavItem.home);
      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
      expect(find.byType(SearchScreen), findsNothing);
      expect(observer.countPushed(AppRouter.home), 1);
    },
  );

  testWidgets(
    'Search opened from Profile returns to that Profile instance',
    (tester) async {
      final observer = _RouteObserver();

      await tester.pumpWidget(_buildApp(observer));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Profile'));
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);

      await tester.tap(find.text('Previous Searches'));
      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);

      _tapNavigation(tester, DealixMainNavItem.profile);
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);
      expect(find.byType(SearchScreen), findsNothing);
      expect(observer.countPushed(AppRouter.profile), 1);
    },
  );

  testWidgets(
    'direct Search opens Profile, Scan, and coming-soon messages',
    (tester) async {
      await tester.pumpWidget(_buildApp(_RouteObserver()));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Open Search'));

      // Wait for SearchScreen's asynchronous initial data.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 800));
      await tester.pump();
      await tester.pump();

      expect(find.byType(SearchScreen), findsOneWidget);

      _tapNavigation(tester, DealixMainNavItem.alerts);
      await tester.pump();

      expect(find.text('Alerts section coming soon.'), findsOneWidget);
      _hideSnackbar(tester);

      _tapNavigation(tester, DealixMainNavItem.saved);
      await tester.pump();

      expect(find.text('Saved section coming soon.'), findsOneWidget);
      _hideSnackbar(tester);

      _tapNavigation(tester, DealixMainNavItem.profile);
      await tester.pumpAndSettle();

      expect(find.byType(ProfileScreen), findsOneWidget);

      // Return from Profile to the previous Search route.
      Navigator.of(
        tester.element(find.byType(ProfileScreen)),
      ).pop();

      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);

      _tapNavigation(tester, DealixMainNavItem.scan);
      await tester.pumpAndSettle();

      expect(find.text('AI Scan route'), findsOneWidget);

      // Return from AI Scan to Search.
      Navigator.of(
        tester.element(find.text('AI Scan route')),
      ).pop();

      await tester.pumpAndSettle();

      expect(find.byType(SearchScreen), findsOneWidget);
    },
  );
}

void _tapNavigation(WidgetTester tester, DealixMainNavItem item) {
  tester
      .widget<DealixMainBottomNav>(find.byType(DealixMainBottomNav))
      .onTap(item);
}

void _hideSnackbar(WidgetTester tester) {
  tester
      .state<ScaffoldMessengerState>(find.byType(ScaffoldMessenger))
      .hideCurrentSnackBar();
}

Widget _buildApp(_RouteObserver observer) {
  return MaterialApp(
    initialRoute: AppRouter.home,

    // Directly create the test Home route.
    // This prevents the real SplashScreen from starting in widget tests.
    onGenerateInitialRoutes: (initialRoute) {
      return [
        MaterialPageRoute<void>(
          settings: const RouteSettings(name: AppRouter.home),
          builder: (_) => const _TestHomeScreen(),
        ),
      ];
    },

    navigatorObservers: [observer],

    onGenerateRoute: (settings) {
      if (settings.name == AppRouter.home) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const _TestHomeScreen(),
        );
      }

      if (settings.name == AppRouter.aiScan) {
        return MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            body: Text('AI Scan route'),
          ),
        );
      }

      return AppRouter.onGenerateRoute(settings);
    },
  );
}

class _TestHomeScreen extends StatelessWidget {
  const _TestHomeScreen();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          const Text('Home Screen'),
          TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.search,
              arguments: 'Samsung',
            ),
            child: const Text('Open Search'),
          ),
          TextButton(
            onPressed: () => Navigator.pushNamed(
              context,
              AppRouter.profile,
            ),
            child: const Text('Open Profile'),
          ),
        ],
      ),
    );
  }
}

class _RouteObserver extends NavigatorObserver {
  final List<String?> pushedRoutes = [];

  int countPushed(String routeName) =>
      pushedRoutes.where((name) => name == routeName).length;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushedRoutes.add(route.settings.name);
  }
}
