import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';

class ProductHeaderSection extends StatelessWidget {
  final String productName;
  final String brand;
  final double rating;
  final int reviewCount;

  const ProductHeaderSection({super.key, required this.productName, required this.brand, required this.rating, required this.reviewCount});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppTheme.largeRadius), border: Border.all(color: AppColors.border)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 90, height: 90,
            decoration: BoxDecoration(color: AppColors.appBackground, borderRadius: BorderRadius.circular(AppTheme.mediumRadius), border: Border.all(color: AppColors.border)),
            child: const Icon(Icons.headphones, size: 50, color: AppColors.secondaryTeal),
          ),
          const SizedBox(width: AppTheme.spacingMedium),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(productName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('Wireless Headphones', style: Theme.of(context).textTheme.bodySmall),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 18, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('$rating', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
                        const SizedBox(width: 4),
                        Text('(${_formatReviewCount(reviewCount)})', style: Theme.of(context).textTheme.bodySmall),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Text(brand, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 4),
                    const Icon(Icons.verified, size: 16, color: AppColors.primaryGreen),
                  ],
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8, runSpacing: 4,
                  children: [_buildTag('Noise Canceling', context), _buildTag('Bluetooth 5.2', context)],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(String label, BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: AppColors.softMint, borderRadius: BorderRadius.circular(AppTheme.smallRadius)),
      child: Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.secondaryTeal, fontWeight: FontWeight.w500)),
    );
  }

  String _formatReviewCount(int count) {
    if (count >= 1000) return '${(count / 1000).toStringAsFixed(1)}k';
    return count.toString();
  }
}