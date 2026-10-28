import 'package:flutter/material.dart';
//import 'package:intl/intl.dart'; // Make sure to add 'intl' package if not present, or just use simple string
import '../../../core/theme/app_colors.dart';

class CurrentPriceHeader extends StatelessWidget {
  final String productName;
  final double currentPrice;
  final String currency;

  const CurrentPriceHeader({
    super.key,
    required this.productName,
    required this.currentPrice,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          productName,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              '$currency ',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              currentPrice.toStringAsFixed(0),
              style: const TextStyle(
                color: AppColors.primaryGreen,
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }
}