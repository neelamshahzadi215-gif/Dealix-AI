import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/history/price_history.dart';

class PriceInsightBanner extends StatelessWidget {
  final PriceHistory priceHistory;

  const PriceInsightBanner({super.key, required this.priceHistory});

  @override
  Widget build(BuildContext context) {
    final points = priceHistory.points;
    final currentPrice = points.last.price;
    final previousPrice = points.length > 1 ? points[points.length - 2].price : currentPrice;

    final percentageChange = ((previousPrice - currentPrice) / previousPrice * 100);
    final isPriceDropped = percentageChange > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.softMint,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(
            isPriceDropped ? Icons.trending_up : Icons.trending_down,
            color: AppColors.primaryGreen,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isPriceDropped
                      ? 'Price dropped by ${percentageChange.toStringAsFixed(0)}% compared to last week.'
                      : 'Price increased by ${percentageChange.abs().toStringAsFixed(0)}% compared to last week.',
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPriceDropped
                      ? 'This is a good time to buy!'
                      : 'You may want to wait for a better deal.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary, size: 20),
        ],
      ),
    );
  }
}