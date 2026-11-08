import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
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
        Expanded(child: _buildStatCard('Current Price', 'Rs ${currentPrice.toStringAsFixed(0)}', isPriceDropped ? '↓ ${percentageChange.toStringAsFixed(0)}%' : '↑ ${percentageChange.abs().toStringAsFixed(0)}%', isPriceDropped ? AppColors.primaryGreen : AppColors.error, 'Last updated: 2 hours ago', context)),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(child: _buildStatCard('Previous Price', 'Rs ${previousPrice.toStringAsFixed(0)}', '', null, '(1 week ago)', context)),
        const SizedBox(width: AppTheme.spacingSmall),
        Expanded(child: _buildStatCard('Lowest Recorded', 'Rs ${lowestPrice.toStringAsFixed(0)}', '', null, '(2 months ago)', context)),
      ],
    );
  }

  Widget _buildStatCard(String title, String price, String change, Color? changeColor, String subtitle, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSmall),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppTheme.mediumRadius), border: Border.all(color: AppColors.border)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w500)),
          const SizedBox(height: 6),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Flexible(child: Text(price, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: changeColor ?? AppColors.textPrimary, fontWeight: FontWeight.w700))),
              if (change.isNotEmpty) ...[
                const SizedBox(width: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: (changeColor ?? AppColors.primaryGreen).withOpacity(0.1), borderRadius: BorderRadius.circular(AppTheme.smallRadius)),
                  child: Text(change, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: changeColor ?? AppColors.primaryGreen, fontWeight: FontWeight.w600)),
                ),
              ],
            ],
          ),
          const SizedBox(height: 6),
          Text(subtitle, style: Theme.of(context).textTheme.bodySmall),
        ],
      ),
    );
  }
}