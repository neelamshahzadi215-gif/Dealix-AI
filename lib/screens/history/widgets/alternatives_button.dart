import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class AlternativesButton extends StatelessWidget {
  final VoidCallback onTap;
  const AlternativesButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(color: AppColors.secondaryTeal, borderRadius: BorderRadius.circular(AppTheme.mediumRadius)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: AppColors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(AppTheme.smallRadius)),
              child: const Icon(Icons.local_offer_outlined, color: AppColors.white, size: 24),
            ),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Find Cheaper Alternatives', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.white)),
                  const SizedBox(height: 4),
                  Text('See similar products at better prices', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.white)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.white, size: 20),
          ],
        ),
      ),
    );
  }
}