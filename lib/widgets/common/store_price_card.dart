import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/store/store_offer.dart';
import 'availability_badge.dart';
import 'best_price_badge.dart';
import 'rating_row.dart';

class StorePriceCard extends StatelessWidget {
  final StoreOffer offer;
  final bool isBestPrice;
  final VoidCallback? onStoreTap;

  const StorePriceCard({
    super.key,
    required this.offer,
    this.isBestPrice = false,
    this.onStoreTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    offer.storeName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                if (isBestPrice) const BestPriceBadge(),
              ],
            ),

            const SizedBox(height: 10),

            Text(
              'PKR ${offer.price.toStringAsFixed(0)}',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryGreen,
              ),
            ),

            if (offer.deliveryFee != null) ...[
              const SizedBox(height: 4),
              Text(
                'Delivery: PKR ${offer.deliveryFee!.toStringAsFixed(0)}',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],

            const SizedBox(height: 10),

            Row(
              children: [
                AvailabilityBadge(available: offer.isAvailable),
                const SizedBox(width: 10),
                if (offer.rating != null)
                  RatingRow(
                    rating: offer.rating!,
                    reviewCount: offer.reviewCount ?? 0,
                  ),
              ],
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: onStoreTap,
                child: const Text('View Store'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
