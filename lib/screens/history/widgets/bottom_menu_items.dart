import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class BottomMenuItems extends StatelessWidget {
  final String productId;
  final VoidCallback onSetAlert;
  final VoidCallback onShare;

  const BottomMenuItems({super.key, required this.productId, required this.onSetAlert, required this.onShare});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(icon: Icons.notifications_outlined, title: 'Set Price Alert', subtitle: 'Get notified when the price drops', onTap: onSetAlert, context: context),
        const SizedBox(height: AppTheme.spacingSmall),
        _buildMenuItem(icon: Icons.share_outlined, title: 'Share Product', subtitle: 'Share with friends and family', onTap: onShare, context: context),
      ],
    );
  }

  Widget _buildMenuItem({required IconData icon, required String title, required String subtitle, required VoidCallback onTap, required BuildContext context}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMedium),
        decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppTheme.mediumRadius), border: Border.all(color: AppColors.border)),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: AppTheme.spacingSmall),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.titleSmall),
                  const SizedBox(height: 4),
                  Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.textSecondary),
          ],
        ),
      ),
    );
  }
}