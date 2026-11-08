import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_theme.dart';
import '../../../models/history/price_history.dart';

class PriceTrendChart extends StatelessWidget {
  final PriceHistory priceHistory;
  final String timeRange;
  const PriceTrendChart({super.key, required this.priceHistory, required this.timeRange});

  @override
  Widget build(BuildContext context) {
    final points = priceHistory.points;
    if (points.isEmpty) return const SizedBox.shrink();
    final spots = points.asMap().entries.map((entry) => FlSpot(entry.key.toDouble(), entry.value.price)).toList();
    final currentPrice = points.last.price;
    final minY = (priceHistory.lowestPrice! * 0.9).roundToDouble();
    final maxY = (priceHistory.highestPrice! * 1.1).roundToDouble();

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMedium),
      decoration: BoxDecoration(color: AppColors.white, borderRadius: BorderRadius.circular(AppTheme.largeRadius), border: Border.all(color: AppColors.border)),
      child: Column(
        children: [
          SizedBox(
            height: 220,
            child: LineChart(
              LineChartData(
                minY: minY, maxY: maxY,
                gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: 20000, getDrawingHorizontalLine: (value) => FlLine(color: AppColors.border.withOpacity(0.5), strokeWidth: 1)),
                titlesData: FlTitlesData(
                  leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: true, reservedSize: 60, getTitlesWidget: (value, meta) => Text('Rs ${value.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodySmall))),
                  topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true, reservedSize: 30,
                      getTitlesWidget: (value, meta) {
                        final index = value.toInt();
                        if (index >= 0 && index < points.length) {
                          return Padding(padding: const EdgeInsets.only(top: 8), child: Text(DateFormat('MMM').format(points[index].date), style: Theme.of(context).textTheme.bodySmall));
                        }
                        return const Text('');
                      },
                    ),
                  ),
                ),
                borderData: FlBorderData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: spots, isCurved: true, color: AppColors.primaryGreen, barWidth: 3, isStrokeCapRound: true,
                    dotData: FlDotData(
                      show: true,
                      getDotPainter: (spot, percent, barData, index) {
                        if (index == points.length - 1) return FlDotCirclePainter(radius: 6, color: AppColors.white, strokeWidth: 3, strokeColor: AppColors.primaryGreen);
                        return FlDotCirclePainter(radius: 4, color: AppColors.primaryGreen, strokeWidth: 0);
                      },
                    ),
                    belowBarData: BarAreaData(show: true, color: AppColors.softMint.withOpacity(0.5)),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(AppTheme.largeRadius)),
              child: Text('Rs ${currentPrice.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.white, fontWeight: FontWeight.w600)),
            ),
          ),
        ],
      ),
    );
  }
}