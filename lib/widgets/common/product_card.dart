import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../models/product/product.dart';
import 'availability_badge.dart';
import 'best_price_badge.dart';
import 'rating_row.dart';

class ProductCard extends StatelessWidget {
  final Product product;
  final bool showBestPrice;
  final VoidCallback? onTap;
  final VoidCallback? onFavorite;

  const ProductCard({
    super.key,
    required this.product,
    this.showBestPrice = false,
    this.onTap,
    this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: AppColors.lightMint,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.imageUrl.isNotEmpty
                      ? Image.network(
                          product.imageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) {
                            return const Icon(
                              Icons.shopping_bag_outlined,
                              color: AppColors.primaryGreen,
                              size: 35,
                            );
                          },
                        )
                      : const Icon(
                          Icons.shopping_bag_outlined,
                          color: AppColors.primaryGreen,
                          size: 35,
                        ),
                ),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (showBestPrice) ...[
                      const BestPriceBadge(),
                      const SizedBox(height: 7),
                    ],

                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),

                    const SizedBox(height: 4),

                    Text(
                      '${product.brand} ${product.model}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),

                    const SizedBox(height: 7),

                    Text(
                      'PKR ${product.price.toStringAsFixed(0)}',
                      style: const TextStyle(
                        color: AppColors.primaryGreen,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 7),

                    Row(
                      children: [
                        AvailabilityBadge(available: product.isAvailable),
                        const SizedBox(width: 8),
                        RatingRow(
                          rating: product.rating,
                          reviewCount: product.reviewCount,
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (onFavorite != null)
                IconButton(
                  onPressed: onFavorite,
                  icon: const Icon(Icons.favorite_border),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
