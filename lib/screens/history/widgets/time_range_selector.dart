import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';

class TimeRangeSelector extends StatelessWidget {
  final String selectedRange;
  final Function(String) onRangeSelected;

  const TimeRangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeSelected,
  });

  final List<String> _ranges = const ['1M', '3M', '6M', '1Y', 'All'];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _ranges.map((range) {
          final isSelected = selectedRange == range;
          return GestureDetector(
            onTap: () => onRangeSelected(range),
            child: Container(
              margin: const EdgeInsets.only(right: 12),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primaryGreen : AppColors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? AppColors.primaryGreen : AppColors.border,
                ),
              ),
              child: Text(
                range,
                style: TextStyle(
                  color: isSelected ? AppColors.white : AppColors.textSecondary,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}