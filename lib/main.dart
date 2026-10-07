import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'screens/analysis/ai-analysis_screen.dart';

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
      home: const AiAnalysisScreen(),
    );
  }
}
