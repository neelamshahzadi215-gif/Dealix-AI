import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/history/price_history.dart';

class PriceInsightCard extends StatelessWidget {
  final PriceHistory priceHistory;

  const PriceInsightCard({super.key, required this.priceHistory});

  @override
  Widget build(BuildContext context) {
    final currentPrice = priceHistory.points.last.price;
    final lowestPrice = priceHistory.lowestPrice ?? currentPrice;

    // Simple logic: if current price is close to lowest price, suggest "Buy"
    final isGoodDeal = currentPrice <= (lowestPrice * 1.05); // Within 5% of lowest

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isGoodDeal ? AppColors.softMint : AppColors.lightMint,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isGoodDeal ? Icons.trending_down : Icons.trending_flat,
                color: isGoodDeal ? AppColors.primaryGreen : AppColors.accent,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                isGoodDeal ? 'Good Time to Buy' : 'Price is Stable',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'The current price is ${currentPrice.toStringAsFixed(0)} PKR. '
                'The lowest observed price was ${lowestPrice.toStringAsFixed(0)} PKR.',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            '*Buy/Wait insights are estimates based on available historical data, not guaranteed predictions.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }
}