import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/history/price_history.dart';

class PriceStatsRow extends StatelessWidget {
  final PriceHistory priceHistory;

  const PriceStatsRow({super.key, required this.priceHistory});

  @override
  Widget build(BuildContext context) {
    final points = priceHistory.points;
    final currentPrice = points.last.price;
    final previousPrice = points.length > 1 ? points[points.length - 2].price : currentPrice;
    final lowestPrice = priceHistory.lowestPrice ?? currentPrice;

    final percentageChange = ((previousPrice - currentPrice) / previousPrice * 100);
    final isPriceDropped = percentageChange > 0;

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            'Current Price',
            'Rs ${currentPrice.toStringAsFixed(0)}',
            isPriceDropped ? '↓ ${percentageChange.toStringAsFixed(0)}%' : '↑ ${percentageChange.abs().toStringAsFixed(0)}%',
            isPriceDropped ? AppColors.primaryGreen : AppColors.error,
            'Last updated: 2 hours ago',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Previous Price',
            'Rs ${previousPrice.toStringAsFixed(0)}',
            '',
            null,
            '(1 week ago)',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _buildStatCard(
            'Lowest Recorded',
            'Rs ${lowestPrice.toStringAsFixed(0)}',
            '',
            null,
            '(2 months ago)',
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard(String title, String price, String change, Color? changeColor, String subtitle) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(
                child: Text(
                  price,
                  style: TextStyle(
                    color: changeColor ?? AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (change.isNotEmpty) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: (changeColor ?? AppColors.primaryGreen).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    change,
                    style: TextStyle(
                      color: changeColor ?? AppColors.primaryGreen,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }
}