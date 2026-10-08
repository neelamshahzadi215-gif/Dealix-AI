import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';

void main() {
  runApp(const DealixAIApp());
}

class DealixAIApp extends StatelessWidget {
  const DealixAIApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AiScanScreen(),
    );
  }
}
