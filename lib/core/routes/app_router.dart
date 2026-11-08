import 'package:dealix_ai/models/product/product.dart';
import 'package:flutter/material.dart';

import '../../screens/splash/splash_screen.dart';
import '../../screens/auth/login_screen.dart';
import '../../screens/auth/signup_screen.dart';
import '../../screens/home/home_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/search/gallery_screen.dart';
import '../../screens/search/ai_scan_screen.dart';
import '../../screens/analysis/ai_analysis_screen.dart';
import '../../screens/comparison/comparison_screen.dart';

// ✅ 1. AAPKI SCREEN KA IMPORT YAHAN HAI
import '../../screens/history/price_history_screen.dart';

class AppRouter {
  AppRouter._();

  static const String splash = '/';
  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String search = '/search';
  static const String gallery = '/gallery';
  static const String aiScan = '/ai-scan';
  static const String analysis = '/analysis';
  static const String comparison = '/comparison';

  // ✅ 2. AAPKI SCREEN KA ROUTE NAME
  static const String priceHistory = '/price-history';

  // Ye routes abhi pending hain, inke liye hum fallback use karenge
  static const String freeUsage = '/free-usage';
  static const String profile = '/profile';
  static const String priceAlert = '/price-alert';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {

    // Helper function: Agar screen abhi bani nahi hai toh ye dikhayega
    Widget underConstruction(String name) {
      return Scaffold(
        appBar: AppBar(title: Text(name)),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.build, size: 50, color: Colors.grey),
              SizedBox(height: 16),
              Text('🚧 Under Construction 🚧', style: TextStyle(fontSize: 18)),
            ],
          ),
        ),
      );
    }

    switch (settings.name) {
      case splash:
        return MaterialPageRoute(builder: (_) => const SplashScreen(), settings: settings);

      case login:
        return MaterialPageRoute(builder: (_) => const LoginScreen(), settings: settings);

      case signup:
        return MaterialPageRoute(builder: (_) => const SignupScreen(), settings: settings);

      case home:
        return MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings);

    // ✅ 3. SEARCH SCREEN FIX (openedFromProfile hata diya kyunki local file mein nahi hai)
      case search:
        final arguments = settings.arguments;
        final query = arguments is String ? arguments : '';
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => SearchScreen(initialQuery: query),
        );

      case gallery:
        return MaterialPageRoute(builder: (_) => const GalleryScreen(), settings: settings);

      case aiScan:
        return MaterialPageRoute(builder: (_) => const AiScanScreen(), settings: settings);

      case analysis:
        return MaterialPageRoute(builder: (_) => const AiAnalysisScreen(), settings: settings);

      case comparison:
        final product = settings.arguments;
        if (product is! Product) {
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(
              body: Center(child: Text('A valid product is required for comparison.')),
            ),
          );
        }
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => ComparisonScreen(product: product),
        );

    // ✅ 4. AAPKI SCREEN KA ROUTE (Price History)
      case priceHistory:
        final args = settings.arguments;
        final productId = args is Map<String, dynamic> ? args['productId'] as String? : null;
        final productName = args is Map<String, dynamic> ? args['productName'] as String? : null;

        return MaterialPageRoute(
          settings: settings,
          builder: (_) => PriceHistoryScreen(
            productId: productId ?? 'p1',
            productName: productName ?? 'Sony WH-1000XM5 Wireless Headphones',
          ),
        );

    // ✅ 5. PENDING SCREENS KE LIYE SAFE FALLBACK (App crash nahi karegi)
      case freeUsage:
      case profile:
      case priceAlert:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => underConstruction(settings.name!),
        );

      default:
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Center(child: Text('Page not found'))),
        );
    }
  }
}