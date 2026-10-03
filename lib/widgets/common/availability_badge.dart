import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class AvailabilityBadge extends StatelessWidget {
  final bool available;

  const AvailabilityBadge({super.key, required this.available});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: available ? AppColors.softMint : Colors.red.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        available ? 'Available' : 'Unavailable',
        style: TextStyle(
          color: available ? AppColors.primaryGreen : AppColors.error,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
