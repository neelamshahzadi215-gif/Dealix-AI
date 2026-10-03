import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

class RatingRow extends StatelessWidget {
  final double rating;
  final int reviewCount;

  const RatingRow({super.key, required this.rating, this.reviewCount = 0});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.star, size: 18, color: AppColors.accent),
        const SizedBox(width: 4),
        Text(
          rating.toStringAsFixed(1),
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        if (reviewCount > 0) ...[
          const SizedBox(width: 5),
          Text(
            '($reviewCount reviews)',
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ],
    );
  }
}
