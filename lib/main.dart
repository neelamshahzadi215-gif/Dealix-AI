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
