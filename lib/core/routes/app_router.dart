import 'package:flutter/material.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/auth/free_usage_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/search/gallery_screen.dart';
import '../../screens/search/ai_scan_screen.dart';
import '../../screens/analysis/ai_analysis_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String freeUsage = '/free-usage';
  static const String home = '/home';
  static const String search = '/search';
  static const String gallery = '/gallery';
  static const String aiScan = '/ai-scan';
  static const String analysis = '/analysis';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SplashScreen(),
        );

      case login:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const LoginScreen(),
        );

      case signup:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SignupScreen(),
        );

      case freeUsage:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FreeUsageScreen(),
        );

      case home:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const HomeScreen(),
        );

      case search:
        final query = settings.arguments as String? ?? '';

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SearchScreen(initialQuery: query),
        );

      case gallery:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const GalleryScreen(),
        );

      case aiScan:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AiScanScreen(),
        );

      case analysis:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AiAnalysisScreen(),
        );

      default:
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
