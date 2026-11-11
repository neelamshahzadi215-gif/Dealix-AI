import 'package:dealix_ai/models/product/product.dart';
import 'package:dealix_ai/models/alert/price_alert.dart';
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
import '../../screens/comparison/comparison_screen.dart';
import '../../screens/product/product_details_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/profile/profile_screen.dart';
import '../../screens/price_alert/set_price_alert_screen.dart';
import '../../screens/price_alert/my_alerts_screen.dart';
import '../../screens/history/price_history_screen.dart';
import '../../screens/alternatives/alternatives_screen.dart';

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
  static const String comparison = '/comparison';
  static const String productDetails = '/product-details';
  static const String favorites = '/favorites';
  static const String profile = '/profile';
  static const String priceAlert = '/price-alert';
  static const String myAlerts = '/my-alerts';
  static const String priceHistory = '/price-history';
  static const String alternatives = '/alternatives';

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

      case profile:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const ProfileScreen(),
        );

      case search:
        final arguments = settings.arguments;
        final query = arguments is String ? arguments : '';
        final openedFromProfile =
            arguments is Map<String, Object?> &&
            arguments['fromProfile'] == true;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SearchScreen(
            initialQuery: query,
            openedFromProfile: openedFromProfile,
          ),
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

      case comparison:
        final product = settings.arguments;

        if (product is! Product) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('A valid product is required for comparison.'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ComparisonScreen(product: product),
        );

      // Product Details Route
      case productDetails:
        final product = settings.arguments;

        if (product is! Product) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(
                child: Text('A valid product is required for product details.'),
              ),
            ),
          );
        }

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ProductDetailsScreen(product: product),
        );

      // Favorites Route
      case favorites:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const FavoritesScreen(),
        );

      case priceAlert:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const SetPriceAlertScreen(),
        );

      case myAlerts:
        final alerts = settings.arguments as List<PriceAlert>? ?? [];

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => MyAlertsScreen(savedAlerts: alerts),
        );

      case priceHistory:
        final args = settings.arguments;

        final productId = args is Map<String, dynamic>
            ? args['productId'] as String?
            : null;

        final productName = args is Map<String, dynamic>
            ? args['productName'] as String?
            : null;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PriceHistoryScreen(
            productId: productId ?? 'p1',
            productName: productName ?? 'Sony WH-1000XM5 Wireless Headphones',
          ),
        );

      case alternatives:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const AlternativesScreen(),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) =>
              const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}
