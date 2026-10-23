import 'package:flutter/material.dart';

import 'core/routes/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const DealixApp());
}

class DealixApp extends StatelessWidget {
  const DealixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Dealix AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouter.splash,
      onGenerateRoute: AppRouter.onGenerateRoute,
    );
  }
}
//product details code

// import 'package:dealix_ai/screens/comparison/comparison_screen.dart';
// import 'package:flutter/material.dart';

// import 'core/theme/app_theme.dart';
// //import 'screens/product/product_details_screen.dart';

// void main() {
//   runApp(const DealixApp());
// }

// class DealixApp extends StatelessWidget {
//   const DealixApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       home: const ComparisonScreen(),
//     );
//   }
// }

// import 'package:flutter/material.dart';

// import 'core/theme/app_theme.dart';
// import 'models/product/product.dart';
// import 'services/mock/mock_data_service.dart';
// import 'screens/comparison/comparison_screen.dart';

// void main() {
//   runApp(const DealixApp());
// }

// class DealixApp extends StatelessWidget {
//   const DealixApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: AppTheme.lightTheme,
//       home: const ComparisonHome(),
//     );
//   }
// }

// class ComparisonHome extends StatefulWidget {
//   const ComparisonHome({super.key});

//   @override
//   State<ComparisonHome> createState() => _ComparisonHomeState();
// }

// class _ComparisonHomeState extends State<ComparisonHome> {
//   late final Future<List<Product>> _productsFuture;

//   @override
//   void initState() {
//     super.initState();
//     _productsFuture = MockDataService().getProducts();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return FutureBuilder<List<Product>>(
//       future: _productsFuture,
//       builder: (context, snapshot) {
//         if (snapshot.connectionState == ConnectionState.waiting) {
//           return const Scaffold(
//             body: Center(child: CircularProgressIndicator()),
//           );
//         }

//         if (snapshot.hasError) {
//           return Scaffold(
//             body: Center(
//               child: Text(
//                 'Failed to load products: ${snapshot.error}',
//                 textAlign: TextAlign.center,
//               ),
//             ),
//           );
//         }

//         final products = snapshot.data ?? [];

//         if (products.isEmpty) {
//           return const Scaffold(
//             body: Center(child: Text('No products available.')),
//           );
//         }

//         final product = products.firstWhere(
//           (item) => item.id == 'p2',
//           orElse: () => products.first,
//         );

//         return ComparisonScreen(product: product);
//       },
//     );
//   }
// }
