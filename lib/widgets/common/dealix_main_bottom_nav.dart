import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

enum DealixMainNavItem { home, alerts, scan, saved, profile }

class DealixMainBottomNav extends StatelessWidget {
  final DealixMainNavItem? selectedItem;
  final ValueChanged<DealixMainNavItem> onTap;

  const DealixMainBottomNav({
    super.key,
    required this.selectedItem,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 8),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            _navItem(
              icon: Icons.home_rounded,
              label: 'Home',
              item: DealixMainNavItem.home,
            ),
            _navItem(
              icon: Icons.notifications_none_rounded,
              label: 'Alerts',
              item: DealixMainNavItem.alerts,
            ),
            Expanded(
              child: GestureDetector(
                onTap: () => onTap(DealixMainNavItem.scan),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                        color: AppColors.secondaryTeal,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.qr_code_scanner_rounded,
                        color: AppColors.white,
                        size: 24,
                      ),
                    ),
                    const SizedBox(height: 3),
                    const Text(
                      'Scan',
                      style: TextStyle(
                        color: AppColors.secondaryTeal,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _navItem(
              icon: Icons.favorite_border_rounded,
              label: 'Saved',
              item: DealixMainNavItem.saved,
            ),
            _navItem(
              icon: Icons.person_outline_rounded,
              label: 'Profile',
              item: DealixMainNavItem.profile,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required IconData icon,
    required String label,
    required DealixMainNavItem item,
  }) {
    final selected = selectedItem == item;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(item),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: selected
                  ? AppColors.secondaryTeal
                  : AppColors.textSecondary,
              size: 23,
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: selected
                    ? AppColors.secondaryTeal
                    : AppColors.textSecondary,
                fontSize: 9.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
