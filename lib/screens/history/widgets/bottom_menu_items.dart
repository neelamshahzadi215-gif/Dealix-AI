import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class BottomMenuItems extends StatelessWidget {
  final String productId;
  final VoidCallback onSetAlert;  // ✅ Yeh add karein
  final VoidCallback onShare;      // ✅ Yeh add karein

  const BottomMenuItems({
    super.key,
    required this.productId,
    required this.onSetAlert,  // ✅ Yeh add karein
    required this.onShare,      // ✅ Yeh add karein
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _buildMenuItem(
          icon: Icons.notifications_outlined,
          title: 'Set Price Alert',
          subtitle: 'Get notified when the price drops',
          onTap: onSetAlert,  // ✅ Yeh use karein
        ),
        const SizedBox(height: 12),
        _buildMenuItem(
          icon: Icons.share_outlined,
          title: 'Share Product',
          subtitle: 'Share with friends and family',
          onTap: onShare,  // ✅ Yeh use karein
        ),
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.textSecondary, size: 24),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
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