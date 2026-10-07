import 'package:dealix_ai/screens/splash/splash_screen.dart';

import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const DealixAI());
}

class DealixAI extends StatelessWidget {
  const DealixAI({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dealix AI',
      theme: AppTheme.lightTheme,
      home: const SplashScreen(),
    );
  }
}
