import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../core/theme/app_colors.dart';
import '../../../models/history/price_history.dart';

class PriceChartWidget extends StatelessWidget {
  final PriceHistory priceHistory;
  final String timeRange;

  const PriceChartWidget({
    super.key,
    required this.priceHistory,
    required this.timeRange,
  });

  List<PriceHistoryPoint> get _filteredPoints {
    // For this beginner version, we just return all points.
    // Later, you can add logic here to filter by 1M, 3M, etc.
    return priceHistory.points;
  }

  @override
  Widget build(BuildContext context) {
    final points = _filteredPoints;
    if (points.isEmpty) return const SizedBox.shrink();

    // Convert data to FlSpot (X is index, Y is price)
    final spots = points.asMap().entries.map((entry) {
      return FlSpot(entry.key.toDouble(), entry.value.price);
    }).toList();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      height: 250,
      child: LineChart(
        LineChartData(
          gridData: const FlGridData(show: false),
          titlesData: FlTitlesData(
            leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                getTitlesWidget: (value, meta) {
                  // Show date for first and last point
                  final index = value.toInt();
                  if (index == 0 || index == points.length - 1) {
                    final date = points[index].date;
                    return Text(
                      '${date.day}/${date.month}',
                      style: const TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          borderData: FlBorderData(show: false),
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              color: AppColors.primaryGreen,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                color: AppColors.softMint.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}