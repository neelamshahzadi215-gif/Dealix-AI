import 'package:flutter/material.dart';

import 'screens/search/ai_scan_screen.dart';

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
